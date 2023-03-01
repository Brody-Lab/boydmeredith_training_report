function trp = train_report_paths()

% Path to brody lab directory on cup where data lives
tr.brodydir = '/jukebox/brody';

% Path to save new files
tr.parentsavedir = '/jukebox/brody/jtb3/projects/rat_training';

tr.figsavedir = fullfile(tr.parentsavedir, 'figures');
if exist(tr.parentsavedir, 'dir') && ~exist(tr.figsavedir, 'dir')
    mkdir(tr.figsavedir)
end
tr.datasavedir = fullfile(tr.parentsavedir, 'data');
if exist(tr.parentsavedir, 'dir') && ~exist(tr.datasavedir, 'dir')
    mkdir(tr.datasavedir)
end
