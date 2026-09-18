function R = fe_extract(X, varargin)
% FE_EXTRACT Dominant-frequency EEG features for one recording.
%
%   R = fe_extract(EEG, Name, Value, ...)       EEGLAB dataset structure
%   R = fe_extract(data, Fs, Name, Value, ...)  numeric [channels x samples x epochs]
%
%   Name-value options
%     'Bands'         cell array {name, [low high]; ...}. Default: the four
%                     README bands (Delta 3-3.5, Theta 4-5.5, PreAlpha 6-7.5,
%                     Alpha 8-12 Hz).
%     'Passband'      [low high] of the band-pass filter already applied to
%                     the data, or [] if unknown/unfiltered (default []).
%                     Bands outside the passband are returned as NaN, and the
%                     dominant-frequency search is restricted to the passband.
%     'DFRange'       [low high] search range for the whole-spectrum dominant
%                     frequency. Default: Passband if given, else (0, Fs/2].
%     'IAFRange'      [low high] search range for individual alpha frequency
%                     (default [7 13]).
%     'SegmentLength' spectral segment length in seconds (default 2, giving a
%                     0.5 Hz frequency grid).
%     'Continuous'    true to cut numeric data into non-overlapping
%                     SegmentLength epochs (default false). EEGLAB datasets
%                     with EEG.trials == 1 are always treated as continuous.
%     'ChannelLabels' cellstr of channel names (default: EEG.chanlocs labels,
%                     else Ch1..ChN).
%
%   Output structure R (C = channels, E = epochs, B = bands)
%     DF          C x E  dominant frequency of each epoch (Hz)
%     DFband      C x E x B  dominant frequency within each band (Hz)
%     DFV         C x B  SD across epochs of the within-band dominant frequency
%     DFV_overall C x 1  SD across epochs of DF
%     DFP         C x (B+1)  % of epochs whose DF falls in each band; the last
%                 column ('Other') holds epochs whose DF falls in no band, so
%                 each row sums to 100
%     AbsPow      C x B  band power (units^2), from the epoch-averaged PSD
%     RelPow      C x B  band power as % of the total power across all valid
%                 bands
%     IAF_peak    C x 1  alpha peak frequency of the epoch-averaged PSD (Hz)
%     IAF_cog     C x 1  alpha centre-of-gravity frequency (Hz)
%     meanPSD, freqs, chanlabels, bandNames, bandRanges, bandValid,
%     Fs, nbchan, nEpochs, epochLength

p = inputParser;
p.FunctionName = 'fe_extract';
if isstruct(X)
    EEG = X;
    data = double(EEG.data);
    Fs = EEG.srate;
    isCont = isfield(EEG, 'trials') && EEG.trials == 1;
    defLabels = {};
    if isfield(EEG, 'chanlocs') && numel(EEG.chanlocs) == size(data, 1)
        defLabels = {EEG.chanlocs.labels};
    end
    args = varargin;
else
    if isempty(varargin) || ~isnumeric(varargin{1})
        error('fe_extract:input', 'Numeric input requires the sampling rate: fe_extract(data, Fs, ...)');
    end
    data = double(X);
    Fs = varargin{1};
    isCont = false;
    defLabels = {};
    args = varargin(2:end);
end

defBands = {'Delta', [3 3.5]; 'Theta', [4 5.5]; 'PreAlpha', [6 7.5]; 'Alpha', [8 12]};
addParameter(p, 'Bands', defBands);
addParameter(p, 'Passband', []);
addParameter(p, 'DFRange', []);
addParameter(p, 'IAFRange', [7 13]);
addParameter(p, 'SegmentLength', 2);
addParameter(p, 'Continuous', false);
addParameter(p, 'ChannelLabels', defLabels);
parse(p, args{:});
o = p.Results;

segLen = round(o.SegmentLength * Fs);
[nCh, nSamp, nEp] = size(data);

% Continuous data -> non-overlapping epochs
if isCont || o.Continuous
    if nEp ~= 1
        error('fe_extract:continuous', 'Continuous data must have a single epoch.');
    end
    nEp = floor(nSamp / segLen);
    if nEp < 1
        error('fe_extract:tooShort', 'Recording is shorter than one %g-s segment.', o.SegmentLength);
    end
    if nEp * segLen < nSamp
        warning('fe_extract:remainder', 'Continuous data: %d trailing samples discarded after cutting %d epochs of %g s.', ...
            nSamp - nEp*segLen, nEp, o.SegmentLength);
    end
    data = reshape(data(:, 1:nEp*segLen), nCh, segLen, nEp);
    nSamp = segLen;
end

