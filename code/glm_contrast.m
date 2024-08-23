% 23 August 2024
% function for estimating contrasts for specified subjects

function glm_contrast(glm_dir, subj, contrasts)

glm_dir = glm_dir;
new_contrasts = contrasts;
subj = subj;

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

end