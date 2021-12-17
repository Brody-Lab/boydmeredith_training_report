function [settings, the_datenum] = loadNewestSettings(ratname,datenum_in)
settings = [];
the_datenum = [];

max_depth = 1;
if nargin < 2
    datenum_in = today;
    max_depth = 20;
elseif isstr(datenum_in)
    datenum_in = datenum(datenum_in);
end



settings_dir = '/Volumes/brody/RATTER/SoloData/Settings/';
if ~exist(settings_dir,'dir')
    error('can''t find ratter. is brody drive mounted?')
end

exptr = 'Tyler';
files = [];
ii=0;
while isempty(files) & ii < max_depth
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
if isempty(datenum_in)
    [the_datenum, date_ind] = max(date_list);
else
    date_list = datenum(datestr(date_list,29));
    [date_ind] = find(date_list==datenum_in);
    date_ind = date_ind(end);
    the_datenum = datenum_in;
end

settings = load(fullfile(files(date_ind).folder,files(date_ind).name));

