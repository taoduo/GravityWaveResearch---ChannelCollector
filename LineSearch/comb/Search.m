classdef Search
	% Search configurations
	properties
		low,
		high,
		filter
	end
	methods
		function obj = Search(low, high, filter)
			obj.low = low;
			obj.high = high;
			obj.filter = filter;
		end

		function [fp, cp] = chopData(obj, freqs, coh, data_path)
			freqGap = freqs(2) - freqs(1);
			il = floor(obj.low / freqGap) + 1;
			ih = ceil(obj.high / freqGap) + 1;
			if il > length(coh)
				disp(strcat(data_path, ' out of range. Skipped.'));
				il = false;
				ih = false;
			elseif ih > length(coh)
		    disp(strcat(data_path, ' range chopped.'));
				ih = length(coh);
			end
			fp = freqs(il : ih);
			cp = coh(il : ih);
		end

		function dump(obj)
			disp(strcat('Search: ', num2str(obj.low), '#', num2str(obj.high), '#', num2str(obj.filter)));
		end
	end
end
