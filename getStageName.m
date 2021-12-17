function [settings, stageName, theDate, endStageName, nStages, prot,...
    start_t, end_t] = getStageName(ratname,the_date)


stageName = [];
endStageName = [];
nStages = [];
prot = [];
start_t = [];
end_t = [];

if nargin < 2 || isempty(the_date)
    [settings, theDate] = loadNewestSettings(ratname);
else
    [settings, theDate] = loadNewestSettings(ratname,the_date);
end

if isempty(settings)
    return
end

[stageName, endStageName, nStages, prot, start_t, end_t]...
    = getActiveStageName(settings);

theDate = datenum(datestr(theDate,29));
