function plot_training_stages(ratname, start_date, varargin)
[stagenums, datenums] = get_training_stages(ratname, start_date);
first_date =  datenums(find(~isnan(datenums),1));
datex = datenums - first_date;

%%
figure(1); clf
 ax = axes;
plot(ax,datex(~isnan(datex)), stagenums(~isnan(datex)), 'k:', 'linewidth', 1.75)
hold(ax,'on')
plot(ax,datex, stagenums, 'k-', 'linewidth', 2)

ylabel(ax,'training stage # at beginning of session')   
start_datestr = datestr(first_date,'mm-dd-yy');
xlabel(ax,sprintf('days from %s',start_datestr))

set(ax, 'ytick', [0:20], 'ylim', [min(stagenums) max(stagenums)]+[-.25 .25])
title(sprintf('%s', ratname))
