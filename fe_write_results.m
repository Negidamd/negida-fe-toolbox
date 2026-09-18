function summary = fe_write_results(R, subjName, outDir, sel)
% FE_WRITE_RESULTS Write fe_extract results for one subject to Excel files.
%
%   summary = fe_write_results(R, subjName, outDir, sel)
%
%   R         output of fe_extract
%   subjName  subject identifier (used as the sheet name)
%   outDir    output folder
%   sel       struct of logical flags: DF, DFV, DFP, RelativePow,
%             PerChannel, PerEpoch (missing fields default to false)
%
%   Each selected output goes to its own workbook, one sheet per subject.
%   Existing sheets with the same name are overwritten, not merged.
%   Returns a per-channel summary table (subject, channel, mean DF, DFV,
%   IAF) that the caller can stack across subjects.

flags = {'DF', 'DFV', 'DFP', 'RelativePow', 'PerChannel', 'PerEpoch'};
for k = 1:numel(flags)
    if ~isfield(sel, flags{k}), sel.(flags{k}) = false; end
end

sheet = fe_sheetname(subjName);
rows = R.chanlabels;
bandVars = matlab.lang.makeValidName(R.bandNames);

if sel.DF
    epochVars = arrayfun(@(e) sprintf('Epoch%d', e), 1:R.nEpochs, 'UniformOutput', false);
    T = array2table(R.DF, 'RowNames', rows, 'VariableNames', epochVars);
    writeSheet(T, fullfile(outDir, 'EEG_Results_DF_forallEpochandChannel.xlsx'), sheet);
end
if sel.DFV
    T = array2table([R.DFV, R.DFV_overall], 'RowNames', rows, ...
        'VariableNames', [bandVars, {'Overall'}]);
    writeSheet(T, fullfile(outDir, 'EEG_Results_DFV_Toolbox.xlsx'), sheet);
end
if sel.DFP
    T = array2table(round(R.DFP, 2), 'RowNames', rows, 'VariableNames', [bandVars, {'Other'}]);
    writeSheet(T, fullfile(outDir, 'EEG_Results_DFP_Toolbox.xlsx'), sheet);
end
if sel.RelativePow
    T = array2table(round(R.RelPow, 2), 'RowNames', rows, 'VariableNames', bandVars);
    writeSheet(T, fullfile(outDir, 'EEG_Results_RelativePow_Toolbox.xlsx'), sheet);
end
if sel.PerChannel
    T = array2table(mean(R.DF, 2), 'RowNames', rows, 'VariableNames', {'MeanDF'});
    writeSheet(T, fullfile(outDir, 'EEG_Results_DF_PerChannel.xlsx'), sheet);
end
if sel.PerEpoch
    epochVars = arrayfun(@(e) sprintf('Epoch%d', e), 1:R.nEpochs, 'UniformOutput', false);
    T = array2table(mean(R.DF, 1), 'RowNames', {'MeanAcrossChannels'}, 'VariableNames', epochVars);
    writeSheet(T, fullfile(outDir, 'EEG_Results_DF_PerEpoch.xlsx'), sheet);
end

n = R.nbchan;
summary = table(repmat({char(subjName)}, n, 1), rows(:), repmat(R.nEpochs, n, 1), ...
    mean(R.DF, 2), R.DFV_overall, R.IAF_peak, R.IAF_cog, ...
    'VariableNames', {'Subject', 'Channel', 'nEpochs', 'MeanDF', 'DFV', 'IAF_peak', 'IAF_cog'});
end

function writeSheet(T, file, sheet)
writetable(T, file, 'WriteRowNames', true, 'Sheet', sheet, 'WriteMode', 'overwritesheet');
end
