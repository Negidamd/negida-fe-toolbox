function tests = test_fe_toolbox
% TEST_FE_TOOLBOX Regression tests on synthetic EEG with known answers.
%
%   Run from the repository root:
%       addpath(pwd); results = runtests('tests/test_fe_toolbox.m')
%
%   The end-to-end GUI test needs EEGLAB on the path (or its folder in the
%   EEGLAB_PATH environment variable) and is skipped otherwise.
tests = functiontests(localfunctions);
end

function setupOnce(tc)
tc.TestData.Fs = 250;
tc.TestData.t = (0:499) / 250;             % one 2-s epoch
rng(1);
end

% ---------------------------------------------------------------- spectra
function testTwoSecondEpochMatchesV1(tc)
% For the standard 2-s epoch, DF must be identical to toolbox v1.0.
Fs = tc.TestData.Fs; t = tc.TestData.t;
for f = [3 4.5 6.5 9 11.5]
    x = sin(2*pi*f*t) + 0.3*randn(size(t));
    [s1, f1] = legacyPowerSpectrum(x, Fs);
    [s2, f2] = PowerSpectrum(x, Fs);
    verifyEqual(tc, f2, f1, 'AbsTol', 1e-12);
    [~, i1] = max(s1); [~, i2] = max(s2);
    verifyEqual(tc, f2(i2), f1(i1));
end
end

function testLongEpochUsesWholeEpoch(tc)
% Epochs longer than 2 s: the whole epoch contributes to the spectrum.
Fs = 250; t = (0:999) / Fs;
x = [sin(2*pi*10*t(1:500)), 3*sin(2*pi*6*t(501:1000))];
R = fe_extract(reshape(x, 1, [], 1), Fs);
verifyEqual(tc, R.DF, 6);
end

function testOddSamplingRates(tc)
for Fs = [128 256 500 512 1000]
    t = (0:2*Fs-1) / Fs;
    R = fe_extract(repmat(sin(2*pi*7*t), [2 1 3]), Fs);
    verifyEqual(tc, R.DF, 7*ones(2, 3), sprintf('Fs = %d', Fs));
end
end

% --------------------------------------------------------- relative power
function testRelativePowerPureAlpha(tc)
% Relative power is expressed as % of total power.
x = 20*sin(2*pi*10*tc.TestData.t);
R = fe_extract(repmat(x, [1 1 5]), tc.TestData.Fs);
verifyGreaterThan(tc, R.RelPow(4), 95);
verifyLessThan(tc, R.RelPow(1:3), 5);
verifyEqual(tc, sum(R.RelPow), 100, 'AbsTol', 1e-9);
end

function testRelativePowerDiffersByBand(tc)
% Each band has its own relative power.
t = tc.TestData.t;
x = 10*sin(2*pi*5*t) + 5*sin(2*pi*10*t) + 0.1*randn(size(t));
R = fe_extract(repmat(x, [1 1 4]), tc.TestData.Fs);
verifyGreaterThan(tc, R.RelPow(2), R.RelPow(4));
verifyGreaterThan(tc, R.RelPow(4), R.RelPow(1));
verifyEqual(tc, sum(R.RelPow), 100, 'AbsTol', 1e-9);
end

% ------------------------------------------------------ DFV / DFP / IAF
function testDFVSteadyAndAlternating(tc)
t = tc.TestData.t;
steady = repmat(sin(2*pi*10*t), [3 1 20]);
alt = zeros(3, 500, 20);
for e = 1:20, alt(:, :, e) = repmat(sin(2*pi*(8 + 4*mod(e, 2))*t), 3, 1); end
Rs = fe_extract(steady, 250);
Ra = fe_extract(alt, 250);
verifyEqual(tc, Rs.DFV_overall, zeros(3, 1));
verifyEqual(tc, Rs.DFV(:, 4), zeros(3, 1));
verifyEqual(tc, Ra.DFV_overall, std([8 12 8 12 8 12 8 12 8 12 8 12 8 12 8 12 8 12 8 12]) * ones(3, 1), 'AbsTol', 1e-12);
end

function testSubjectsAreIndependent(tc)
% Results for a subject do not depend on which subjects were processed before.
% Run the GUI's per-subject sequence and compare with running B alone.
t = tc.TestData.t;
A = zeros(19, 500, 60);
for e = 1:60, A(:, :, e) = repmat(sin(2*pi*(8 + 4*mod(e, 2))*t), 19, 1); end
B = repmat(sin(2*pi*10*t), [19 1 20]) + 0.01*randn(19, 500, 20);
fe_extract(A, 250);
RbAfterA = fe_extract(B, 250);
RbAlone = fe_extract(B, 250);
verifyEqual(tc, RbAfterA.DFV, RbAlone.DFV);
verifyEqual(tc, RbAfterA.DFV(:, 4), zeros(19, 1));
end

