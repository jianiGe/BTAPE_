% A short script to extract onset/condition information from log files
% **IF YOU HAVE MORE THAN 20 CONDITIONS, please manually increase the preallocated cell
% array size**

function onsets = get_onset(log_folder)
    log_folder = log_folder;
    log_dir = dir(log_folder);
    log_dir = log_dir(~ismember({log_dir.name}, {'.', '..'}));

    onsets = cell(length(log_dir), 21);

    for i = 1:length(log_dir)

        log = load(log_dir(i).name);
        onsets{i, 1} = log_dir(i).name;

        for j = 1:length(log.log.conditions)
            if log.log.conditions(j) == 1
                onsets{i, 2}(end+1) = log.log.onset(j);
            else
                onsets{i, 3}(end+1) = log.log.onset(j);
            end
        end
 
    % trim empty columns
    num_cols = size(onsets, 2);
    not_empty = false(1, num_cols);

    for col = 1:num_cols
        if any(~cellfun(@isempty, onsets(:, col)))
            not_empty(col) = true;
        end
    end

    onsets = onsets(:, not_empty);

end