% Bands
bandNames = o.Bands(:, 1)';
bandRanges = cell2mat(o.Bands(:, 2));
nB = numel(bandNames);
if any(~isfinite(bandRanges(:))) || any(bandRanges(:, 1) > bandRanges(:, 2))
    error('fe_extract:bands', 'Each band needs finite limits with low <= high.');
end
bandValid = true(1, nB);
if ~isempty(o.Passband)
    bandValid = bandRanges(:, 1)' >= o.Passband(1) & bandRanges(:, 2)' <= o.Passband(2);
    if any(~bandValid)
        warning('fe_extract:bandOutsidePassband', ...
            'Band(s) %s lie outside the %g-%g Hz passband and are returned as NaN.', ...
            strjoin(bandNames(~bandValid), ', '), o.Passband(1), o.Passband(2));
    end
end

% Channel labels (unique, valid row names)
labels = o.ChannelLabels;
if isempty(labels) || numel(labels) ~= nCh
    labels = arrayfun(@(k) sprintf('Ch%d', k), 1:nCh, 'UniformOutput', false);
end
labels = cellfun(@char, labels, 'UniformOutput', false);
blank = cellfun(@isempty, strtrim(labels));
labels(blank) = arrayfun(@(k) sprintf('Ch%d', k), find(blank), 'UniformOutput', false);
labels = matlab.lang.makeUniqueStrings(labels);

% Frequency grid and masks
[~, freqs] = PowerSpectrum(zeros(1, nSamp), Fs, segLen);
nF = numel(freqs);
dfRange = o.DFRange;
if isempty(dfRange)
    if isempty(o.Passband), dfRange = [eps Fs/2]; else, dfRange = o.Passband; end
end
dfMask = freqs >= dfRange(1) & freqs <= dfRange(2);
dfFreqs = freqs(dfMask);
bandMask = false(nB, nF);
for b = 1:nB
    bandMask(b, :) = freqs >= bandRanges(b, 1) & freqs <= bandRanges(b, 2);
    if bandValid(b) && ~any(bandMask(b, :))
        warning('fe_extract:emptyBand', 'Band %s contains no frequency bins at %.3g Hz resolution.', ...
            bandNames{b}, freqs(2) - freqs(1));
    end
end
iafMask = freqs >= o.IAFRange(1) & freqs <= o.IAFRange(2);

% Per-epoch spectra
DF = nan(nCh, nEp);
DFband = nan(nCh, nEp, nB);
meanPSD = zeros(nCh, nF);
for ch = 1:nCh
    for ep = 1:nEp
        s = PowerSpectrum(data(ch, :, ep), Fs, segLen);
        meanPSD(ch, :) = meanPSD(ch, :) + s / nEp;
        [~, i] = max(s(dfMask));
        DF(ch, ep) = dfFreqs(i);
        for b = find(bandValid & any(bandMask, 2)')
            fb = freqs(bandMask(b, :));
            [~, i] = max(s(bandMask(b, :)));
            DFband(ch, ep, b) = fb(i);
        end
    end
end

% Variability
DFV = reshape(std(DFband, 0, 2), nCh, nB);
DFV_overall = std(DF, 0, 2);

% Prevalence
DFP = nan(nCh, nB + 1);
inAny = false(nCh, nEp);
for b = 1:nB
    inBand = DF >= bandRanges(b, 1) & DF <= bandRanges(b, 2);
    if bandValid(b)
        DFP(:, b) = 100 * mean(inBand, 2);
        inAny = inAny | inBand;
    end
end
DFP(:, end) = 100 * mean(~inAny, 2);

% Band power from the epoch-averaged PSD
df = freqs(2) - freqs(1);
AbsPow = nan(nCh, nB);
for b = find(bandValid)
    AbsPow(:, b) = sum(meanPSD(:, bandMask(b, :)), 2) * df;
end
totMask = any(bandMask(bandValid, :), 1);
totPow = sum(meanPSD(:, totMask), 2) * df;
RelPow = 100 * AbsPow ./ totPow;

% Individual alpha frequency
fI = freqs(iafMask);
PI = meanPSD(:, iafMask);
[~, i] = max(PI, [], 2);
IAF_peak = fI(i)';
IAF_cog = (PI * fI') ./ sum(PI, 2);

R = struct('Fs', Fs, 'nbchan', nCh, 'nEpochs', nEp, 'epochLength', nSamp / Fs, ...
    'chanlabels', {labels(:)}, 'bandNames', {bandNames}, 'bandRanges', bandRanges, ...
    'bandValid', bandValid, 'freqs', freqs, 'meanPSD', meanPSD, ...
    'DF', DF, 'DFband', DFband, 'DFV', DFV, 'DFV_overall', DFV_overall, ...
    'DFP', DFP, 'AbsPow', AbsPow, 'RelPow', RelPow, ...
    'IAF_peak', IAF_peak, 'IAF_cog', IAF_cog);
end
