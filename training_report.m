function training_report(ratnames)
% function training_report()
%
% 

if isempty(bdata)
    bdata('connect')
end

fig_path = '~/projects/rat_training';

if nargin < 1 | isempty(ratnames)
    ratnames = get_ratnames;
end

ndays_to_check = 10;
ndays_to_plot = 7;
check_date = datestr(today,29);

print_training_report(ratnames, check_date, ndays_to_check);
fh = print_active_rats_psychometrics(ratnames, ndays_to_plot);


