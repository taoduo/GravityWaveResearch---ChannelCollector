function output(channel_name, freqs, coh, search, comb, markPos, output_path)
	% plot the data and save the plot
	% channels_name: name for title of plot
	% freqs: frequencies of the data
	% coh: coherence of the data, corresponding to freqs
	% search: configurations of this search (high / low /filter)
	% comb: parameters of the comb	% path: where the plot is saved, down to /channel.jpg
	% markPos: the positions of the lines to mark
	% output_path: the output path down to the jpg image

	% init the figure
	[~, name, ~] = fileparts(fullPath);
	figure1 = figure;
	set(figure1, 'Visible', 'off');
	axes1 = axes('Parent', figure1);
	hold(axes1, 'all');

	% plot the mark lines
	yl = max(coh);
	for i = 1 : length(markerPos)
			line([markerPos(i) markerPos(i)],[0, yl], 'LineStyle', '-.', 'Color',[1 0 0], 'LineWidth', 0.1);
	end

	% plot the data lines
	hold on;
	plot(fp, cp);
	t = title(channel_name);
	set(t, 'interpreter', 'none');
	xlabel('Frequency (Hz)');
	ylabel('Coherence');
	xlim([search.low, search.high]);
	grid on;
	saveas(figure1, output_path);
	% clear & close to avoid memory overflow
	clear all force;
	close all force;
end
