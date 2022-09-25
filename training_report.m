function res = training_report(ndays)
% function res = training_report(ratnames, startDate, endDate, fh)
%
% 

if isempty(bdata)
    bdata('connect')
end

fig_path = '~/projects/rat_training';

fh = figure(1); clf

if nargin < 1 | isempty(ratnames)
    ratnames = get_ratnames;
end

%[fh res] = plot_training_report(ratnames, startDate, endDate, fh)
ndays_to_check = 10;
print_training_report(ratnames, endDate, ndays_to_check);
ndays_to_plot = 7;
print_active_rats_psychometrics(ratnames, ndays_to_plot);


