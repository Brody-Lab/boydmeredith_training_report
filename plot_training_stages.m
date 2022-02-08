function plot_training_stages(ratname, start_date, varargin)
% function plot_training_stages(ratname, start_date, varargin)
% plot the progression through training stages for a given rat (or group of
% rats) starting on a specified date
%
% EXAMPLE USAGE
% plot_training_stages({'Z255','Z258'}, '2016-11-21', ...
%       'protocols',  {'PBups', 'PBupsWT'}, 'experimenter', 'Tyler')
%
%
% NEW USERS should make sure to change the default arguments for
% experimenter, figsavedir, datasavedir


p = inputParser;
addParameter(p, 'ax', []);
addParameter(p, 'fignum', 1);
addParameter(p, 'protocols', []); % a list of protocols to include in plot e.g. {'ProAnti3','PBups'}
addParameter(p, 'end_date', []);
addParameter(p, 'list_stages', 1);
% NEW USERS CHANGE THESE DEFAULT ARGUMENTS
addParameter(p, 'experimenter','Tyler')
addParameter(p, 'figsavedir', '~/projects/rat_training/figures');
addParameter(p, 'datasavedir', '~/projects/rat_training/');
parse(p, varargin{:});
par = p.Results;
fn = par.fignum;
protocols = par.protocols;

if nargin < 2
    start_date = [];
end

% loop over rats if multiple
if iscell(ratname)
    nrats = length(ratname);
    for rr = 1:nrats
        this_ratname = ratname{rr};
        plot_training_stages(this_ratname, start_date, ...
            'fignum',rr,varargin{:});
    end
    return
end

% get training stages
par = p.Results;
res = get_training_stages(ratname, start_date, ...
    'experimenter', par.experimenter, 'protocols', par.protocols,...
    'end_date', par.end_date, 'savedir', par.datasavedir);

% find dates from file that should be plotted
stagenums = res.stagenums;
datenums = res.datenums;
end_date = max(datenums);
if ~isempty(start_date)
    first_datenum = datenum(start_date);
    firstgoodday = find(datenums>=first_datenum,1);
else
    firstgoodday = find(~isnan(datenums),1)
    first_datenum =  datenums(firstgoodday);
    start_date = first_datenum;
end
gooddateind = (1:length(datenums))' > firstgoodday;
datex = datenums - first_datenum;

% make plot layout
ax = par.ax;
if isempty(ax)
    fh = figure(par.fignum); clf
    set(fh,'position',[2 7 8 3.75],'units','inches')
    ax = axes('position',[.1 .2 .75 .7]);  
    
    if par.list_stages
        ax = subplot(1,5,1:4);
        axpos = get(ax,'position');
    else
        ax = axes;
    end
else
    fh = get(ax,'parent');
end
hold(ax,'on')
% draw stagenumber trace
plot(ax,datex(gooddateind&~isnan(datex)), stagenums(gooddateind&~isnan(datex)), 'k:', 'linewidth', 1.75)
hold(ax,'on')
plot(ax,datex(gooddateind), stagenums(gooddateind), 'k-', 'linewidth', 2)



% mark protocol change dates
not_nan = find(~isnan(res.protnums));
not_nan_prot_changes = find(diff(res.protnums(not_nan))~=0);
pre_changes = not_nan(not_nan_prot_changes);
post_changes = not_nan(not_nan_prot_changes+1);
days_to_mark = datex(pre_changes);
days_to_mark(days_to_mark<0) = [];
if ~isempty(days_to_mark)
    plot(ax,repmat(days_to_mark,1,2)', ...
    ylim,'color',[1 .65 .85],'linewidth',2)
end

% label axes and draw ticks and stuff
start_datestr = datestr(first_datenum,'mm-dd-yy');
xlabel(ax,sprintf('days from %s',start_datestr))
ylabel(ax,'stage # at session start')   
set(ax, 'ytick', [0:20], 'ylim', [min(stagenums) max(stagenums)]+[-.25 .25])
box(ax,'off')

ndays = max(datenums) - first_datenum;
datenums_nonans = first_datenum(1) + (0:ndays);
newmonth = find(day(datenums_nonans)==1);
temp = month(datenums_nonans(newmonth));
monthnames = string(datestr(datenums_nonans(newmonth),'mmm'))
xt=2:2:length(monthnames)
monthnames(xt)
set(ax,'XMinorTick','on','xtick',newmonth(xt),'xticklabel',monthnames(xt))
ax.XAxis.MinorTickValues=newmonth;
title_str = sprintf('%s (%s to %s)', ratname, ...
    datestr(start_date,'mmm yyyy'), datestr(end_date,'mmm yyyy'));
title(ax, title_str,'fontweight','normal')

pre_prots = res.prots(pre_changes)
post_prots = res.prots(post_changes)
axis tight
ylim([min([0,ylim]) max(ylim)])

% make a the list of stagenumers and names
if par.list_stages
unique_prots = unique(res.protnums(gooddateind & ~isnan(res.protnums)));
k = .45+.01*max(res.stagenums);
inc = 0;
text_inc = -max(res.stagenums)*.1;
for pp = 1:length(unique_prots)
    this_prot = res.protnums == unique_prots(pp);
    this_protname = res.prots(find(this_prot,1));
    unique_stages = unique(res.stagenums(gooddateind & this_prot));
    unique_stages = unique_stages(~isnan(unique_stages));
    text(ax,max(get(ax,'xlim'))*1.05, max(get(ax,'ylim')) - text_inc*k,...
        sprintf('--- %s stages ---',this_protname{1}));
    for ss = 1:length(unique_stages);
        text_inc = text_inc+1;
        inc = inc + 1;
        revprint = 0;
        if revprint
            this_stage = unique_stages(length(unique_stages)-ss+1);
        else
            this_stage = unique_stages(ss);
        end
        this_stagename = res.stagenames{find(this_prot & ...
            res.stagenums==this_stage,1)};
        stagenames{inc} = this_stagename;
        text(ax,max(get(ax,'xlim'))*1.05, max(get(ax,'ylim')) - text_inc*k, this_stagename);
    end
    text_inc = text_inc+1;
end

end

if ~isempty(par.figsavedir)
    fpos = get(fh,'position');
    set(fh,'paperpositionmode','auto','papersize',fpos(3:4)*1.25,'units','inches')
    figsavename = sprintf('%s_stages.pdf',ratname)
    print(fh, fullfile(par.figsavedir, figsavename), '-dpdf')
end
