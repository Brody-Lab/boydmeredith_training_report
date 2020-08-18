function [settings, the_datenum] = loadNewestSettings(ratname,datenum_in)

if nargin < 2
    datenum_in = [];
end

files = dir(sprintf('/Volumes/brody/RATTER/SoloData/Settings/*/%s/settings_*',...
    ratname));

date_list = [files.datenum];
if isempty(datenum_in)
    [the_datenum, date_ind] = max(date_list);
else
    date_list = datenum(datestr(date_list,29));
    [date_ind] = find(date_list==datenum_in);
    date_ind = date_ind(end);
end

settings = load(fullfile(files(date_ind).folder,files(date_ind).name));

