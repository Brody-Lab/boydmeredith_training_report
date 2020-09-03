function [fh res] = plot_training_report(ratnames, startDate, endDate, fh)

if nargin < 1 || isempty(ratnames)
    [ratnames, experimenter] = get_ratnames;
elseif ischar(ratnames)
    ratnames = {ratnames};
end
if nargin < 2 | isempty(startDate),
    startDate = datestr(today-25,29);
else   
    startDate = datestr(startDate,29);
end

if nargin < 3 | isempty(endDate)
    endDate = datestr(today+1,29);
else   
    endDate = datestr(endDate,29);
end

if nargin < 4 | isempty(fh)
    fh = uifigure();
end

if ~iscell(ratnames)
    ratnames = {ratnames};
end



%set(0, 'defaultaxeslinewidth', 1.5, 'defaultlinelinewidth', 1.5, 'defaultaxesfontsize', 15)
%set(fh, 'position',[27 0 20 15], 'color', 'w');

ploty = 2;
plotx = 2;

markers = {'o', 'x', '<', '>', '+', '*', 's', 'd', '^', 'p', 'h'};
clrset  = {[.75 0 0], [0 .75 0], [0 0 .75], [.75 0 .75], [.75 .75 0]};
lw      = 1;

pos = [1000 100 900 800];
fh.Units = 'pixels';
fh.Position = pos;
w = (pos(3) - 100) / 2 * .9;
h = pos(4) / 2 * .9;
xoff = pos(3) / 4 * .1;
yoff = pos(4) / 4 * .1;
s(1) = uiaxes('Parent',fh,'BackgroundColor','w','position',[xoff yoff w h]);%subplot(ploty,plotx,1);
s(2) = uiaxes('BackgroundColor','w','Parent',fh,'position',[w+2*xoff yoff w h]);%subplot(ploty,plotx,1);
s(3) = uiaxes('BackgroundColor','w','Parent',fh,'position',[xoff h+2*yoff w h]);%subplot(ploty,plotx,1);
s(4) = uiaxes('BackgroundColor','w','Parent',fh,'position',[w+2*xoff h+2*yoff w h]);%subplot(ploty,plotx,1);
hold(s(1),'on');hold(s(2),'on');hold(s(3),'on');hold(s(4),'on');
bgpos = [pos(3) - 120 100 100 .8*h] ;
bg = uibuttongroup('Parent',fh,'Position',  bgpos );



for rr = 1:length(ratnames)
res = get_perf_summary(ratnames{rr}, startDate, endDate);
res_all{rr} = res;

mm = mod(rr-1,length(markers))+1;
cc = mod(rr-1,length(clrset))+1;

linestr = [markers{mm} '-'];
xstr = sprintf('sessions from %s', datestr(today,29));

if ~isempty(res.n_total_trials)
% plot the trial counts
datesx = res.dates - today;
%plot(datesx, res.n_total_trials,'.-');
plh(1,rr) = plot(s(1),datesx, res.n_total_trials,linestr,...
    'linewidth',lw, 'color', clrset{cc},'markerfacecolor','w');

%plot(datesx, res.frac_hit.*res.n_valid_trials, '.-');
%plot(xlim,[200 200],'-k');
%legend('all','valid','correct','location','eastoutside');
ylabel(s(1),'# trials');
xlabel(s(1),xstr);
set(s(1),'ygrid','on')
%ylim([0 700]);


% plot the performance
goodsess = res.n_total_trials>0;
xx = datesx(goodsess);
yy =res.frac_hit(goodsess);
plh(2,rr) = plot(s(2),xx,yy,linestr,'linewidth',lw, 'color', clrset{cc},...
    'markerfacecolor','w');

%legend('hit frac','viol','correct','location','eastoutside');
ylabel(s(2),'% correct');
xlabel(s(2),xstr);
set(s(2),'ygrid', 'on');
ylim(s(2),[0 1]);
box(s(2),'off')
text(s(2),1,yy(end),ratnames{rr});



% plot the performance
plh(3,rr) = plot(s(3),datesx(goodsess), res.frac_viol(goodsess),linestr,...
    'linewidth',lw, 'color', clrset{cc},'markerfacecolor','w');
%splot(xlim,[.5 .5],'-k');
%legend('hit frac','viol','correct','location','eastoutside');
ylabel(s(3),'% violations');
xlabel(s(3),xstr);
set(s(3),'ygrid', 'on');
ylim(s(3),[0 1]);
box(s(3),'off')

% plot the performance
plh(4,rr) = plot(s(4),datesx(goodsess), res.rbias(goodsess),linestr,...
    'linewidth',lw, 'color', clrset{cc},'markerfacecolor','w');
ylabel(s(4),'bias (r-l)');
%legend('bias','location','eastoutside')
xlabel(s(4),xstr);
set(s(4),'ygrid', 'on');
ylim(s(4),'auto');
box(s(4), 'off')

else
    
    plh(1,rr) =  plot(s(1),0, 0,'m:','linewidth',lw);
    plh(2,rr) =  plot(s(2),0, 0,'m:','linewidth',lw);
    plh(3,rr) =  plot(s(3),0, 0,'m:','linewidth',lw);
    plh(4,rr) =  plot(s(4),0, 0,'m:','linewidth',lw);
end
cbxpos = [5 bgpos(4)-(rr+1)*(bgpos(4)/(length(ratnames)+1)) 100 20 ];
% rb(rr) = uiradiobutton(bg,'Position',rbpos,'Value',1,'ValueChangedFcn',...
%     @(rb,event) rb_changed(rb,rr));
cbx(rr) = uicheckbox(bg,'Position',cbxpos,'Value',1,'Text',ratnames{rr},...
    'ValueChangedFcn', @(rb,event) cbx_changed(rb,plh(:,rr)));
%suptitle(ratname);
end

%%
rb_all = uicheckbox('Parent',fh,'Text','Select All',...
'Position',  [bgpos(1) 10 bgpos(3) 50],'Value',1, ...
'ValueChangedFcn', @(rb,event) rb_changed(rb,cbx,plh));

%%
s4pos = [w+2*xoff h+2*yoff w h];
hl = legend(s(4),ratnames,'location','eastoutside')
set(hl,'units','pixels')
hlpos = get(hl,'Position')
%set(s(4),'Position',s4pos+[0 0 hlpos(3)+hlpos 0])
%drawnow
%%
plot(s(2),get(s(2),'xlim'),[.5 .5],'-k');
plot(s(4),get(s(4),'xlim'),[0 0],'-k');

%linkaxes(s,'x')
% 
function rb_changed(rb,cbx,plh)
    val = rb.Value;
    for ii = 1:length(cbx)
        %if cbx(ii).Value == 0;
            cbx(ii).Value = val;
            cbx_changed(cbx(ii),plh(:,ii));
        %end
    end
    
    %     if val == 1
%         for cc=1:length(cbx)
%             cbx(cc).Value = 1;
%         end
%     end

function cbx_changed(rb, hh)
val = rb.Value;
if val
    str = 'on';
else
    str = 'off';
    
end
for ii = 1:numel(hh)
    hh(ii).Visible = str;
end




