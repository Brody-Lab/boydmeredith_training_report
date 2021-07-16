function res = training_report(ratnames, startDate, endDate, fh)

fig_path = '~/projects/rat_training';
set(0,'units','inches')
mp      = get(0, 'MonitorPositions');
max_x   = mp(1,1) + mp(1,3);

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
    ratnames = get_ratnames;
end

%[fh res] = plot_training_report(ratnames, startDate, endDate, fh)
print_training_report(ratnames, endDate);
%%
nrats = length(ratnames);
f = figure(1); clf
fw = 8.5;
fht = 11;
%fx = mp(1)+mp(1,3)/2-fw/2;
fx = sum(mp(1,[1 3])) - fw - 1;
set(f , 'position',   [fx 1  fw fht])
warning('off')
ndays = 7;
for rr = 1:nrats
    ax = subplot(4,ceil(nrats/4),rr);
    try
        plotPsychometricRat(ratnames{rr},...
            'daterange',ndays,'type','delta','ax',ax);
        drawnow
    catch
    end
end
warning('on')
print(f, fullfile(fig_path, ['rat_psycho_' datestr(today, 'mmddyy')]), '-dpng')

