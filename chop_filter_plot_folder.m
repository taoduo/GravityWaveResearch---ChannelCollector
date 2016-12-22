function chop_filter_plot_folder(path, lowFreq, highFreq, lineToSearch, thresold, extremeCutoff)
    % This scripts loads all mat files from a folder and plot each mat file 
    % within a range of frequencies. (coh ~ freqs)
    
    % Plots are saved as ./plots_<low_freq>_<high_freq>/<original_name>.jpg
    % Create if not exist, overwrite if exist
    
    % path: the relative path from the script to the folder where all mat
    % files lies in
    % lowFreq: the lower bound of the range of frequencies
    % highFreq: the upper bound
    % line: the line to be search and marked
    % thresold: the cutoff coherence value
    % extreme cutoff: whether to implement extreme value cutoff to show the
    % structures of lower regions
    
    folder = what(path);
    matFiles = folder.mat;
    plotsFolderName = strcat('plots_', num2str(lowFreq), '_', num2str(highFreq));
    if (extremeCutoff)
        plotsFolderName = strcat(plotsFolderName, '_cut'); 
    end
    mkdir(plotsFolderName);
    for iFile = 1 : numel(matFiles)
        % init the variables
        coh=[];
        freqs = [];
        fullPath = strcat(folder.path, '/', char(matFiles(iFile)));
        load(fullPath);
        freqGap = freqs(2) - freqs(1);
        % chop the data between the two frequencies
        il = floor(lowFreq / freqGap) + 1;
        ih = ceil(highFreq / freqGap) + 1;
        if il > size(coh, 1)
            disp(strcat(char(matFiles(iFile)), ': low index ', num2str(ih) ,' exceeds ', num2str(size(coh, 1)), '. Empty.'));
            ih = 1;
            il = 1;
        elseif ih > size(coh, 1)
            disp(strcat(char(matFiles(iFile)), ': high index ', num2str(ih) ,' exceeds ', num2str(size(coh, 1)), '. Ranged Chopped.'));
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
        if (extremeCutoff)
            maxCoh = max(coh);
            avg = mean(coh);
            if (maxCoh > 0.5 && maxCoh > avg * 5);
                ylim([0, maxCoh / 2]);
            end
        end
        grid on;
        dim = [0.2 0.5 0.3 0.3];
        yl = max(cp);
	line([lineToSearch, lineToSearch],[0, yl], 'LineStyle', '-.', 'Color',[1 0 0], 'LineWidth', 0.1);
	saveas(figure1, strcat(plotsFolderName, '/', name, '.jpg'));
    end
end
