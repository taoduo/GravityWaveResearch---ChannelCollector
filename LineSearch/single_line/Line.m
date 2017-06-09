classdef Line
	% Line configurations
	properties
		line,
		resolution
	end
	methods
		function obj = Line(line, resolution)
			if nargin == 1
				obj.line = line;
				obj.resolution = 0.001;
			end
			if nargin == 2
				obj.line = line;
				obj.resolution = resolution;
			end
		end

		function dump(obj)
			disp(strcat('Line:', num2str(obj.line), '# Resolution:', num2str(obj.resolution)));
		end
	end
end
