function [stagenums, datenums] = get_training_stages(ratname, start_date, varargin)

% build file list 
settings_dir = '/Volumes/brody/RATTER/SoloData/Settings/';
if ~exist(settings_dir,'dir')
    error('can''t find ratter. is brody drive mounted?')
end
end_datenum = today;

start_datenum = datenum(start_date);
ndays = end_datenum - start_datenum + 1;
the_date  = start_datenum;
datenums = nan(ndays,1);
stagenums = nan(ndays,1);
maxstages = nan(ndays,1);
prots = cell(ndays,1);

for dd = 1:ndays
    if mod(dd,10)==1,
        fprintf('\nworking on day %i of %i\n', dd, ndays);
    end
    [settings, stageName, ~, endStageName, nStages, prot,...
    start_t, end_t] = getStageName(ratname,the_date);
    the_date = the_date + 1;
    if ~isempty(settings)
        temp = regexp(stageName, '\d+','match');
        stagenum = str2num(temp{1});
        stagenums(dd) = stagenum;
        temp = regexp(stageName, '\d+','match');
        stagemax = str2num(temp{1});
        maxstages(dd) = stagemax;
        datenums(dd) = the_date;
        prots{dd} = prot;
    end
    
end
    

    
    
