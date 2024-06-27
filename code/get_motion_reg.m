% function to split the rp_.txt file from realignment into separate files for each run 
function get_motion_reg(rp_path, output_path, file_length)
    rp_path = rp_path;
    outputFolder = output_path;
    linesPerFile = file_length;
   
    % get total number of lines
    fid = fopen(rp_path, 'r');
    lineCount = 0;
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            lineCount = lineCount + 1;
        end
    end
    fclose(fid);

    lineIndex = 1;
    fileIndex = 1;
    
    % create separate motion regressor files for each run
    fid = fopen(rp_path, 'r');
    while lineIndex <= lineCount
        splitFileName = fullfile(outputFolder, sprintf('motion_reg_%d.txt', fileIndex));
        splitFile = fopen(splitFileName, 'w');  % writes to splitted files
    
        if splitFile == -1
            error('Unable to create split file: %s', splitFileName);
        end
    
        % write linesPerFile lines to the split file
        for i = 1:linesPerFile
            line = fgetl(fid);
            fprintf(splitFile, '%s\n', line);
  
            lineIndex = lineIndex + 1;
        end
        fclose(splitFile);
    
        fileIndex = fileIndex + 1;
    end

    % close all opened files
    fclose('all');

    disp('Splitting complete.');

end