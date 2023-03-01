# Training Report

This code provides some helpful functions for reporting training progress in 
rats training in the Brody lab.

# Configuration

You will need to modify `train_report_paths.m` to point to the
relevant directories containing rat data and where you'd like to save data. 

On a Mac with cup mounted, you probably want
`tr.brodydir = '/Volumes/brody'`, whereas on the cluster you
probably want `tr.brodydir = '/jukebox/brody'`.

You can specify a `tr.parentsavedir` to be whereever you want. It will
automatically put a `figures` and `data` folder there for saving out
figures and new compilations of data like the `stages.mat` files that
contain all the training stages a rat experiences.

# Looking at the full training history

`get_training_stages` and `plot_training_stages` can be used to 
compile a list of all of the protocols and protcol stages a rat encounters 
during training. It is also possible to grab settings of interest from
the settings file as well. 

You can specify these as an `optset` in `train_report_config.m`.
You'll see there's already an example for the wait time protcol called
`wt` and a minimal example for `pbups`. 

To view the training history of rat B136, you can run

```matlab
rat = 'B139';
start_date = '' % leaving this empty will get all sessions
res = get_training_stages(rat, start_date, 'overwrite', 1, 'config_optset',
'pbups');
plot_training_stages(res);
``` 

This will produce an image like this one

![image](https://user-images.githubusercontent.com/7471909/222270642-dc6f4432-da08-4e9b-b0d1-b35516da323a.png)


