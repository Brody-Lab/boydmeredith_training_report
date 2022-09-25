function print_wt_settings_summary(ratnames, date_in, ndays)

if nargin < 1 || isempty(ratnames)
    [ratnames, experimenter] = get_ratnames;
elseif ischar(ratnames)
    ratnames = {ratnames};
end

if nargin < 2 || isempty(date_in)
    date_in = [];
    date_in = today;
else
    date_in = datenum(datestr(date_in,29));
end

if nargin < 3
    ndays = 14;
end

fprintf('rat  Catch\n')
format_str = '%s %.2f\n';
for rr = 1:length(ratnames)
    %try
    [settings, stageName, the_date, endStageName, nStages, prot, start_t, end_t]=...
        getStageName(ratnames{rr},[],ndays);
    
    if isempty(settings)
        continue
    end
    
    catch_frac = 0;    
    if strncmp(prot, 'PBupsWT',7)
        catch_frac = settings.saved.SidesSection_CatchFreq;
    
        if the_date > today-1000
            fprintf(format_str,ratnames{rr}, catch_frac)
        end
    end
    
end