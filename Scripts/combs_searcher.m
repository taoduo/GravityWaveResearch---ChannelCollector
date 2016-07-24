function combs_searcher(channelPath, dataPath, lowFreq, highFreq, combFreq, offset, whetherToMark)
    % COMBS_SEARCHER Plot and mark at certain frequencies with equal gaps to
    % show whether a comb structure of a particular frequency and offset exists in the plot
    % channelPath: the path to a txt file with all the channels
    % dataPath: the relative path from the script to the folder where all mat
    % files lies in
    % lowFreq: the lower bound of the range of frequencies
    % highFreq: the upper bound
    % combFreq: the frequency gap of the expected comb structure
    % offset: the offset of the comb structure
    % whetherToMark: whether to mark the frequencies with text. If the gap
    % is too small, better not since they covers each other.
    
    channels = textread(channelPath, '%s', 'delimiter', '\n');
    folder = what(dataPath);
    plotsFolderName = strcat(num2str(numel(channels)), '_outlier_plots_', num2str(lowFreq), '_', num2str(highFreq));
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
            disp(strcat(channels(chni), ': low index ', num2str(ih) ,' exceeds ', num2str(size(coh, 1)), '. Empty.'));
            ih = 1;
            il = 1;
        elseif ih > size(coh, 1)
            disp(strcat(channels(chni), ': high index ', num2str(ih) ,' exceeds ', num2str(size(coh, 1)), '. Ranged Chopped.'));
            ih = size(coh, 1);
        end
        fp = freqs(il : ih);
        cp = coh(il : ih);        
        % plot the mark lines
        [~, name, ~] = fileparts(fullPath);
        figure1 = figure;
        set(figure1, 'Visible', 'off');
        axes1 = axes('Parent', figure1);
        hold(axes1, 'all');
        markerPostions=ceil(lowFreq / combFreq) * combFreq : combFreq : floor(highFreq / combFreq) * combFreq; %your point goes here
        yl = max(cp);
        for i = 1 : length(markerPostions)
            line([markerPostions(i) markerPostions(i)],[0, yl], 'LineStyle', '-.', 'Color',[1 0 0], 'LineWidth', 0.1);
            if whetherToMark
                text(markerPostions(i), yl, strcat(num2str(markerPostions(i)), '(', num2str(i), ')'), 'FontSize', 5);
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
    end
end

