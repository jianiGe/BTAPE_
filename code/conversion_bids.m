%% Sort fmri data (.nii and .json) into BIDS compatible folder structures
% N.B. the .nii and .json files are converted from the raw dicom files using
% the dicm2nii tool box 
% (https://de.mathworks.com/matlabcentral/fileexchange/42997-xiangruili-dicm2nii)
sub_no = 'sub-007';
sub_dir = "C:\Users\jiani\Documents\MATLAB\BTAPE\raw\output\sub-007";

% create subfolders for func and anat images
func_dir = fullfile(sub_dir, 'func');
anat_dir = fullfile(sub_dir, 'anat');

if ~isfolder(func_dir)
    mkdir(func_dir);
    disp('"func" folder is created');
else
    disp('"func" folder already exists');
end

if ~isfolder(anat_dir)
    mkdir(anat_dir);
    disp('"anat" folder is created');
else
    disp('"anat" folder already exists');
end

% move files
files = dir(sub_dir);
for i = 1:length(files)
    if startsWith(files(i).name, 'anat') && ~files(i).isdir
        
        movefile(fullfile(files(i).folder, files(i).name), fullfile(anat_dir, files(i).name));
    end

    if contains(files(i).name, 'func_task') && ~files(i).isdir
        movefile(fullfile(files(i).folder, files(i).name), fullfile(func_dir, files(i).name))
    end
end

% rename files
files = dir(anat_dir);
cd(anat_dir);
for i = 1:length(files)
    if startsWith(files(i).name, 'anat') && ~files(i).isdir
        [~, name, ext] = fileparts(files(i).name);
        movefile(files(i).name, strcat(sub_no, "_T1w", ext)) % new name: 'sub-007_T1w...'
    end
end

files = dir(func_dir);
cd(func_dir);

for i = 1:length(files)
    if contains(files(i).name, 'func_task') && ~files(i).isdir
        [~, name, ext] = fileparts(files(i).name);
        movefile(files(i).name, strcat(sub_no, ...
                                       "_task-BTP_run-", ...
                                       name(end-2:end), ...
                                       '_bold', ext)) % e.g. 'sub-007_task-BTP_run-005_bold.nii'
    end
end
    


