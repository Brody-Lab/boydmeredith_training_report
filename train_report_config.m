function tr = train_report_config()

include_wt = false;

% Path to brody lab directory on cup where data lives
tr.brodydir = '/Volumes/brody';

% Path to save new files
tr.parentsavedir = '~/projects/rat_training';

tr.figsavedir = fullfile(tr.parentsavedir, 'figures');
if exist(tr.parentsavedir, 'dir') && ~exist(tr.figsavedir, 'dir')
    mkdir(tr.figsavedir)
end
tr.datasavedir = fullfile(tr.parentsavedir, 'data');
if exist(tr.parentsavedir, 'dir') && ~exist(tr.datasavedir, 'dir')
    mkdir(tr.datasavedir)
end

% Protocols to include in analysis
if include_wt
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

else
    tr.protocols = {'ProAnti3', 'PBups', 'SameDifferent', 'Classical'};
    tr.settings_fields_names = {};
end

