function matlabbatch = normalise_functional(fnorm_def_path, fnorm_rsmp_path)
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = fnorm_def_path;
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = fnorm_rsmp_path;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
end