classdef Comb
	% Comb configurations
	properties
		low,
		high,
		comb
	end
	methods
		function obj = Comb(low, comb, high)
			obj.low = low;
			obj.high = high;
			obj.comb = comb;
		end

		function pos = getLines(obj)
			pos = obj.low : obj.comb : obj.high;
		end

		function dump(obj)
			disp(['Comb:', obj.low, ' ', obj.high, ' ', obj.comb]);
		end
	end
end
