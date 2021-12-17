function res = get_training_stages(ratname, start_date, varargin)
p = inputParser;
addParameter(p, 'protocols', {'ProAnti3', 'PBups', 'PBupsWT'})
parse(p,varargin{:})

end_datenum = today;

if isempty(start_date)
   sessdates = bdata(['select sessiondate from sessions'...
       ' where ratname="{S}"'], ratname);
   if isempty(sessdates)
       return;
   end
   start_date = sessdates{1};
   end_datenum = datenum(sessdates{end});

end
end_date = datestr(end_datenum,29);

savedir = '~/projects/rat_training/';
savepath = fullfile(savedir, [ratname '_stages.mat']);
if exist(savepath, 'file')
    start_date_in = start_date;
    load(savepath)
    start_date = res.start_date;
    if datenum(start_date_in) == datenum(start_date)
        return;
    end
end

% build file list 
settings_dir = '/Volumes/brody/RATTER/SoloData/Settings/';
if ~exist(settings_dir,'dir')
    error('can''t find ratter. is brody drive mounted?')
end


start_datenum = datenum(start_date);
ndays = end_datenum - start_datenum + 1;
the_date  = start_datenum;
datenums = nan(ndays,1);
stagenums = nan(ndays,1);
maxstages = nan(ndays,1);
stagenames = cell(ndays,1);
prots = cell(ndays,1);
protnums = nan(ndays,1);

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
        prot = strjoin(regexp(prot, '\w', 'match'),'');
        prots{dd} = prot;
        protnums(dd) = find(ismember(p.Results.protocols,prot));
        stagenames{dd} = stageName;
    else
        prots{dd} = '';
    end
    
end
res.start_date = start_date;
res.stagenums = stagenums;
res.stagenames = stagenames;
res.datenums = datenums;
res.prots = prots;
res.protnums = protnums;
save(savepath, 'res')
