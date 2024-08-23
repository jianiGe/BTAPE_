% 23 August 2024
% Script for estimating contrasts for all subjects
% With the following sample contrasts
% con1: bistable cond 1
% con2: bistable cond 2
% con3: localizer cond 1
% con4: localizer cond 2

glm_dir = 'C:\Users\jiani\Documents\MATLAB\BTAPE\derivatives\spm-first-level-motion-reg';

new_contrasts = {struct('name', 'bistable1', 'weights', repmat([1 0 0 0 0 0 0 0 0 0],1,6), 'type', 't');...
                 struct('name', 'bistable2', 'weights', repmat([0 0 1 0 0 0 0 0 0 0],1,6), 'type', 't');...
                 struct('name', 'localizer1', 'weights', [repmat([0],1,60) [1 0 0 0 0 0 0 0 0 0]], 'type', 't');...
                 struct('name', 'localizer2', 'weights', [repmat([0],1,60) [0 0 1 0 0 0 0 0 0 0]], 'type', 't')};

subj = [1:1]; % replace with your subject number(s)

% Specify matlabbatch
for i = subj

    spm_mat = strcat(glm_dir, '\sub-', sprintf('%03d',i), '\SPM.mat'); % modify according to your folder structure

    matlabbatch = {};

    for j = 1:length(new_contrasts)

        matlabbatch{j}.spm.stats.con.spmmat = {spm_mat};

        if new_contrasts{j}.type == 't'
            matlabbatch{j}.spm.stats.con.consess{1}.tcon.name = new_contrasts{j}.name;
            matlabbatch{j}.spm.stats.con.consess{1}.tcon.weights = new_contrasts{j}.weights;
            matlabbatch{j}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        elseif new_contrasts{j}.type == 'f'
            matlabbatch{j}.spm.stats.con.consess{1}.fcon.name = new_contrasts{j}.name;
            matlabbatch{j}.spm.stats.con.consess{1}.fcon.weights = new_contrasts{j}.weights;
            matlabbatch{j}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
        end
        
        % delete previously estimated contrasts
        if j == 1
            matlabbatch{j}.spm.stats.con.delete = 1;
        else
            matlabbatch{j}.spm.stats.con.delete = 0;
        end

    end
    
    spm_jobman('run', matlabbatch);
end

