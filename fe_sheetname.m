function s = fe_sheetname(name)
% FE_SHEETNAME Excel-safe sheet name: drops the file extension and the
% characters Excel forbids, and truncates to 31 characters.
[~, s] = fileparts(char(name));
s = regexprep(s, '[\[\]:*?/\\]', '_');
if isempty(s), s = 'Sheet'; end
s = s(1:min(end, 31));
end
