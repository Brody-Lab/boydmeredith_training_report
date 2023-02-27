function res = get_training_stages(ratname, start_date, varargin)
% function res = get_training_stages(ratname, start_date, varargin) Gets a
%
% Get a list of training stage name, number and protocol for every day from
% start_date to now for subject ratname
%
% res = get_training_stages('Z255', '2016-12-11','end_date','2017-12-11')
%
%

if iscell(ratname)
    for rr = 1:length(ratname)
        fprintf('\nWorking on rat %i of %i...\n',rr,length(ratname))
        tic
        res(rr) = get_training_stages(ratname{rr}, start_date, varargin{:});
        toc
    end
    return
end

% parse optional arguments
p = inputParser;
addParameter(p, 'end_date', [])
addParameter(p, 'protocols', {'ProAnti3', 'PBups', 'PBupsWT'})
addParameter(p, 'datadir', '~/projects/rat_training/data/');
addParameter(p, 'brodydir', '/Volumes/brody');
addParameter(p, 'experimenter', 'Tyler');
addParameter(p, 'savename', '');
addParameter(p, 'overwrite', 0);
addParameter(p, 'update', 0);
addParameter(p, 'settings_fields_names',...
    {'PenaltySection_LegalWaitBreak','LegalWaitBreak',...
    'PenaltySection_SignalWaitViol', 'SignalWaitViol',...
    'PenaltySection_TerminateWaitBreak','TerminateWaitBreak',...
    'DistribInterface_HitWaitDelay_Min','RewDelayMin',...
    'DistribInterface_HitWaitDelay_Tau','RewDelayTau',...
    'DistribInterface_HitWaitDelay_Max','RewDelayMax',...
    'DistribInterface_ErrorWaitDelay_Min','ErrDelayMin',...
    'DistribInterface_ErrorWaitDelay_Max','ErrDelayMax',...
    'SidesSection_CatchFreq','CatchFrac',...
    })
parse(p,varargin{:})
par = p.Results;
% set path where results should be saved
savename = p.Results.savename;
if isempty(savename)
    savename = [ratname '_stages.mat'];
end
savepath = fullfile(p.Results.datadir, savename);
fprintf('\nLooking for saved training stages file for %s',ratname);

% check to see if this file alreay exists
if exist(savepath, 'file') & ~p.Results.overwrite
    %% 
    load(savepath,'res')
    
    if par.update
        lastday = datestr(max(res(1).datenums),29);
        newsess = bdata(['select sessid from sessions where ' ...
            'ratname="{S}" and sessiondate>"{S}"'], ratname, lastday);
        do_update = ~isempty(newsess);
    end
    if par.update & do_update
        fprintf('\n updating file to cover %i new sessions\n',length(newsess))
    else
        if isempty(start_date) 
            fprintf('\nreturning existing file.\n');
            return
        elseif datenum(start_date) >= datenum(res.start_date)
            fprintf('\nexisting file contains this daterange. returning existing file.');
            return 
    else
       fprintf(['\nsexisting file doesn''t cover this daterange.\n'...
           'we should probably be careful about only getting the dates we don''t have '...
           'but instead we''ll just go ahead and recompute']);
        end 
    end
end

% check that settings files are accessible
settings_dir = fullfile(p.Results.brodydir,'RATTER/SoloData/Settings/');
if ~exist(settings_dir,'dir')
    error('can''t find ratter. is brody drive mounted?')
end
settings_dir = fullfile(settings_dir, p.Results.experimenter, ratname);

% set start_date. if not supplied, will load all dates for rat
start_datenum = [];
end_datenum = [];
if nargin < 2
    start_date = [];
end
if ~isempty(start_date)
    start_datenum = datenum(start_date);
end

% set end_date
end_date = p.Results.end_date;
if ~isempty(end_datenum)
    end_datenum = datenum(end_date);
end

% build list of settings files
fprintf(['\nhold on to your hat while we look through all '...
    'the settings files for %s '],ratname)
if ~isempty(start_date)
    fprintf( 'between %s and %s.\n', start_date, end_date)
end

