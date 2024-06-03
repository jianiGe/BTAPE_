% Description: SPM preprocessing and first-level analysis script,
% compatible with BIDS

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
addpath(data_job_dir);
addpath(fullfile(proj_dir, 'code'));


%% 
%for each subject folder under data_dir,
%--do preprocessing steps & save output to <…derivatives\spm-preproc\sub-0x>
%--do first level analysis & save output to <…derivatives\spm-preproc\sub-0x>


% Create spm-preproc folder under derivatives
preproc_dir = fullfile(proj_dir, 'derivatives', 'spm-preproc');
if ~isfolder(preproc_dir)
    mkdir(preproc_dir);
    disp('spm-preproc folder is created');
else
    disp('spm-preproc folder already exists');
end

% Create spm-first-level folder under derivatives
firstlevel_dir = fullfile(proj_dir, 'derivatives', 'spm-first-level');
if ~isfolder(firstlevel_dir)
    mkdir(firstlevel_dir);
    disp('spm-first-level folder is created');
else
    disp('spm-first-level folder already exists');
end


%% For each subject...
subfolder = dir(rawdata_dir);

for i = 1:length(subfolder)

    if subfolder(i).isdir && startsWith(subfolder(i).name, 'sub')

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



