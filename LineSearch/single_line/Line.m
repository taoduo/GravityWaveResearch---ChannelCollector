classdef Line
	% Line configurations
	properties
		line, % frequency of the line in Hz
        run, % the LIGO run of the line when it is found
        observatory, % the observatory where it is found
		resolution % the resolution of the line, 1mHz by default
	end
	methods
		function obj = Line(line, run, observatory, resolution)
            if nargin == 0
               obj.line = 0;
               obj.run = '';
               obj.observatory = '';
               obj.resolution = 0;
               return
            end
            obj.line = line;
            obj.run = run;
            obj.observatory = observatory;
			if nargin == 3
				obj.resolution = 0.001;
			end
			if nargin == 4
				obj.resolution = resolution;
			end
		end

		function dump(obj)
			disp(strcat('Line:', num2str(obj.line), '# Resolution:', num2str(obj.resolution)));
		end
	end
end
