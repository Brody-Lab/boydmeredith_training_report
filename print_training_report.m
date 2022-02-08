function print_training_report(ratnames, date_in, ndays)

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

sprintf('rat  prot\t\b\bday/hr\t nic  [tmin-tmax] lcb\teasy/hard  vol  rate\tnvalid(ntotal)\t perf(rbias)viol\trig\tmax/stage  ')
format_str = '%s %s\t\b%i/%1.2f\t %.2f [%.1f-%.1f] %.3f\t %.1f/%.1f   %.2f  %i \t  %03i(%03i)\t   %2.f (%2.f) %2.f    \t%s\t%02i/%s\n';
for rr = 1:length(ratnames)
    %try
    [settings, stageName, the_date, endStageName, nStages, prot, start_t, end_t]=...
        getStageName(ratnames{rr},[],ndays);
    
    if isempty(settings)
        continue
    end
    
    [sessid, n_done, sessdatestrs, ...
        perf, rightPerf, leftPerf, viol, hostname, prot_] = bdata(['select '...
        'sessid, n_done_trials, sessiondate, '...
        'total_correct, right_correct, left_correct, percent_violations, hostname, protocol '...
        'from sessions where '...
        'sessiondate="{S}" and ratname="{S}"'],...
        datestr(the_date,29),ratnames{rr});
    if isempty(n_done) 

        for ii = 1:ndays
            [sessid, n_done, sessdatestrs, ...
                perf, rightPerf, leftPerf, viol, hostname, prot_] = bdata(['select '...
                'sessid, n_done_trials, sessiondate, '...
                'total_correct, right_correct, left_correct, percent_violations, hostname, protocol '...
                'from sessions where '...
                'sessiondate="{S}" and ratname="{S}"'],...
                datestr(the_date-ii,29),ratnames{rr});
            if ~isempty(n_done)
                continue
            end
        end
        if isempty(n_done)
            n_done = nan;
            perf = nan;
            rightPerf =nan;
            leftPerf=nan;
            viol=nan;
            hostname='';
        end
        
    end
    if iscell(hostname)
        hostname = hostname{1}(4:5);
    end
    % deal with case where there are multiple sessions from the same day
    if length(sessid) > 1 
        %%
        frac_per    = n_done./sum(n_done);
        viol        = nansum(viol.*frac_per);
        perf        = nansum(perf.*frac_per);
        rightPerf   = nansum(rightPerf.*frac_per);
        leftPerf    = nansum(leftPerf.*frac_per);
        n_done      = nansum(n_done);
    end
            
    
    n_valid = round(n_done.*(1-viol));

    %prot = prot{1};
    
    vol = nan; rate = nan; rbias = nan; hard_gamma = nan; easy_gamma = nan; rat = nan; t_min = nan; t_max = nan;
    rbias       = rightPerf - leftPerf;
    
    
    
    if strfind(prot,'PBups')
        vol = settings.saved.PBupsSection_vol;
        hard_gamma = settings.saved.PBupsSection_hardest;
        easy_gamma = settings.saved.PBupsSection_easiest;
        rate       = settings.saved.PBupsSection_total_rate;
        t_min       = settings.saved.PBupsSection_T_min;
        t_max       = settings.saved.PBupsSection_T_max;
        bups_type   = settings.saved.PBupsSection_task_type;
        
        if strncmp(prot, 'PBupsWT',7)
            nic_dur = settings.saved.StimulusSection_NICDur;
            lcb = settings.saved.StimulusSection_LegalCBreak;
        else
            nic_dur = settings.saved.StimulusSection_nose_in_center;
            lcb = settings.saved.StimulusSection_legal_cbreak;
        end
        
        if bups_type ==0
            prot = [prot 'F'];
        end
    elseif strncmp(prot,'ProAnti3',8)
        nic_dur = settings.saved.ProAnti3_NICDur;
        lcb     = settings.saved.ProAnti3_LegalCBrk;
    end
    
    if ~isempty(end_t)
        elapsed_t = (hour(end_t)-hour(start_t)) + (minute(end_t)-minute(start_t))/60;
    else
        elapsed_t = 0;
    end
    if the_date > today-1000
        %%
        fprintf(format_str,ratnames{rr},prot,...
            today-the_date, elapsed_t, nic_dur,t_min, t_max, lcb, ...
            easy_gamma, hard_gamma, vol, rate, n_valid(1), n_done, perf(1)*100, ...
            rbias(1)*100, viol(1)*100, hostname, nStages, stageName)
    end
    %     catch
    %         fprintf([ratnames{rr} ' didn''t work. did you mount the brody data?\n'])
    %     end
end