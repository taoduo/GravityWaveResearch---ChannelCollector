% SUSPR - Thermal noise for quadruple pendulum
%  switches to various suspension types based on
%    ifo.Suspension.Type
%  the general case calls the suspTYPE function to generate TFs

function noise = suspR(f, ifo)

  % Assign Physical Constants
  kB    = ifo.Constants.kB;
  Temp  = ifo.Suspension.Temp;
  
  % and vertical to beamline coupling angle
  theta = ifo.Suspension.VHCoupling.theta;

  noise = zeros(1,numel(f));
  if numel(Temp)==1 % if the temperature is uniform along the suspension    
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Suspension TFs
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      hForce = ifo.Suspension.hForce;
      vForce = ifo.Suspension.vForce;

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Thermal Noise Calculation
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      % convert to beam line motion
      %  theta is squared because we rotate by theta into the suspension
      %  basis, and by theta to rotate back to the beam line basis
      dxdF = hForce + theta^2 * vForce;

      % thermal noise (m^2/Hz) for one suspension
      w      = 2*pi*f;
      noise  = 4 * kB * Temp * abs(imag(dxdF)) ./ w;

  else % if the temperature is set for each suspension stage
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Suspension TFs
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      hForce = ifo.Suspension.hForce_singlylossy(:,:);
      vForce = ifo.Suspension.vForce_singlylossy(:,:);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Thermal Noise Calculation
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      for ii = 1:numel(Temp)
        % add up the contribution from each stage
          
        % convert to beam line motion
        %  theta is squared because we rotate by theta into the suspension
        %  basis, and by theta to rotate back to the beam line basis
        dxdF(ii,:) = hForce(ii,:) + theta^2 * vForce(ii,:);

        % thermal noise (m^2/Hz) for one suspension
        w = 2*pi*f;
        noise = noise + 4 * kB * Temp(ii) * abs(imag(dxdF(ii,:))) ./ w;
      end
      
  end
  
  % turn into gravitational wave strain; 4 masses
  noise = 4 * noise / ifo.Infrastructure.Length.^2;      

end
