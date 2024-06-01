function first_level_spec_est(steps, sub_preproc_dir, sub_firstlevel_dir)

%% Set paths
func_dir = fullfile(sub_preproc_dir, 'func');
firstlevel_dir = sub_firstlevel_dir

%% 
if nargin < 2 || isempty(steps)
    steps = 'SE';
else
    steps = steps';


%% spm_jobman() variables

nrun = 1;
%jobfile = matlabbatch;
%jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end


%% FIRST LEVEL

for i = 1:length(steps)

    matlabbatch = {};

    % =====================SPECIFICATION=====================
    if steps(i) == 'S'

    %select input files
    filter_scans = '^sw.*\.nii$';
    selected_scans = spm_select('List', func_dir, filter_scans);
    spec_scans_path = cellstr(strcat(func_dir, '\', selected_scans));

    spec_dir_path = cellstr(firstlevel_dir);

    %specify batch
    matlabbatch{1}.spm.stats.fmri_spec.dir = spec_dir_path;
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 7;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = spec_scans_path;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond.name = 'listening';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond.onset = [6
                                                      18
                                                      30
                                                      42
                                                      54
                                                      66
                                                      78];
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond.duration = 6;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond.tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond.orth = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    end

    % ======================ESTIMATION=======================
    if steps(i) == 'E'

    %select input file
    est_spmmat_path = cellstr(strcat(firstlevel_dir,'\SPM.mat'));

    %specify batch
    matlabbatch{1}.spm.stats.fmri_est.spmmat = est_spmmat_path;
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    end

    %% Run matlabbatch
    spm('defaults', 'FMRI');
    spm_jobman('run', matlabbatch, inputs{:});

end

end