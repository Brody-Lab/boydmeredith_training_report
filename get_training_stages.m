function res = get_training_stages(ratname, start_date, varargin)
% function res = get_training_stages(ratname, start_date, varargin) Gets a
%
% Get a list of training stage name, number and protocol for every day from
% start_date to now for subject ratname. In addition, a list of optional
% settings variables can be added to results file. 
%
% res = get_training_stages({'Z255' 'Z256'},
% '2016-12-11','end_date','2017-12-11'); 
% 
% plot_training_stages(res);
%

% If ratname is a cell, loop over the rats
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
addParameter(p, 'experimenter', '*'); % you can save a few seconds per rat by specifying which experimenter
addParameter(p, 'savename', '');
addParameter(p, 'reload', 1);
addParameter(p, 'overwrite', 0);
addParameter(p, 'protocols', []);
addParameter(p, 'update', 0);
addParameter(p, 'config_optset', 'pbups')
parse(p,varargin{:})
par = p.Results;

% get configuration parameters
tr = train_report_config(par.config_optset);
if isempty(par.protocols)
    par.protocols = tr.protocols;
end

% set path where results should be saved
savename = p.Results.savename;
if isempty(savename) 
    savename = [ratname '_stages.mat']; 
end
savepath = fullfile(tr.datasavedir, savename);

if par.overwrite || par.update
    bdata_connect()
end

% check to see if this file alreay exists and decide whether to return it
if exist(savepath, 'file') && ~par.overwrite
    fprintf('\nLoading saved training stages file for %s',ratname);
    load(savepath,'res')
    if par.update
        lastday = datestr(max(res(1).datenums),29);
        newsess = bdata(['select sessid from sessions where ' ...
            'ratname="{S}" and sessiondate>"{S}"'], ratname, lastday);
        do_update = ~isempty(newsess);
    end
    if par.update && do_update
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
settings_basedir = fullfile(tr.brodydir,'RATTER/SoloData/Settings/');
data_basedir = fullfile(tr.brodydir,'RATTER/SoloData/Data/');
if ~exist(settings_basedir,'dir')
    error(['Can''t find ratter. is brody drive mounted? ' ...
        'Does train_report_config.m contain the right reference to brodydir?'])
end
settings_dir = fullfile(settings_basedir, par.experimenter, ratname);
data_dir = fullfile(data_basedir, par.experimenter, ratname);

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

% build list of data files
fprintf(['\nhold on to your hat while we look through all '...
    'the settings files for %s '],ratname)
if ~isempty(start_date)
    fprintf( 'between %s and %s.\n', start_date, end_date)
end
tic
files = dir(fullfile(data_dir, 'data_*mat'));
toc

file_datelett = cellfun(@(x) get_file_dateletter(x), {files.name},'uniformoutput',0);
file_dateiso = cellfun(@(x) get_file_dateiso(x), file_datelett, 'uniformoutput', 0);
file_datenum = datenum(file_dateiso);
file_lett = cellfun(@(x) x(end), file_datelett, 'uniformoutput', 0);
file_prot = cellfun(@(x) get_file_protocol(x), {files.name});

% figure out which files are from the appropriate date range and protocol
if isempty(start_datenum) 
    start_datenum = min(file_datenum);
end
start_date = datestr(start_datenum,29);

if isempty(end_datenum)
    end_datenum = max(file_datenum);
end
end_date = datestr(end_datenum,29);

if ~isempty(par.protocols)
    good_prot = ismember(file_prot, par.protocols);
else
    good_prot = true(size(file_prot));
end
good_dates = (file_datenum >= start_datenum) & (file_datenum <= end_datenum);
good_files = good_dates(:) & good_prot(:);
unique_datenums = unique(file_datenum(good_files));
unique_protocols = unique(file_prot(good_files));

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
optfields   = tr.settings_fields_names;
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
    thisidx = find(file_datenum == this_date);
    % grab file with largest final character (e.g. 161112b not 161112a)
    [~, maxidx] = max([file_lett{thisidx}]);
    thisidx = thisidx(maxidx);
    this_file = fullfile(files(thisidx).folder, files(thisidx).name);
    warning('off')
    data = load(this_file, 'saved');
    warning('on')
    prot = get_file_protocol(this_file);
    
    [stageName, stagenum, ~, nStages, ~, ~, ~] = getActiveStageName(data);
    
    if ~isempty(stageName)
        stageName = sprintf('%i %s',stagenum,stageName);
%         tempstagenum = regexp(stageName, '\d+','match'); if
%         ~isempty(tempstagenum)
%             stagenum = str2num(tempstagenum{1});
%         else
%             stagenum = 0; stageName = strcat('0 ',stageName);
%         end
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

res.ratname = ratname;
res.start_date = start_date;
res.end_date = end_date;
res.stagenums = stagenums;
res.stagenames = stagenames;
res.datenums = datenums;
res.prots = prots;
res.protnums = protnums;
save(savepath, 'res')

end

% convert the file list to dates in iso formats and the letter used to
% determine which file is used as the settings file
function datelett = get_file_dateletter(name)
    datelett = name(regexp(name, '\d\d\d\d\d\d\S.mat')+(0:6));
end

function dateiso = get_file_dateiso(datlett) 
    dateiso = sprintf('20%s-%s-%s', datlett(1:2), datlett(3:4), datlett(5:6));
end

function prot = get_file_protocol(name)
    prot = regexp(name, '(?<=@)[^_]+(?=_)', 'match');
end
