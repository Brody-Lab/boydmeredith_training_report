function tr = train_report_config(optset)

if nargin < 1 || isempty(optset)
    optset = 'pbups';
end

tr = train_report_paths();

% Protocols to include in analysis
switch optset
    case 'wt'
    tr.protocols = {'ProAnti3', 'PBups', 'PBupsWT'};

    % Settings fields to record
    tr.settings_fields_names = {'PenaltySection_LegalWaitBreak','LegalWaitBreak',...
        'PenaltySection_SignalWaitViol', 'SignalWaitViol',...
        'PenaltySection_TerminateWaitBreak','TerminateWaitBreak',...
        'DistribInterface_HitWaitDelay_Min','RewDelayMin',...
        'DistribInterface_HitWaitDelay_Tau','RewDelayTau',...
        'DistribInterface_HitWaitDelay_Max','RewDelayMax',...
        'DistribInterface_ErrorWaitDelay_Min','ErrDelayMin',...
        'DistribInterface_ErrorWaitDelay_Max','ErrDelayMax',...
        'SidesSection_CatchFreq','CatchFrac',...
        };

    case 'pbups'
    tr.protocols = {'ProAnti3', 'PBups', 'SameDifferent', 'Classical'};
    tr.settings_fields_names = {};
end

