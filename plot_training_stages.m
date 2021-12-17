function plot_training_stages(ratname, start_date, varargin)
p = inputParser;
addParameter(p, 'fignum', 1);
addParameter(p, 'protocols', {'ProAnti3', 'PBups', 'PBupsWT', []});
addParameter(p, 'list_stages', 0);
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

fh = figure(fn); clf
set(fh, 'position', [2,7, 9, 4])

if par.list_stages
    ax = subplot(1,5,1:4);
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
title(sprintf('%s', ratname))
box(ax,'off')

not_nan = find(~isnan(res.protnums));
not_nan_prot_changes = find(diff(res.protnums(not_nan))~=0);
pre_changes = not_nan(not_nan_prot_changes);
post_changes = not_nan(not_nan_prot_changes+1);
res.prots(pre_changes);
res.prots(post_changes);
plot(datex(pre_changes).*[1 1], ylim,'color',[1 1 1].*.5,'linewidth',2)
%ismember(res.prots, protocols)
%cellfun(protocols)


