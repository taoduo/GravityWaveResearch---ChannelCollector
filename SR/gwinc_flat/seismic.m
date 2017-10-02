function varargout = seismic(f,ifo)
% SEISMIC - seismic noise psd at frequencies f for given ifo.
%   n = seismic(f,ifo)
%   [nh,nv] = seismic(f,ifo)
%   [n,nh,nv] = seismic(f,ifo)
%
% Modified to include realistic SEI + SUS models (Rana, 11/2005)

  % Interpolate the log10 onto the ifo frequency array
%   n = interp1(ifo.Seismic.darmseis_f, ...
%     log10(ifo.Seismic.darmseis_x), f, 'cubic', -30);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Suspension TFs
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  hTable = ifo.Suspension.hTable;
  vTable = ifo.Suspension.vTable;

  % and vertical to beamline coupling angle
  theta = ifo.Suspension.VHCoupling.theta;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % noise input, horizontal and vertical
  nx = seisBSC(f);

  % horizontal noise total
  nh = (abs(hTable).^2) .* nx.^2;

  % vertical noise total
  nv = (abs(theta * vTable).^2) .* nx.^2;

  % new total noise
  n = nv + nh;
  
  % Convert into Strain PSD (4 TMs)
  nh = 4 * nh / ifo.Infrastructure.Length^2;
  nv = 4 * nv / ifo.Infrastructure.Length^2;
  n  = 4 * n  / ifo.Infrastructure.Length^2;

  switch nargout
    case 1,
      varargout{1} = n;
    case 2,
      varargout{1} = nh;
      varargout{2} = nv;
    case 3,
      varargout{1} = n;
      varargout{2} = nh;
      varargout{3} = nv;
  end

end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [nx, np] = seisBSC(f)
%   get rough ISI noise source spectra
%
% nx - ISI translational DOFs
% np - ISI rotational DOFs

function [nx, np] = seisBSC(f)

  % translational DOFs (from Rana's bsc_seismic.m)
  SEI_F = [0.01 0.03 0.1 0.2 0.5 1 10 30 300];
  SEI_X = [3e-6 1e-6 2e-7 2e-7 8e-10 1e-11 3e-13 3e-14 3e-14];
  nx = 10.^(interp1(SEI_F,log10(SEI_X),f,'pchip',-14));
  
  % rotational DOFs
  SEI_P = [1e-8 3e-8 2e-8 1e-8 4e-10 1e-11 3e-13 3e-14 3e-14];
  np = 10.^(interp1(SEI_F,log10(SEI_P),f,'pchip',-14));
  
end
