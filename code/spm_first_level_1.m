%% FIRST LEVEL GLM FOR ONE SUBJECT
% 27.06
% just a warning that for this one, i was taking less care to automatize file paths; so you
% might have to manually replace things a bit more...than usual =>
spm('defaults', 'fmri');
spm_jobman('initcfg');

% files paths
proj_dir = 'C:\Users\jiani\Documents\MATLAB\BTAPE\derivatives\spm-first-level-motion-reg';
sub_preproc_dir = 'C:\Users\jiani\Documents\MATLAB\BTAPE\derivatives\spm-preproc\sub-007\func';

%% input variables
% preprocessed runs
input_scans = {};
filter = fullfile(sub_preproc_dir, 'sw*nii');
files = dir(filter);
for i = 1:length(files)
    input_scans{end+1} = [sub_preproc_dir '\' files(i).name];
end

% runs that we are going to use
% for now i'm using the 6 bistable runs, later (this/next week) i will
% also try to do GLM with the localizer runs together
runs = [1 2 3 4 5 6];

% onset info
log_folder = 'C:\Users\jiani\Documents\MATLAB\BTAPE\raw\source data\sub-007\log';
onsets = get_onset(log_folder);

% timing, etc.
RT = 1; %sec
block_duration = 24;

% regressors
% motion
rp_path = 'C:\Users\jiani\Documents\MATLAB\BTAPE\derivatives\spm-preproc\sub-007\func\rp_sub-007_task-BTP_run-004_bold.txt';
rp_output_path = fullfile(proj_dir, 'motion-regressors');
if ~exist(rp_output_path)
    mkdir(rp_output_path);
end
run_length = 360;

get_motion_reg(rp_path, rp_output_path, run_length);

rp_dir = dir(rp_output_path);
rp_dir = rp_dir(~ismember({rp_dir.name}, {'.', '..'}));

% time modulation
time_mod = 1;



%% finally we can build the batch!
matlabbatch{1}.spm.stats.fmri_spec.dir = {proj_dir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = RT;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

for i = 1:length(runs)
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans = {input_scans{runs(i)}};

    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).name = 'condition1';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).onset = onsets{runs(i), 1+1};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).duration = block_duration;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).tmod = time_mod;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).orth = 1;

    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(2).name = 'condition2';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(2).onset = onsets{runs(i), 2+1};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(2).duration = 24;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(2).tmod = time_mod;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(2).orth = 1;

    matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi_reg = {fullfile(rp_output_path, rp_dir(runs(i)).name)};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).hpf = 128;    
end   
    
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

% modal estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%%
spm_jobman('run', matlabbatch);