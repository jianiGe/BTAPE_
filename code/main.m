%% Main script for preprocessing and first level analysis
% August 19 update

% Contains the following functionalities
% - Sort data into BIDS compatible folder structure
% - Preprocessing
% --- realignment, coregistration, segmentation, functional normalization, structural normalization, smoothing
% - First-level GLM
% --- extract onset, extract motion regressors, GLM specification and
% estimation, contrast estimation


%% Preliminary set-up
% set up SPM
spm_dir = 'C:\Users\jiani\Downloads\spm12\spm12';
addpath(spm_dir);
spm('defaults', 'fmri');
spm_jobman('initcfg');

% set paths
proj_dir = 'C:\Users\jiani\Documents\MATLAB\BTAPE';
rawdata_dir = fullfile(proj_dir, 'raw', 'output');
addpath(rawdata_dir);

data_job_dir = fullfile(proj_dir, 'code','preproc_func');
%addpath(data_job_dir);
addpath(fullfile(proj_dir, 'code'));


%% Sort fmri data (.nii and .json) into BIDS compatible folder structures
% N.B. the .nii and .json files are converted from the raw dicom files using
% the dicm2nii tool box 
% (https://de.mathworks.com/matlabcentral/fileexchange/42997-xiangruili-dicm2nii)

sub_no = [1:1]; % an array with the subject numbers to be processed
output_dir = 'C:\Users\jiani\Documents\MATLAB\BTAPE\raw\output'; % folder containing the output files from dicm2nii conversion

conversion_bids(sub_no, output_dir);


%% Preprocessing
% for each subject folder under data_dir, execute preprocessing steps 
% & save output to <…derivatives\spm-preproc\sub-0x>

% Create spm-preproc folder under derivatives
preproc_dir = fullfile(proj_dir, 'derivatives', 'spm-preproc');
if ~isfolder(preproc_dir)
    mkdir(preproc_dir);
    disp('spm-preproc folder is created');
else
    disp('spm-preproc folder already exists');
end

subfolder = dir(rawdata_dir);

for i = 1:length(subfolder)

    if subfolder(i).isdir && startsWith(subfolder(i).name, 'sub-') % replace 'sub-' with 'sub-00x' if you want to process one subject at a time

        sub_dir = fullfile(rawdata_dir, subfolder(i).name); %'...\sub-00x'

        % ==========================PREPROCESSING==========================

        % Create a folder for the subject under derivatives\spm-preproc
        sub_preproc_dir = ([preproc_dir '\' subfolder(i).name]);
        if ~isfolder(sub_preproc_dir)
            mkdir(sub_preproc_dir);
            disp(['spm-preproc folder for ' subfolder(i).name ' has been created']);
        else
            disp(['spm-preproc folder for ' subfolder(i).name ' already exists']);
        end
        
        % Make a copy of the data in the spm-preproc/sub-0x directory
        files = dir(sub_preproc_dir);
        files = files(~ismember({files.name}, {'.', '..'}));
        if isempty(files)
            copyfile(fullfile(sub_dir, '*'), sub_preproc_dir);
            disp(['a copy of folder ''' subfolder(i).name ''' has been made'])
        else
            disp(['a copy of folder ''' subfolder(i).name ''' already exists'])
        end
        
        % Run preprocessing
        % via function 'preprocessing'. e.g., preprocessing(steps, data_dir, spm_dir)
        % 'steps' argument is a string that specifies the preprocessing steps to be
        % executed; if nothing is entered, the default would be to execute all of the
        % following:
        % A--realignment
        % B--coregistration
        % C--segmentation
        % D--functional normalization
        % E--structural normalization
        % F--smoothing

        preprocessing('ABCDEF', sub_preproc_dir, spm_dir); 
        % i'd suggest to do them one at a time if you're working on your
        % personal PC as some steps could take hours with a larger
        % dataset :)

    end
end


%% First-level GLM
% currently designed to process one subject at a time, given that the
% number of runs isn't consistent across subjects

% directory of preprocessed files
sub_preproc_dir = 'C:\Users\jiani\Documents\MATLAB\BTAPE\derivatives\spm-preproc\sub-007\func';

% runs to be included in the GLM
runs = [1 2 3 4 5 6 7];

% extract condition onsets from log files
log_folder = 'C:\Users\jiani\Documents\MATLAB\BTAPE\raw\source data\sub-007\log';
onsets = get_onset(log_folder);

% segment motion regressors into one file per run
rp_path = 'C:\Users\jiani\Documents\MATLAB\BTAPE\derivatives\spm-preproc\sub-007\func\rp_sub-007_task-BTP_run-004_bold.txt';
rp_output_path = fullfile(proj_dir, 'sub-007_motion-regressors');
if ~exist(rp_output_path)
    mkdir(rp_output_path);
end
run_length = 360;

get_motion_reg(rp_path, rp_output_path, run_length);

% first-level GLM specification and estimation
% **please set additional parameters (e.g. time modulation) within the
% glm_first_level_spec_est() function**
glm_first_level_spec_est(sub_preproc_dir, runs, onsets, rp_output_path)


%% First-level contrast

glm_dir = 'C:\Users\jiani\Documents\MATLAB\BTAPE\derivatives\spm-first-level-motion-reg';

% sample contrasts, modify as needed
new_contrasts = {struct('name', 'bistable1', 'weights', repmat([1 0 0 0 0 0 0 0 0 0],1,6), 'type', 't');...
                 struct('name', 'bistable2', 'weights', repmat([0 0 1 0 0 0 0 0 0 0],1,6), 'type', 't');...
                 struct('name', 'localizer1', 'weights', [repmat([0],1,60) [1 0 0 0 0 0 0 0 0 0]], 'type', 't');...
                 struct('name', 'localizer2', 'weights', [repmat([0],1,60) [0 0 1 0 0 0 0 0 0 0]], 'type', 't')};

% sample subject number, modify as needed
subj = [1:1]; 

% estimate contrast
glm_contrast(glm_dir, subj, new_contrasts);


