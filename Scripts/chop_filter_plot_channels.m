function chop_filter_plot_channels(channelPath, dataPath, lowFreq, highFreq, thresold)
    % This scripts loads all mat files from a folder and plot each mat file 
    % specified in a txt file within a range of frequencies. (coh ~ freqs)
    
    % Plots are saved as ./plots_<low_freq>_<high_freq>/<original_name>.jpg
    % Create if not exist, overwrite if exist
    
    % channelPath: the path to a txt file with all the channels
    % dataPath: the relative path from the script to the folder where all mat
    % files lies in
    % lowFreq: the lower bound of the range of frequencies
    % highFreq: the upper bound
    % thresold: the cutoff coherence
    
    channels = textread(channelPath, '%s', 'delimiter', '\n');
    folder = what(dataPath);
    plotsFolderName = strcat(num2str(numel(channels)), '_channels_plots_', num2str(lowFreq), '_', num2str(highFreq));
    mkdir(plotsFolderName);
    for chni = 1 : numel(channels)
        % init the variables
        coh=[];
        freqs = [];
        fn = strcat(channels{chni, 1}, '.mat');
        fullPath = strcat(folder.path, '/', fn);
        load(fullPath);
        freqGap = freqs(2) - freqs(1);
        % chop the data between the two frequencies
        il = floor(lowFreq / freqGap) + 1;
        ih = ceil(highFreq / freqGap) + 1;
        if il > size(coh, 1)
            disp(strcat(char(matFiles(fn)), ': low index ', num2str(ih) ,' exceeds ', num2str(size(coh, 1)), '. Empty.'));
            ih = 1;
            il = 1;
        elseif ih > size(coh, 1)
            disp(strcat(char(matFiles(fn)), ': high index ', num2str(ih) ,' exceeds ', num2str(size(coh, 1)), '. Ranged Chopped.'));
            ih = size(coh, 1);
        end
        
        fp = freqs(il : ih);
        cp = coh(il : ih);
        
        %filter the data
        cp(cp < thresold) = 0;
        
        % plot and save
        [~, name, ~] = fileparts(fullPath);
        figure1 = figure;
        set(figure1, 'Visible', 'off');
        axes1 = axes('Parent', figure1);
        hold(axes1, 'all');
        plot(fp, cp);
        t = title(name);
        set(t, 'interpreter', 'none');
        xlabel('Frequency (Hz)');
        ylabel('Coherence');
        xlim([lowFreq, highFreq]);
        grid on;
        saveas(figure1, strcat(plotsFolderName, '/', name, '.jpg'));
    end
end