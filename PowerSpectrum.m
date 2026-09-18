function [spectra, freqs] = PowerSpectrum(data, Fs, segLen)
% POWERSPECTRUM One-sided power spectral density of a single EEG epoch.
%
%   [spectra, freqs] = PowerSpectrum(data, Fs)
%   [spectra, freqs] = PowerSpectrum(data, Fs, segLen)
%
%   data    vector of samples (one channel, one epoch)
%   Fs      sampling rate (Hz)
%   segLen  segment length in samples (default round(2*Fs), i.e. 2 s,
%           which gives a 0.5 Hz frequency grid)
%
%   Epochs no longer than segLen are Hamming-windowed and zero-padded to
%   segLen (identical frequency grid and peak location to toolbox v1.0).
%   Longer epochs are split into Hamming-windowed segments with 50%
%   overlap and their power is averaged (Welch's method), so the whole
%   epoch contributes to the estimate.
%
%   spectra  PSD (units^2/Hz), row vector
%   freqs    frequency of each bin (Hz), row vector from 0 to Fs/2

if nargin < 3 || isempty(segLen)
    segLen = round(2*Fs);
end
data = double(data(:))';
L = numel(data);
NFFT = segLen;

if L <= segLen
    starts = 1;
    winLen = L;
else
    step = floor(segLen/2);
    starts = 1:step:(L - segLen + 1);
    winLen = segLen;
end

n = (0:winLen-1);
if winLen > 1
    w = 0.54 - 0.46*cos(2*pi*n/(winLen-1));    % Hamming window (no toolbox needed)
else
    w = 1;
end
U = sum(w.^2);

P = zeros(1, NFFT);
for s = starts
    seg = data(s:s+winLen-1);
    seg = seg - mean(seg);                     % remove DC offset
    X = fft(seg .* w, NFFT);
    P = P + abs(X).^2;
end
P = P / numel(starts) / (Fs*U);

nOneSided = floor(NFFT/2) + 1;
spectra = P(1:nOneSided);
if mod(NFFT, 2) == 0
    spectra(2:end-1) = 2*spectra(2:end-1);
else
    spectra(2:end) = 2*spectra(2:end);
end
freqs = (0:nOneSided-1) * Fs/NFFT;

end
