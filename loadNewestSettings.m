function [settings, the_datenum, prot] = loadNewestSettings(ratname,datenum_in,ndays)
settings = [];
the_datenum = [];
prot = [];


if nargin < 2 | isempty(datenum_in)
    datenum_in = today;
elseif isstr(datenum_in)
    datenum_in = datenum(datenum_in);
end
if nargin < 3
    ndays = 1;
end
settings_dir = '/Volumes/brody/RATTER/SoloData/Settings/';
if ~exist(settings_dir,'dir')
    error('can''t find ratter. is brody drive mounted?')
end

exptr = 'Tyler';
files = [];
ii=0;
while isempty(files) & ii < ndays
    fpatt = sprintf(['%s/%s/'...
    'settings_*%s*'],...
    exptr, ratname, datestr(datenum_in-ii,'yymmdd'));
    files = dir(fullfile(settings_dir, fpatt));
    ii = ii + 1;
end

if isempty(files)
    return 
end

date_list = [files.datenum];
[the_datenum, date_ind] = max(date_list);
% if isempty(datenum_in)
%     [the_datenum, date_ind] = max(date_list);
% else
%     date_list = datenum(datestr(date_list,29));
%     [date_ind] = find(date_list==datenum_in);
%     if isempty(date_ind)
%         return
%     end
%     date_ind = date_ind(end);
%     the_datenum = datenum_in;
% end
%%
fname = files(date_ind).name;
fpath = fullfile(files(date_ind).folder,fname);
prot  =  regexp(fpath, '(?<=@)[^_]+(?=_)', 'match');
prot  = prot{1};
settings = load(fpath);

