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
			disp(strcat('Comb:',num2str(obj.low), '#', num2str(obj.high), '#', num2str(obj.comb)));
		end
	end
end
