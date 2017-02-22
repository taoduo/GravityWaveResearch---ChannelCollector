function line_channels_all_week(lineChannelPath, dataPath, postfix, folderid, flexibleChannelDirection)
    % Input: lines/channels to examine + weeks of data
    % Output: plots of all channels at the lines of all weeks
    
    % Plots are saved as ./plots/
    % Create if not exist, overwrite if exist
    
    % lineChannelPath: the path to a txt file with all the lines, ranges & channels
    %   the txt file format:
    %     line lower upper
    %     channel
    %     channel
    % dataPath: contains weeks, and then channels of the week
    % postfix: whether there are '_data' at the end of the channels in txt
    % folderid: the string to prepend the folder name
    % flexibleChannelDirection: if _X does not exist, try _Y or _Z. Usually false,
    % used only in special situations
    
    output_folder = strcat(folderid, '_', 'plots'); % save plots here
    note_path = strcat(output_folder, '/notes.txt'); % error log file
    mkdir(output_folder);
    note_file = fopen(note_path,'w'); % create the error log file, if no error it will be empty
    % The outputs of this section are just two maps: lineChannelMap and
    % lineRangeMap
    lineChannelMap = containers.Map('KeyType','double', 'ValueType','any');
    lineRangeMap = containers.Map('KeyType','double', 'ValueType','any');
    lineChannel = textread(lineChannelPath, '%s', 'delimiter', '\n');
    key = '';
    chns = cell(1,1);
    trk = 1;
    for i = 1 : size(lineChannel)
        matches = strfind(lineChannel(i), ' ');
        tf = any(vertcat(matches{:}));
        if tf && ~strcmp(key, '')
            temp = strsplit(key{1}, ' ');
            line = str2double(temp(1));
            up = str2double(temp(2));
            down = str2double(temp(3));
            lineChannelMap(line) = chns;
            lineRangeMap(line) = [down, up];
            
            key = lineChannel(i);
            chns = cell(1,1);
            trk = 1;
            
        elseif tf && strcmp(key, '')
            key = lineChannel(i);
        else
            chns{trk,1} = lineChannel(i);
            trk = trk + 1;
        end
    end
    temp = strsplit(key{1}, ' ');
    line = str2double(temp(1));
    up = str2double(temp(2));
    down = str2double(temp(3));
    lineChannelMap(line) = chns;
    lineRangeMap(line) = [down, up];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % start plotting
    for line = keys(lineChannelMap)
        line_folder_path = strcat(output_folder, '/', num2str(line{1}));
        chns = lineChannelMap(line{1});
        for chni = 1 : length(chns)
            chn = chns{chni};
            channel_folder_path = strcat(line_folder_path, '/', chn{1});
            mkdir(channel_folder_path);
            data_file_name = chn{1};
            if ~postfix
                data_file_name = strcat(data_file_name, '_data');
            end
            files = dir(dataPath);
            dir_filter = [files.isdir];
            week_data_folder = files(dir_filter);
            week_data_folder(1:2) = [];
            for k = 1 : length(week_data_folder)
                path_to_data = strcat(dataPath, '/', week_data_folder(k).name, '/data/', data_file_name, '.mat');
                output_plot_path = strcat(channel_folder_path, '/week', num2str(k), '.jpg');
                range = lineRangeMap(line{1});
                if exist(path_to_data, 'file')
                    look_at_mark(path_to_data, range(1), range(2), line{1}, output_plot_path);
                elseif (flexibleChannelDirection)
                    npath = flexible_channel_direction(path_to_data);
                    if (~isempty(npath))
                        look_at_mark(npath, range(1), range(2), line{1}, output_plot_path);
                        [~, nchn, ~] = fileparts(npath);
                        note_str = strcat(chn{1}, ' substituted with:', nchn, '. Week:', num2str(k), '/Line:', num2str(line{1}), '\n');
                        fprintf(note_file, note_str);
                    else
                        note_str = strcat(chn{1}, ' not found. Week:', num2str(k), '/Line:', num2str(line{1}), '/Flexible\n');
                        fprintf(note_file, note_str);
                    end
                else
                    note_str = strcat(chn{1}, ' not found. Week:', num2str(k), '/Line:', num2str(line{1}), '/InFlexible\n');
                    fprintf(note_file, note_str);
                end
            end
        end
    end
    fclose(note_file);
end
