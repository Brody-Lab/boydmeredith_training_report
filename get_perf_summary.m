function res = get_perf_summary(ratname, startDate, endDate)

if nargin < 2 | isempty(startDate),
    startDate = datestr(today-50,29);
else 
    startDate = datestr(startDate,29);
end

if nargin < 3 | isempty(endDate),
    endDate = datestr(today+1,29);
else 
    endDate = datestr(endDate,29);
end

if isnumeric(startDate)
    datestr(startDate,29);
end

if isnumeric(endDate)
    datestr(endDate,29);
end



 [sessid, prot, perf, lperf, rperf, t, pv, dates] = bdata(...
     ['select sessid, protocol, total_correct, '...
    'left_correct, right_correct, n_done_trials, ' ...
    'percent_violations, sessiondate from sessions where ' ...
    'sessiondate>="{S}" and sessiondate<="{S}" and ratname="{S}"'],startDate,endDate,ratname);

if any(ismember(prot,'ProAnti3'))
    S = get_sessdata(sessid);
    for ss = 1:length(prot)
        if strcmp(prot(ss),'ProAnti3')
            pv(ss) = mean(S.pd{ss}.cpt > 0);
        end
    end
end
            

v = round(t .* pv);
n = t-v;

res.n_total_trials  = t;
res.n_valid_trials  = n;
res.n_viol          = v;
res.frac_viol       = pv;
res.frac_hit        = perf;
res.frac_lhit       = lperf;
res.frac_rhit       = rperf;
res.rbias           = rperf-lperf;
res.dates           = datenum(dates);




