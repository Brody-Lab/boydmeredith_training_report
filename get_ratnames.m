function [ratnames, experimenter] = get_ratnames

j_rats_2019 = {'J243', 'J244', 'J246', 'J247', 'J248','J249', 'J250',...
    'J300', 'J301', 'J302','J303', 'J306','J307','J308',...
    'J309','J310','J311','J312','J313','J314','J315'};
    
j_rats_2020 = cellfun(@(x) sprintf('J%i',x), num2cell(316:323),'uniformoutput',0);
h_rats  = {'H153', 'H161','H126','H138','H170','H171','H173',...
    'H209','H203','H215','H194'};
ratnames = {j_rats_2019{:} j_rats_2020{:} h_rats{:}};

ratnames = { 'J324','J325','J327','J328','J329','J330','J331','J332','J333',...
    'J334','J335','J336'};

experimenter = ratnames;
for rr = 1:length(ratnames)
    if ratnames{rr}(1)=='J'
        experimenter{rr} = 'Tyler';
    else
        experimenter{rr} = 'Ahmed';
    end
end
    
    
    dead = {'Z159','Z160','Z161','Z163','Z164','Z165','J245'};
    %
% 
% alive = {'Z159'  'Z160'  'Z161'  'Z162'  'Z163'  'Z164'  'Z166'};
% active = { 'Z160'  'Z161'  'Z162'  'Z163'  'Z164'  'Z166'};
% soon_dead = {'Z159'};
% dead = {'Z165' };
% wtFirst = {'Z161'  'Z162'  'Z165'  'Z166'}; 
% bupsFirst = {'Z159'  'Z160'  'Z163'  'Z164'};

