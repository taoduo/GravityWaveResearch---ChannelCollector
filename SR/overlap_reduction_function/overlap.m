function orf = overlap(f, det1, det2, michelson, fabryperot, resolution, ...
                       isBar1, isBar2)
%
% Input:
%   f: frequency array
%   det1, det2: 'L1', 'H1', 'H2'
%   michelson: 'lw', '1st', 'exact'
%   fabryperot: 'id', 'cp', 'fp'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c = 299792458;   % speed of light (m/s)

try, isBar1; catch, isBar1=false; end;
try, isBar2; catch, isBar2=false; end;

% get angles from healpix pixelization of the sky
pixelfile = ['pixelization_' num2str(resolution) '.dat'];
[theta,phi]=healpix2ang(pixelfile);
Npix = length(theta);
dArea = 4*pi/Npix;

% get detector geometry information
[r1, u1, v1, T1] = getdetectorNew(det1);
[r2, u2, v2, T2] = getdetectorNew(det2);
deltaX = r1-r2;

% construct overlap reduction function
orf = zeros(1,length(f));

for ii = 1:1:Npix
   fprintf('working on %d of %d\n', ii, Npix);

   [F1p,F1c] = FpFc(f, theta(ii),  phi(ii), 0, u1, v1, T1, michelson, fabryperot, isBar1);
   [F2p,F2c] = FpFc(f, theta(ii),  phi(ii), 0, u2, v2, T2, michelson, fabryperot, isBar2);

   %H = (5/(8*pi)) * (conj(F1p).*F2p + conj(F1c).*F2c);
   H = (5/(8*pi)) * (F1p.*conj(F2p) + F1c.*conj(F2c));

   R = Ry(theta(ii)) * Rz(phi(ii));
   RdeltaX = R * deltaX;
   %kDotDeltaX = -RdeltaX(3);
   nDotDeltaX = RdeltaX(3);
    
   %phaseFac = 2*pi*f*kDotDeltaX/c;
   phaseFac = 2*pi*f*nDotDeltaX/c;
   orf = orf + H.*exp(sqrt(-1)*phaseFac)*dArea;

end

% plot overlap reduction function
figure(1);
plot(f, real(orf));

return
