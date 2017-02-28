function combs_searcher_folder_filter( dataPath, lowFreq, highFreq, combFreq, offset, filter_multiplier, output_path )    % COMBS_SEARCHER_FOLDER_FILTER Plot and mark at certain frequencies with equal gaps to
    % show whether a comb structure of a particular frequency and offset exists in the plot
    
    % dataPath: the relative path from the script to the folder where all mat
    % files lies in
    % lowFreq: the lower bound of the range of frequencies
    % highFreq: the upper bound
    % combFreq: the frequency gap of the expected comb structure
    % offset: the offset of the comb structure
    % whetherToMark: whether to mark the frequencies with text. If the gap
    % is too small, better not since they covers each other.
    
    folder = what(dataPath);
    matFiles = folder.mat;
    plotsFolderName = strcat(num2str(combFreq), '_', 'comb_search_filter_plots_', num2str(lowFreq), '_', num2str(highFreq));
    mkdir(plotsFolderName);
    chnTxtPath = strcat(plotsFolderName, '/', 'channels.txt');
    chnTxtFile = fopen(chnTxtPath, 'wt');
    fprintf(chnTxtFile, 'Results');
    for chni = 1 : numel(matFiles);
        % init the variables
        coh=[];
        freqs = [];
        fn = matFiles{chni, 1}; % file name
        fullPath = strcat(folder.path, '/', fn);
        load(fullPath);
        freqGap = freqs(2) - freqs(1);
        markerPositions = (ceil((lowFreq - offset) / combFreq) * combFreq + offset) : combFreq : highFreq; 
        % chop the data between the two frequencies
        il = floor(lowFreq / freqGap) + 1;
        ih = ceil(highFreq / freqGap) + 1;
        if il > size(coh, 1)
            disp(strcat(fn, ': low index ', num2str(ih) ,' exceeds ', num2str(size(coh, 1)), '. Empty.'));
            ih = 1;
            il = 1;
        elseif ih > size(coh, 1)
            disp(strcat(fn, ': high index ', num2str(ih) ,' exceeds ', num2str(size(coh, 1)), '. Ranged Chopped.'));
            ih = size(coh, 1);
        end
        fp = freqs(il : ih);
        cp = coh(il : ih);
        
        % if the data at these marker positions are not significant enough,
        % skip
        thres = mean(cp) * filter_multiplier;
        sigCount = 0; % count the number of significant lines
        viablePositions = markerPositions(markerPositions <= freqs(ih));
        if (viablePositions > 0)
            for p = markerPositions
                if ((ceil(p / freqGap) <= length(coh) && coh(ceil(p / freqGap)) >= thres) || (floor(p / freqGap) > 0 && floor(p / freqGap) <= length(coh) && coh(floor(p / freqGap)) >= thres))
                    sigCount = sigCount + 1;
                end
            end
            if (sigCount / length(viablePositions) < 0.5)
                continue;
            end
        end
        % plot the mark lines
        [~, name, ~] = fileparts(fullPath);
        figure1 = figure;
        set(figure1, 'Visible', 'off');
        axes1 = axes('Parent', figure1);
        hold(axes1, 'all');
        
        yl = max(cp);
        for i = 1 : length(markerPositions)
            line([markerPositions(i) markerPositions(i)],[0, yl], 'LineStyle', '-.', 'Color',[1 0 0], 'LineWidth', 0.1);
            if whetherToMark
                text(markerPositions(i), yl, strcat(num2str(markerPositions(i)), '(', num2str(i), ')'), 'FontSize', 5);
            end
        end
        
        % plot the data lines
        hold on;
        plot(fp, cp);
        t = title(name);
        set(t, 'interpreter', 'none');
        xlabel('Frequency (Hz)');
        ylabel('Coherence');
        xlim([lowFreq, highFreq]);
        grid on;    
        saveas(figure1, strcat(plotsFolderName, '/', name, '.jpg'));
        fprintf(chnTxtFile, strcat(name(1 : length(name) - 5), '\n'));
    end
    fclose(chnTxtFile);
end

