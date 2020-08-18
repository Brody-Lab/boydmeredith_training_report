function res = training_report(ratnames, startDate, endDate, fh)

if nargin < 4
    fh = uifigure(1); clf
end
if nargin < 3
    endDate = [];
end 
if nargin < 2
    startDate = [];
end
if nargin < 1
    ratnames = [];
end

[fh res] = plot_training_report(ratnames, startDate, endDate, fh)
print_training_report(ratnames, endDate);