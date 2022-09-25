function [ratnames, experimenter] = get_ratnames(group)
if nargin < 1
    group = 'active';
end
switch group
    case 'wt_all'
           ratnames = {'J243', 'J244', 'J246', 'J247', 'J248', 'J250',...
               'J300', 'J301', 'J303', 'J304', 'J305', 'J313', 'J314', ...
               'J315', 'J330', 'J332', 'Z159', 'Z160', 'Z161', 'Z162',...
               'Z163', 'Z164', 'Z165', 'Z166', 'Z253', 'Z254', 'Z255',...
               'Z256', 'Z257', 'Z258'};
    case 'wt_muscimol'
        ratnames = {'Z255', 'J244'};
    case 'active'
        recentrats = unique(bdata(['select ratname from sessions where ' ...
            'experimenter="Tyler" and sessiondate>="{S}"'],datestr(today-7, 29)));
        [allrats, alive] = bdata('select ratname, extant from ratinfo.rats');
        recentalive = ismember(recentrats, allrats(find(alive)));
        ratnames    = recentrats(recentalive);
end
% 
% j_rats_2019 = {'J243', 'J244', 'J246', 'J247', 'J248','J249', 'J250',...
%     'J300', 'J301', 'J302','J303', 'J306','J307','J308',...
%     'J309','J310','J311','J312','J313','J314','J315'};
%     
% j_rats_2020 = cellfun(@(x) sprintf('J%i',x), num2cell(316:323),'uniformoutput',0);
% h_rats  = {'H153', 'H161','H126','H138','H170','H171','H173',...
%     'H209','H203','H215','H194'};
% ratnames = {j_rats_2019{:} j_rats_2020{:} h_rats{:}};
% 
% 
% 
experimenter = ratnames;
for rr = 1:length(ratnames)
    if ratnames{rr}(1)=='J' | ratnames{rr}(1)=='Z'
        experimenter{rr} = 'Tyler';
    elseif ratnames{rr}(1)=='H'
        experimenter{rr} = 'Ahmed';
    end
end
%     
%     
%     dead = {'Z159','Z160','Z161','Z163','Z164','Z165','J245'};
    %
% 
% alive = {'Z159'  'Z160'  'Z161'  'Z162'  'Z163'  'Z164'  'Z166'};
% active = { 'Z160'  'Z161'  'Z162'  'Z163'  'Z164'  'Z166'};
% soon_dead = {'Z159'};
% dead = {'Z165' };
% wtFirst = {'Z161'  'Z162'  'Z165'  'Z166'}; 
% bupsFirst = {'Z159'  'Z160'  'Z163'  'Z164'};