function testDFPSumsTo100WithOther(tc)
t = tc.TestData.t;
X = zeros(1, 500, 10);
freqsIn = [3 5 7 10 10 10 13 13.5 2 11];     % 13, 13.5, 2 Hz fall in no band
for e = 1:10, X(1, :, e) = sin(2*pi*freqsIn(e)*t); end
R = fe_extract(X, 250);
verifyEqual(tc, sum(R.DFP, 2), 100, 'AbsTol', 1e-9);
verifyEqual(tc, R.DFP, [10 10 10 40 30], 'AbsTol', 1e-9);
end

function testIAF(tc)
t = tc.TestData.t;
R = fe_extract(repmat(sin(2*pi*9.5*t) + 0.05*randn(1, 500), [2 1 10]), 250);
verifyEqual(tc, R.IAF_peak, [9.5; 9.5]);
verifyEqual(tc, R.IAF_cog, [9.5; 9.5], 'AbsTol', 0.3);
end

% ------------------------------------------------------ passband / input
function testBandsOutsidePassbandAreNaN(tc)
bands = {'Delta', [3 3.5]; 'Theta', [4 5.5]; 'PreAlpha', [6 7.5]; ...
         'Alpha', [8 12]; 'Beta', [13 30]; 'Gamma', [30 45]};
X = repmat(sin(2*pi*10*tc.TestData.t), [2 1 3]);
R = verifyWarning(tc, @() fe_extract(X, 250, 'Bands', bands, 'Passband', [3 14]), ...
    'fe_extract:bandOutsidePassband');
verifyTrue(tc, all(isnan(R.RelPow(:, 5:6)), 'all'));
verifyTrue(tc, all(isnan(R.DFV(:, 5:6)), 'all'));
verifyEqual(tc, sum(R.RelPow(:, 1:4), 2), [100; 100], 'AbsTol', 1e-9);
R2 = fe_extract(X, 250, 'Bands', bands);   % unfiltered: all bands computed
verifyFalse(tc, any(isnan(R2.RelPow), 'all'));
end

function testContinuousDataIsEpoched(tc)
Fs = 250; t = (0:10*Fs-1) / Fs;             % 10 s continuous
EEG = struct('data', sin(2*pi*9*t), 'srate', Fs, 'trials', 1, ...
    'chanlocs', struct('labels', {'Oz'}));
R = fe_extract(EEG);
verifyEqual(tc, R.nEpochs, 5);
verifyEqual(tc, R.DF, 9*ones(1, 5));
verifyEqual(tc, R.chanlabels, {'Oz'});
end

function testAnyChannelCountAndLabels(tc)
% Any montage size, with the dataset's own channel labels.
X = repmat(sin(2*pi*10*tc.TestData.t), [32 1 3]);
labels = [arrayfun(@(k) sprintf('E%d', k), 1:31, 'UniformOutput', false), {'E1'}];
R = fe_extract(X, 250, 'ChannelLabels', labels);
verifyEqual(tc, numel(unique(R.chanlabels)), 32);
out = tempname; mkdir(out); cleanup = onCleanup(@() rmdir(out, 's'));
sel = struct('DF', 1, 'DFV', 1, 'DFP', 1, 'RelativePow', 1, 'PerChannel', 1, 'PerEpoch', 1);
S = fe_write_results(R, 'S032', out, sel);
verifyEqual(tc, height(S), 32);
T = readtable(fullfile(out, 'EEG_Results_DFV_Toolbox.xlsx'), 'Sheet', 'S032', 'ReadRowNames', true);
verifyEqual(tc, size(T), [32 5]);
end

function testRerunOverwritesSheet(tc)
% Writing a smaller result to an existing sheet must not leave stale rows.
out = tempname; mkdir(out); cleanup = onCleanup(@() rmdir(out, 's'));
sel = struct('DF', 1);
fe_write_results(fe_extract(repmat(sin(2*pi*10*tc.TestData.t), [8 1 2]), 250), 'S1', out, sel);
fe_write_results(fe_extract(repmat(sin(2*pi*10*tc.TestData.t), [4 1 2]), 250), 'S1', out, sel);
T = readtable(fullfile(out, 'EEG_Results_DF_forallEpochandChannel.xlsx'), 'Sheet', 'S1', 'ReadRowNames', true);
verifyEqual(tc, height(T), 4);
end

