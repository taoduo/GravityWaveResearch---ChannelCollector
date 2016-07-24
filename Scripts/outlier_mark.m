function outlier_mark(channelPath, dataPath, lowFreq, highFreq, multiplier)
    % Plot the data of certain channels in a range of frequencies and mark the frequency of outliers 
    % channelPath: the path to a txt with all the channels to look at
    % dataPath: the path to the mat files
    % lowFreq: the low thresold of the frequency range
    % highFreq: the high thresold of the frequency range
    % multiplier: how many times a line is higher than the average to be
    % considered an outlier
    
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
        
        % plot
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
        plot(fp, cp);
        
        % add the labels
        avg = mean(coh);
        thresold = avg * multiplier;
        moreThanThres = cp > thresold;
        over_freq = double(fp(moreThanThres));
        over_coh = cp(moreThanThres);
        
        % label the peaks
        % ******* You may need to adjust this parameter each time *******
        % I did not make this a parameter since this is not something that
        % can be easily determined. Needs experiment.
        [label_coh, label_loc] = findpeaks(over_coh, 'MinPeakDistance', 10);
        
        label_freq = over_freq(label_loc);
        over_label = {};
        for fi = 1 : numel(label_freq)
            over_label = [over_label, num2str(label_freq(fi))];
        end
        hold on;
        plot(over_freq, over_coh, 'r*', 'LineWidth', 1, 'MarkerSize', 5);
        text(label_freq, label_coh, over_label, 'FontSize', 5);
        saveas(figure1, strcat(plotsFolderName, '/', name, '.jpg'));
    end
    
end