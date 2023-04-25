
function [fh, b] = plotPsychometricRat(ratname, varargin)
% function [fh, b] = plotPsychometricRat(ratname, varargin)
% optional inputs and defaults: daterange = 10, type = 'delta', ax = []
% nbin = 8, dataColor = 'k', plotLastDay = true
p = inputParser;
addParameter(p, 'daterange', 10);
addParameter(p, 'type', 'delta');
addParameter(p, 'ax', []);
addParameter(p, 'nbin', 8);
addParameter(p, 'dataColor', 'k');
addParameter(p, 'plotLastDay', false);
addParameter(p, 'data_dir', []);
parse(p, varargin{:});

daterange = p.Results.daterange;
if length(daterange) == 1 || isempty(daterange)
    daterange = {datestr(today-daterange,29) datestr(today,29)};
elseif isnumeric(daterange)
    daterange = {datestr(today-daterange,29) datestr(today,29)};
end

type = p.Results.type;
ax = p.Results.ax;
nbin = p.Results.nbin;

if isempty(ax)
    fh = figure;
    ax = axes;
end

[ratdata, avgdata] = package_wt_data(ratname, daterange);
if isempty(ratdata) 
    [ratdata, avgdata] = package_pbups_data(ratname, daterange);
end
%%
if isempty(ratdata)
    fprintf('\ncould not find data for rat %s in range %s to %s\n',...
        ratname, daterange{1}, daterange{2})
    return
end
%%
pokedR = avgdata.pokedR(:);
switch type
    case 'delta'
        SNR = avgdata.Delta(:);
        xlab = 'click difference ($R-L$)';
    case 'gamma'
        SNR = avgdata.gamma(:);
        xlab ='$log(rate_r)-log(rate_l)$';
        nbin = length(unique(SNR));
    case 'snr'
        SNR = avgdata.Delta(:) ./ sqrt(avgdata.Sigma(:));
        xlab = '$\frac{R-L}{\sqrt{R+L}}$';
    case 'norm_sum'
        SNR = avgdata.Delta(:) ./ (avgdata.Sigma(:));
        xlab = '$\frac{R-L}{R+L}$';
end

%SNR = avgdata.gamma';
[~, res] = plotPsychometric(SNR, pokedR,'axHandle', ax, 'nbin', nbin, ...
    'dataLineStyle','.','dataColor', 'k', 'dataFaceColor','w','dataMarkerSize',18);

if p.Results.plotLastDay
    [~, ~, ix] = unique([ratdata.sessdate]);
    
    ix = ix == max(ix);
    b = plotPsychometric(SNR(ix), pokedR(ix),...
        'axHandle', ax, 'nbin', nbin, ...
        'dataLineStyle','o','dataMarkerSize',5,...
        'dataFaceColor','w', 'compute_fit', false,...
        'edges',res.edges);
end

ntrials = length(avgdata.Delta);
title_str = sprintf('%s %i trials %.0f%% hits \n %s -- %s',...
    ratname, ntrials, 100* mean(avgdata.hits),...
    datestr(daterange{1},'mm-dd-yy'), datestr(daterange{2},'mm-dd-yy'));
title(ax, title_str,'fontweight','normal');
xlabel(ax, xlab, 'interpreter','latex')
ylabel(ax, '% went right')




