function tr = train_report_config()

% Path to brody lab directory on cup where data lives
tr.brodydir = '/Volumes/brody';

% Path to save new files
tr.parentsavedir = '~/projects/rat_training';


tr.figsavedir = fullfile(tr.parentsavedir, 'figures');
tr.datasavedir = fullfile(tr.parentsavedir, 'data');