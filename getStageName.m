function [settings, stageName, theDate, endStageName, nStages, prot,...
    start_t, end_t] = getStageName(ratname,the_date,ndays,varargin)
p = inputParser();
addParameter(p, 'settings_filename',[])
parse(p,varargin{:});

if nargin<3
    ndays = 1;
end

stageName = [];
endStageName = [];
nStages = [];
prot = [];
start_t = [];
end_t = [];

if ~isempty(p.Results.settings_filename)
    fpath = p.Results.settings_filename;
    settings = load(fpath, 'saved');
    prot     = regexp(fpath, '(?<=@)[^_]+(?=_)', 'match');
elseif nargin < 2 || isempty(the_date)
    [settings, theDate, prot] = loadNewestSettings(ratname,[],ndays);
else
    [settings, theDate, prot] = loadNewestSettings(ratname,the_date,ndays);
end

if isempty(settings)
    return
end

[activeStageName, activeStagenum, finalStageName, nStages, prot, start_t, end_t]...
    = getActiveStageName(settings);

theDate = datenum(datestr(theDate,29));
