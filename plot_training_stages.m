function plot_training_stages(ratname, start_date, varargin)
p = inputParser;
addParameter(p, 'fignum', 1);
addParameter(p, 'protocols', {'ProAnti3', 'PBups', 'PBupsWT', []});
addParameter(p, 'list_stages', 1);
parse(p, varargin{:});
par = p.Results;
fn = par.fignum;
protocols = par.protocols;

if nargin < 2
    start_date = [];
end

if iscell(ratname)
    nrats = length(ratname);
    for rr = 1:nrats
        this_ratname = ratname{rr};
        plot_training_stages(this_ratname, start_date, ...
            'fignum',rr,varargin{:});
    end
    return
end

res = get_training_stages(ratname, start_date);
stagenums = res.stagenums;
datenums = res.datenums;

first_date =  datenums(find(~isnan(datenums),1));
datex = datenums - first_date;
%%
fh = figure(fn); clf
set(fh, 'position', [12,7, 9, 4])

if par.list_stages
    ax = subplot(1,5,1:4);
    axpos = get(ax,'position');
else
    ax = axes;
end
plot(ax,datex(~isnan(datex)), stagenums(~isnan(datex)), 'k:', 'linewidth', 1.75)
hold(ax,'on')
plot(ax,datex, stagenums, 'k-', 'linewidth', 2)

ylabel(ax,'training stage # at beginning of session')   
start_datestr = datestr(first_date,'mm-dd-yy');
xlabel(ax,sprintf('days from %s',start_datestr))

set(ax, 'ytick', [0:20], 'ylim', [min(stagenums) max(stagenums)]+[-.25 .25])
title(ax,sprintf('%s', ratname))
box(ax,'off')

not_nan = find(~isnan(res.protnums));
not_nan_prot_changes = find(diff(res.protnums(not_nan))~=0);
pre_changes = not_nan(not_nan_prot_changes);
post_changes = not_nan(not_nan_prot_changes+1);

plot(ax,repmat(datex(pre_changes),1,2)', ...
    ylim,'color',[1 .65 .85],'linewidth',2)
%%
datenums_nonans = datenums(1) + (0:length(datenums)-1);
newmonth = find(day(datenums_nonans)==1);
temp = month(datenums_nonans(newmonth));
monthnames = string(datestr(datenums_nonans(newmonth),'mmm'))

%%
xt=2:2:length(monthnames)
monthnames(xt)
%%
set(ax,'XMinorTick','on','xtick',newmonth(xt),'xticklabel',monthnames(xt))
ax.XAxis.MinorTickValues=newmonth;

%set(ax,'xtick','xtick',[0:30:
%ismember(res.prots, protocols)
%cellfun(protocols)
%%
pre_prots = res.prots(pre_changes)
post_prots = res.prots(post_changes)

%%
if par.list_stages
unique_prots = unique(res.protnums(~isnan(res.protnums)));
inc = 0;
text_inc = -1;
for pp = 1:length(unique_prots)
    this_prot = res.protnums == unique_prots(pp);
    this_protname = res.prots(find(this_prot,1));

    unique_stages = unique(res.stagenums(this_prot));
    text(ax,max(get(ax,'xlim'))*1.05, max(get(ax,'ylim')) - text_inc*.5,...
        sprintf('--- %s ---',this_protname{1}));
    for ss = 1:length(unique_stages);
        text_inc = text_inc+1;
        inc = inc + 1;
        this_stage = unique_stages(ss);
        
        this_stagename = res.stagenames{find(this_prot & ...
            res.stagenums==this_stage,1)};
        stagenames{inc} = this_stagename;
        text(ax,max(get(ax,'xlim'))*1.05, max(get(ax,'ylim')) - text_inc*.5, this_stagename);
    end
    text_inc = text_inc+1;
end

end

