function first_level_contrast(sub_firstlevel_dir, stat, name, vec)
    
    % SPM.mat path
    spmmat_path = fullfile(sub_firstlevel_dir, 'SPM.mat');
    
    %==================CONTRAST ESTIMATION======================
    matlabbatch = {};

    for i = 1:length(name)
        j = i*2-1;

    % specify matlabbatch
    matlabbatch{j}.spm.stats.con.spmmat = {spmmat_path};

    % define contrast
    if stat == 't'
        matlabbatch{j}.spm.stats.con.consess{1}.tcon.name = name{i};
        matlabbatch{j}.spm.stats.con.consess{1}.tcon.weights = vec{i};
        matlabbatch{j}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    elseif stat == 'f'
        matlabbatch{j}.spm.stats.con.consess{1}.fcon.name = name{i};
        matlabbatch{j}.spm.stats.con.consess{1}.fcon.weights = vec{i};
        matlabbatch{j}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
    end
    matlabbatch{j}.spm.stats.con.delete = 1;
    
    %===================RESULT TABLE====================
    p_value_threshold = 0.05;
    
    matlabbatch{j+1}.spm.stats.results.spmmat = {spmmat_path};
    matlabbatch{j+1}.spm.stats.results.conspec(1).titlestr = name{i};
    matlabbatch{j+1}.spm.stats.results.conspec(1).contrasts = i;
    matlabbatch{j+1}.spm.stats.results.conspec(1).threshdesc = 'FWE'; % 'FWE' for family-wise error correction, 'FDR' for false discovery rate, or 'none'
    matlabbatch{j+1}.spm.stats.results.conspec(1).thresh = p_value_threshold;
    matlabbatch{j+1}.spm.stats.results.conspec(1).extent = 0; % minimum cluster size
    matlabbatch{j+1}.spm.stats.results.conspec(1).conjunction = 1;
    matlabbatch{j+1}.spm.stats.results.conspec(1).mask.none = 1; % no mask

    end
    
    spm_jobman('run', matlabbatch);
    
end