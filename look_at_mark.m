function look_at_mark( data_path, high, low, mark_pos, output_path )
% LOOK_AT_MARK look at the channel data at data_path in range low, high,
% mark mark_pos and save plot at output_path
    freqs = [];
    coh = [];
    load(data_path);
    % chop the data between the two frequencies
    freqGap = freqs(2) - freqs(1); % sample the first two data to get the gap
    il = floor(low / freqGap) + 1;
    ih = ceil(high / freqGap) + 1;
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
   
    
    % plot and save
    [~, name, ~] = fileparts(data_path);
    figure1 = figure;
    set(figure1, 'Visible', 'off');
    axes1 = axes('Parent', figure1);
    hold(axes1, 'all');
    % plot the mark line
    yl = max(cp);
    line([mark_pos mark_pos],[0, yl], 'LineStyle', '-.', 'Color',[1 0 0], 'LineWidth', 0.1);
    text(mark_pos, yl, num2str(mark_pos), 'FontSize', 5);
    % get the plots
    plot(fp, cp);
    t = title(name);
    set(t, 'interpreter', 'none');
    xlabel('Frequency (Hz)');
    ylabel('Coherence');
    xlim([low, high]);
    grid on;
    saveas(figure1, output_path);

end

