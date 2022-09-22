function fh = print_active_rats_psychometrics(ratnames)
if nargin < 1
    ratnames = get_ratnames;
end

set(0,'defaultfigureunits','inches')
mp      = get(0, 'MonitorPositions');
max_x   = mp(1,1) + mp(1,3);

nrats = length(ratnames);
fht = 15;
%fx = mp(1)+mp(1,3)/2-fw/2;
warning('off')
ndays = 7;
nrows = 5;
ncols = ceil(nrats/nrows);
fw    = 3.5*ncols;
fx    = sum(mp(1,[1 3])) - fw - 1;
%

set(f , 'position',   [fx 1  fw fht], 'units','inches')

for rr = 1:nrats
    ax = subplot(nrows,ncols,rr);

    %%
    plotPsychometricRat(ratnames{rr},...
        'daterange',ndays,'type','delta','ax',ax);
    drawnow

end
warning('on')
print(f, fullfile(fig_path, ['rat_psycho_' datestr(today, 'mmddyy')]), '-dpng')