function testSheetNames(tc)
verifyEqual(tc, fe_sheetname('S001-preprocessed.set'), 'S001-preprocessed');
verifyEqual(tc, fe_sheetname('a[b]:c*?.set'), 'a_b__c__');
verifyEqual(tc, strlength(fe_sheetname(repmat('x', 1, 50))), 31);
end

% ------------------------------------------------------- GUI end to end
function testGuiEndToEnd(tc)
% Two subjects with different epoch counts plus the single-file case,
% run through the real GUI callback with EEGLAB loading and filtering.
if ~exist('pop_loadset', 'file')
    p = getenv('EEGLAB_PATH');
    assumeFalse(tc, isempty(p), 'EEGLAB not on path and EEGLAB_PATH not set');
    addpath(p); eeglab('nogui');
end
in = tempname; out = tempname; mkdir(in); mkdir(out);
cleanup = onCleanup(@() cellfun(@(d) rmdir(d, 's'), {in, out}));
Fs = 250; t = (0:499) / Fs;
labels = {'Fp1','Fp2','F3','F4','C3','C4','P3','P4','O1','O2','F7','F8','T3','T4','T5','T6','Fz','Cz','Pz','Oz','FC1','FC2'};
A = zeros(22, 500, 30);
for e = 1:30, A(:, :, e) = repmat(sin(2*pi*(8 + 4*mod(e, 2))*t), 22, 1); end
B = repmat(sin(2*pi*10*t), [22 1 12]) + 0.01*randn(22, 500, 12);
saveSet(A, Fs, labels, in, 'S001_A.set');
saveSet(B, Fs, labels, in, 'S002_B.set');

sel = {'DF', 'DFV', 'DFP', 'RelativePow', 'PerChannel', 'PerEpoch'};
fig = FE_Toolbox; set(fig, 'Visible', 'off'); closeFig = onCleanup(@() delete(fig));
h = guidata(fig);
for k = 1:numel(sel), set(h.(sel{k}), 'Value', 1); end
h.inputfile = {'S001_A.set', 'S002_B.set'}; h.inputpath = in; h.outDir = out;
h.filterChoice = 'Yes (3-14 Hz)';
FE_Toolbox('FinalRUN_Callback', fig, [], h);

S = readtable(fullfile(out, 'EEG_Results_Summary.xlsx'), 'Sheet', 'Summary');
verifyEqual(tc, height(S), 44);
dfvB = S.DFV(strcmp(S.Subject, 'S002_B'));
verifyEqual(tc, dfvB, zeros(22, 1));
T = readtable(fullfile(out, 'EEG_Results_RelativePow_Toolbox.xlsx'), 'Sheet', 'S002_B', 'ReadRowNames', true);
verifyEqual(tc, T.Properties.RowNames(1:3), {'Fp1'; 'Fp2'; 'F3'});
verifyTrue(tc, all(isnan(T.Beta)) && all(isnan(T.Gamma)));
verifyGreaterThan(tc, T.Alpha, 90 * ones(22, 1));

% Single-file selection: uigetfile returns a char array, not a cell
h.inputfile = 'S002_B.set';
FE_Toolbox('FinalRUN_Callback', fig, [], h);
S1 = readtable(fullfile(out, 'EEG_Results_Summary.xlsx'), 'Sheet', 'Summary');
verifyEqual(tc, height(S1), 22);
end

% ---------------------------------------------------------------- helpers
function saveSet(X, Fs, labels, folder, name)
EEG = eeg_emptyset;
EEG.data = single(X); EEG.srate = Fs;
EEG.nbchan = size(X, 1); EEG.pnts = size(X, 2); EEG.trials = size(X, 3);
EEG.xmin = 0; EEG.chanlocs = struct('labels', labels);
EEG = eeg_checkset(EEG);
pop_saveset(EEG, 'filename', name, 'filepath', folder);
end

function [spectra, freqs] = legacyPowerSpectrum(data, Fs)
% PowerSpectrum.m exactly as released in v1.0 (hamming written out).
L = length(data);
NFFT = Fs/0.5;
data = data - mean(data);
n = 0:L-1;
data = data .* (0.54 - 0.46*cos(2*pi*n/(L-1)));
X = fft(data, NFFT)/L;
freqs = Fs/2*linspace(0, 1, NFFT/2+1);
spectra = abs(X(1:NFFT/2+1));
end
