function [r, u, v, T, isBar] = getdetectorNew(site, azDeg)
%
% GETDETECTORNEW -- a modified version of getdetector for L1, H1, H2
% get detector geometry structure for major detector
%
%  The output is in the form of a structure with the fields
%      r: [3x1 double] %  position vector (in units of meters)
%                         in Earth-based Cartesian coordinates
%      u: [3x1 double] %  unit vector along x-arm of detector
%                         in Earth-based Cartesian coordinates
%      v: [3x1 double] %  unit vector along y-arm of detector
%                         in Earth-based Cartesian coordinates
%      T:              %  arm length measured in light propagation
%                         time (in units of seconds)
%
%  Routine written by Joseph D. Romano and John T. Whelan.
%  Contact john.whelan@ligo.org
%  $Id: getdetectorNew.m,v 1.1 2008-12-17 21:54:04 joe Exp $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c = 299792458;   % speed of light (m/s)
isBar = false;

switch site

  case 'L1'
    % LIGO Livinston 4km (Livingston, Louisiana, USA)

    if (nargin ~= 1)
      error('Cannot specify orientation of IFO\n');
    end

    loc  = createlocation( 30+(33+46.4196/60)/60 , ...
			  - (90+(46+27.2654/60)/60) , ...
   			  -6.574 );
    xarm = createorientation(180+72.2835, -3.121e-4*180/pi);
    yarm = createorientation(180-17.7165, -6.107e-4*180/pi);
    r = getcartesianposition(loc);
    u = getcartesiandirection(xarm, loc);
    v = getcartesiandirection(yarm, loc);
    T = 3995.08/c;

  case 'H1'
    % LIGO Hanford 4km (Hanford, Washington, USA)

    if (nargin ~= 1)
      error('Cannot specify orientation of IFO\n');
    end

    loc  = createlocation( 46+(27+18.528/60)/60 , ...
			  - (119+(24+27.5657/60)/60) , ...
			  142.554);
    xarm = createorientation(-35.9994, -6.195e-4*180/pi);
    yarm = createorientation(180+54.0006, 1.25e-5*180/pi);
    r = getcartesianposition(loc);
    u = getcartesiandirection(xarm, loc);
    v = getcartesiandirection(yarm, loc);
    T = 3995.08/c;

  case 'H2'
    % LIGO Hanford 2km (Hanford, Washington, USA)

    if (nargin ~= 1)
      error('Cannot specify orientation of IFO\n');
    end

    loc  = createlocation( 46+(27+18.528/60)/60 , ...
			  - (119+(24+27.5657/60)/60) , ...
			  142.554);
    xarm = createorientation(-35.9994, -6.195e-4*180/pi);
    yarm = createorientation(180+54.0006, 1.25e-5*180/pi);
    r = getcartesianposition(loc);
    u = getcartesiandirection(xarm, loc);
    v = getcartesiandirection(yarm, loc);
    T = (3995.08/2)/c;

  case 'V1'
    % VIRGO (Cascina/Pisa, Italy)

    if (nargin ~= 1)
      error('Cannot specify orientation of IFO\n');
    end

    loc  = createlocation(43 + (37 + 53.0921/60)/60 , ...
                          10 + (30 + 16.1878/60)/60 , ...
                          51.884);
    xarm = createorientation(90-70.5674);
    yarm = createorientation(90-160.5674);
    r = getcartesianposition(loc);
    u = getcartesiandirection(xarm, loc);
    v = getcartesiandirection(yarm, loc);
    T = (3000)/c;

  case 'AX'
    % ALLEGRO X-ARM (Baton Rouge, Louisiana, USA)

    if (nargin == 1)
      azDeg = -40;
    end

    loc = createlocation(30+(24+45.110/60)/60, ...
                         - (91+(10+43.766/60)/60) );
    azDeg = -108;
    axis = struct('az',azDeg*pi/180,'alt',0);
    r = getcartesianposition(loc);
    u = getcartesiandirection(axis,loc);
    v = getcartesiandirection(axis,loc);
    T = 0;

    isBar = true;

  case 'AY'
    % ALLEGRO Y-ARM (Baton Rouge, Louisiana, USA)

    if (nargin == 1)
      azDeg = -40;
    end

    loc = createlocation(30+(24+45.110/60)/60, ...
                         - (91+(10+43.766/60)/60) );
    azDeg = -18;
    axis = struct('az',azDeg*pi/180,'alt',0);
    r = getcartesianposition(loc);
    u = getcartesiandirection(axis,loc);
    v = getcartesiandirection(axis,loc);
    T = 0;

    isBar = true;

  case 'AN'
    % ALLEGRO NULL (Baton Rouge, Louisiana, USA)

    if (nargin == 1)
      azDeg = -40;
    end

    loc = createlocation(30+(24+45.110/60)/60, ...
                         - (91+(10+43.766/60)/60) );
    azDeg = -63;
    axis = struct('az',azDeg*pi/180,'alt',0);
    r = getcartesianposition(loc);
    u = getcartesiandirection(axis,loc);
    v = getcartesiandirection(axis,loc);
    T = 0;

    isBar = true;

  case 'default'

    r = [0; 0; 0];
    u = [1; 0; 0];
    v = [0; 1; 0];
    T = 3995.08/c;

  otherwise
    error('unrecognized detector site');

end

return
