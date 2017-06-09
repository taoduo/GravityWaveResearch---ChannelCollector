classdef Search
	% Search configurations
	properties
		zoom, % the x-axis range of the plot, centerd at the single line. One-sided.
		filter, % filter thresold
		selected_weeks % the weeks selected, as array, in folder names. Empty to select all.
	end
	methods
		function obj = Search(zoom, filter, selected_weeks)
			obj.zoom = zoom;
			obj.filter = filter;
			if nargin == 2
				obj.selected_weeks = [];
			end
			if nargin == 3
				obj.selected_weeks = selected_weeks;
			end
		end

		function [fp, cp] = chopData(obj, data_path, freqs, coh, line)
			freqGap = freqs(2) - freqs(1);
			low = line.line - obj.zoom;
			high = line.line + obj.zoom;
			il = floor(low / freqGap) + 1;
			ih = ceil(high / freqGap) + 1;
			if il > length(coh) % no data is in the search range
				disp(strcat(data_path, ' out of range. Skipped.'));
				fp = false;
				cp = false;
				return;
			elseif ih > length(coh)
				disp(strcat(data_path, ' range chopped.'));
				ih = length(coh);
			end
			fp = freqs(il : ih);
			cp = coh(il : ih);
		end

		function dump(obj)
			disp(strcat('Zoom: ', num2str(obj.zoom), '#', num2str(obj.filter)));
			if length(obj.selected_weeks) == 0
				disp('All weeks selected.');
			else
				disp('Weeks selected:');
				for w = obj.selected_weeks
					disp(w);
				end
			end
		end
	end
end