%% get list of all files in settings dir
files = dir(fullfile(settings_dir, 'settings*'));

% convert the file list to dates in iso formats and the letter used to
% determine which file is used as the settings file
get_settings_dateletter = @(name) name(regexp(name, '\d\d\d\d\d\d\S.mat')+(0:6));
get_settings_dateiso = @(datlett) sprintf('20%s-%s-%s', datlett(1:2), datlett(3:4), datlett(5:6));
get_settings_protocol = @(name) regexp(name, '(?<=@)[^_]+(?=_)', 'match');

settings_datelett = cellfun(@(x) get_settings_dateletter(x), {files.name},'uniformoutput',0);
settings_dateiso = cellfun(@(x) get_settings_dateiso(x), settings_datelett, 'uniformoutput', 0);
settings_datenum = datenum(settings_dateiso);
settings_lett = cellfun(@(x) x(end), settings_datelett, 'uniformoutput', 0);
settings_prot = cellfun(@(x) get_settings_protocol(x), {files.name});

% figure out which files are from the appropriate date range and protocol
if isempty(start_datenum) 
    start_datenum = min(settings_datenum);
end
start_date = datestr(start_datenum,29);

if isempty(end_datenum)
    end_datenum = max(settings_datenum);
end
end_date = datestr(end_datenum,29);

if ~isempty(p.Results.protocols)
    good_prot = ismember(settings_prot, p.Results.protocols);
else
    good_prot = true(size(settings_prot));
end
good_dates = (settings_datenum >= start_datenum) & (settings_datenum <= end_datenum);
good_files = good_dates(:) & good_prot(:);
unique_datenums = unique(settings_datenum(good_files));
unique_protocols = unique(settings_prot(good_files));

% initialize variables to store outputs
res         = [];
ndays       = end_datenum - start_datenum + 1;
datenums    = nan(ndays,1);
stagenums   = nan(ndays,1);
maxstages   = nan(ndays,1);
stagenames  = cell(ndays,1);
prots       = cell(ndays,1);
protnums    = nan(ndays,1);
% initialize optional fields
optfields   = par.settings_fields_names;
for ff = 1:2:length(optfields)
    res.(optfields{ff+1}) = nan(ndays,1);
end

% look at all settings files and save
datei = unique_datenums-start_datenum + 1;
fprintf('\nworking through %i dates\n',length(unique_datenums));

for dd = 1:length(unique_datenums)
    if mod(dd,10)==0
        fprintf('%i...',dd);
    end    
    this_date = unique_datenums(dd);
    di = datei(dd);
    thisidx = find(settings_datenum == this_date);
    % grab file with largest final character (e.g. 161112b not 161112a)
    [~, maxidx] = max([settings_lett{thisidx}]);
    thisidx = thisidx(maxidx);
    this_file = fullfile(files(thisidx).folder, files(thisidx).name);
    settings = load(this_file, 'saved');
    prot = get_settings_protocol(this_file);
    
    [stageName, endStageName, nStages, ~, start_t, end_t]...
        = getActiveStageName(settings);
    if ~isempty(stageName)
        tempstagenum = regexp(stageName, '\d+','match');
        if ~isempty(tempstagenum)
            stagenum = str2num(tempstagenum{1});
        else
            stagenum = 0;
            stageName = strcat('0 ',stageName);
        end
    else
        stageName = 'undefined';
        stagenum = -1;
    end
    protnums(di) = find(ismember(unique_protocols,prot));
    prots{di} = prot{1};
    datenums(di) = this_date;
    stagenames{di} = stageName;
    stagenums(di) = stagenum;
    maxstages(di) = nStages;
    
    % fill in optional fields
    for ff = 1:2:length(optfields)
        if isfield(settings.saved, optfields{ff})
            res.(optfields{ff+1})(di)  = settings.saved.(optfields{ff});
        else 
            res.(optfields{ff+1})(di) = nan;
        end
    end

end

res.start_date = start_date;
res.end_date = end_date;
res.stagenums = stagenums;
res.stagenames = stagenames;
res.datenums = datenums;
res.prots = prots;
res.protnums = protnums;
save(savepath, 'res')
