function varargout = gwinc(flo, fhi, ifoin, sourcein, varargin)
% GWINC   Calculates strain noise due to various noise sources, for a
% specified set of interferometer parameters. Also evaluates the
% sensitivity of the interferometer to the detection of several potential 
% gravitational wave sources. Usage:
%
%      VARARGOUT = GWINC(FLO,FHI,IFO,SOURCE,VARARGIN)
%
%      FLO, FHI = minimum and maximum frequencies between which
%                  calculations are made
%                  If one is a vector, and the other empty,
%                  the vector is used for calculations.
%      IFO       = structure containing interferometer parameters
%      SOURCE    = structure containing source parameters
%
% Optional input arguments (the last 4 override IFO parameters):
%      VARARGIN{1}: PLOT_FLAG set to 4 for score, only calculating shotrad
%                                    3 for score and plots
%                                    2 for score only
%                                    1 to make plots but no score
%                                    else 0 (DEF)
%      VARARGIN{2}: LASER POWER -> ifo.Laser.Power
%      VARARGIN{3}: SRC PHASE   -> ifo.Optics.SRM.Tunephase
%      VARARGIN{4}: SRM TRANS   -> ifo.Optics.SRM.Transmittance
%      VARARGIN{5}: ITM TRANS   -> ifo.Optics.ITM.Transmittance
%      VARARGIN{6}: PRM TRANS   -> ifo.Optics.PRM.Transmittance
%      VARARGIN{7}: HOMO PHASE  -> ifo.Optics.Quadrature.dc
%
% Optional output arguments
%      VARARGOUT{1}: SCORE  structure containing source sensitivities
%      VARARGOUT{2}: NOISE  structure containing noise terms
%      VARARGOUT{3}: IFO  structure containing IFO model (arg with precomp)
%      VARARGOUT{4}: SOURCE  structure containing source model (= arg)
%
% Ex.1    [score,noise] = gwinc(5,5000,IFOModel,SourceModel,1)
%
% OR, just specify the IFO model and take default FLO, FHI, and SOURCE
%
%      VARARGOUT = GWINC()          % use default IFOModel
%      VARARGOUT = GWINC(ifo)       % use specified IFOModel struct
%      VARARGOUT = GWINC(ifo_name)  % call IFOModel_<ifo_name> to get model
%
% Ex.2    gwinc             % make plot using IFOModel.m
% Ex.3    gwinc(myIFO)      % use the given IFO model
% Ex.4    gwinc('sqz')      % call IFOModel_sqz.m to make IFO model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse Arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set default options
fig = 0;
makescore = 0;
modeSR = 0;

% PRfixed: set to 1 for a fixed PRM transmission; 0 to allow optimization,
% which occurs in BSPower.m
PRfixed = 1;   

% 0 or 1 arguments
if nargin == 0
  flo = 5;
  fhi = 5000;
  ifoin = IFOModel;        % default IFO model
  sourcein = SourceModel;  % default source model
  varargin{1} = 3;         % plot and score
  plotTitle = 'aLIGO';
elseif nargin < 3 && (ischar(flo) || isstruct(flo))
  % specified IFO model
  if ischar(flo)
    plotTitle = flo;       % use given name
    ifoin = feval(['IFOModel_', flo]);
  else
    plotTitle = 'aLIGO';   % what else?
    ifoin = flo;
  end
  flo = 5;                 % replace flo with default
  sourcein = SourceModel;
  varargin{1} = 3;         % plot and score  
  
  % frequency vector?
  if nargin == 2
    if numel(fhi) > 1
      flo = [];
    end
  else
    fhi = 5000;            % default fhi
  end
elseif (nargin >= 4)
  plotTitle = 'aLIGO';  % what else?
else
  error('usage: gwinc(flo,fhi,ifo,source,...);');
end

% avoid modifying arguments
ifo = ifoin;
source = sourcein;

% Parse varargin to decide to make plots or scores or both or neither
if (numel(varargin) > 0)
  if varargin{1} > 1
    makescore = 1;
  end
  if (varargin{1} == 1 || varargin{1} == 3)
    fig = 1;
  end
  if varargin{1} == 4
    modeSR = 1;
  end
end

% Adjust these parameters as command line arguments
if nargin > 5
   ifo.Laser.Power = varargin{2};
end
if nargin > 6
  ifo.Optics.SRM.Tunephase = varargin{3};
end
if nargin > 7
  ifo.Optics.SRM.Transmittance  = varargin{4};
end
if nargin > 8
  ifo.Optics.ITM.Transmittance  = varargin{5};
end
if nargin > 9
  PRfixed = 1;
  ifo.Optics.PRM.Transmittance  = varargin{6};
end
if nargin > 10
    ifo.Optics.Quadrature.dc = varargin{7};
end
if nargin > 11
  error('Too many arguments to gwinc')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add some derived values to the ifo struct
% (this should not require the frequency vector)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ifo = precompIFO(ifo, PRfixed);

% extract some precomputed power levels
pbs      = ifo.gwinc.pbs;
finesse  = ifo.gwinc.finesse;
prfactor = ifo.gwinc.prfactor;
armpower = ifo.gwinc.parm / 1000; % kW

% compute thermal lens
PowAbsITM = [finesse*(2/pi)*ifo.Optics.ITM.CoatingAbsorption/2; ...
             ifo.Materials.MassThickness*ifo.Optics.SubstrateAbsorption/2]*pbs;
ifo.TCS.M = [ifo.TCS.s_cc ifo.TCS.s_cs;...
             ifo.TCS.s_cs ifo.TCS.s_ss];         
S_uncorr = transpose(PowAbsITM)*ifo.TCS.M*PowAbsITM;         
TCSeff = 1 - sqrt(ifo.TCS.SRCloss/S_uncorr);
thermalLoad.ITM = sum(PowAbsITM);
thermalLoad.BS = ifo.Materials.MassThickness * ifo.Optics.SubstrateAbsorption * pbs;

if (ifo.Laser.Power*prfactor ~= pbs)
  disp(sprintf('Warning: lensing limits input power to %7.2f W',...
  		pbs/prfactor));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency vector on which everything is calculated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isscalar(flo) && isscalar(fhi)
  f = logspace(log10(flo),log10(fhi),3000);
elseif isvector(flo) && isempty(fhi)
  f   = flo(:)';
  flo = f(1);
  fhi = f(end);
elseif isvector(fhi) && isempty(flo)
  f   = fhi(:)';
  flo = f(1);
  fhi = f(end);
else
  error('flo and fhi must either be scalars, or one vector and one empty')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Suspension Type Switch (requires frequency vector)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch ifo.Suspension.Type
  
  % quad cases, for backward compatability
  case {0, 1, 2}
    [hForce, vForce, hTable, vTable] = suspQuad(f, ifo);
    
    % general case
  otherwise
    fname = ['susp' ifo.Suspension.Type];
    [hForce, vForce, hTable, vTable] = feval(fname, f, ifo);
end

if isstruct(hForce) % if the suspension code supports different temps for the stages
  
  % full TF (conventional)
  ifo.Suspension.hForce = hForce.fullylossy;
  ifo.Suspension.vForce = vForce.fullylossy;
  
  % TFs with each stage lossy
  ifo.Suspension.hForce_singlylossy = hForce.singlylossy;
  ifo.Suspension.vForce_singlylossy = vForce.singlylossy;
  
else % if not
  
  ifo.Suspension.hForce = hForce;
  ifo.Suspension.vForce = vForce;
  
end

ifo.Suspension.hTable = hTable;
ifo.Suspension.vTable = vTable;

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute all noise sources and sum for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Physical constants
c    = ifo.Constants.c;
MSol = ifo.Constants.MSol;
Mpc  = ifo.Constants.Mpc;
yr   = ifo.Constants.yr;

% global noise source struct can be used with plot option = 4
%   modeSR = 0 => compute all noises and store them in nse
%   modeSR other => compute only quantum noise, use old nse for others
global nse

% Compute noises
y1 = shotrad(f,ifo);
switch modeSR
case 0
 y3  = suspR(f, ifo);
 y4  = gas(f,ifo);
 y5  = subbrownian(f,ifo);                      % substrate Brownian
 y6  = coatbrownian(f,ifo);                     % Coating Brownian
 y8  = subtherm(f,ifo);                         % substrate thermo-elastic
 y9  = gravg(f,ifo);
 y10 = seismic(f,ifo);
 y11 = thermooptic(f,ifo);                     % coating thermo-optic (TE + TR)
 % adjust noise curves for multiple bounces - for resonant delay lines
 % Brownian noise scales as Neff (correlation-corrected spot number)
 % Displacement noises scale as N^2
 % Thermo-optic noise scales as N (incoherent between spots)
 if isfield(ifo.Infrastructure,'NFolded')
     if ifo.Infrastructure.travellingWave
         N=ifo.Infrastructure.NFolded;
         sep_w=ifo.Infrastructure.DelayLineSpotSeparation;
         Neff=getBrownianCorrelationFactor(N,sep_w);
         y3 =y3 *N^2;
         y5 =y5 *Neff;
         y6 =y6 *Neff;
         y8 =y8 *N^2;
         y9 =y9 *N^2;
         y10=y10*N^2;
         y11=y11*N;
     else
         N=ifo.Infrastructure.NFolded;
         sep_w=ifo.Infrastructure.DelayLineSpotSeparation;
         Neff=getBrownianCorrelationFactorStandingWave(N,sep_w);
         Ndispl=(2*N-1);
         N_TO=4*N-3; % use naive counting, needs improvement
         y3 =y3 *Ndispl^2;
         y5 =y5 *Neff;
         y6 =y6 *Neff;
         y8 =y8 *Ndispl^2;
         y9 =y9 *Ndispl^2;
         y10=y10*Ndispl^2;
         y11=y11*N_TO;
     end
 end
 y2 = y5 + y6 + y8 + y11;                      % total mirror thermal 
otherwise
%  y3 = nse.SuspThermal;
%  y4 = nse.ResGas;
%  y5 = nse.MirrorThermal.SubBrown;              % substrate Brownian
%  y6 = nse.MirrorThermal.CoatBrown;             % Coating Brownian
%  y8 = nse.MirrorThermal.SubTE;                 % substrate thermo-elastic
%  y9 = nse.Newtonian;
%  y10 = nse.Seismic;
%  y11 = nse.MirrorThermal.CoatTO;               % coating thermo-optic
%  y2 = nse.MirrorThermal.Total;                 % total mirror thermal 
end
ys = y1 + y2 + y3 + y4 + y9 + y10;             % sum of noise sources


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Graphics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (fig ~= 0)
  % Report input parameters
  fprintf('Laser Power:            %7.2f Watt\n',ifo.Laser.Power);
  fprintf('SRM Detuning:           %7.2f degree\n',ifo.Optics.SRM.Tunephase*180/pi);
  fprintf('SRM transmission:       %9.4f\n',ifo.Optics.SRM.Transmittance);
  fprintf('ITM transmission:       %9.4f\n',ifo.Optics.ITM.Transmittance);
  fprintf('PRM transmission:       %9.4f\n',ifo.Optics.PRM.Transmittance);

  hndls = loglog(f,sqrt(y1),'-',...         % Quantum Unification  
                 f,sqrt(y10),'-',...        % Seismic
                 f,sqrt(y9),'-',...         % Newtonian Gravity
                 f,sqrt(y3),'-',...         % Suspension thermal
                 f,sqrt(y6),'-',...         % Coating Brownian
                 f,sqrt(y11),'--',...       % Coating thermooptic
                 f,sqrt(y5),'--',...        % Substrate brownian
                 f,sqrt(y4),'--',...        % Gas
                 f,sqrt(ys),'k');            % Total Noise
  set(hndls(1:(end)),'LineWidth',5);
  leggravg = strcat('Newtonian background(\beta=',num2str(ifo.Seismic.Beta),')');
  legpower = [num2str(ifo.Laser.Power,'%3.1f') ' W'];
  legend('Quantum',...
         'Seismic',...
         'Newtonian',...
         'Suspension Thermal',...
         'Coating Brownian',...
         'Coating Thermo-optic',...
         'Substrate Brownian',...
         'Excess Gas',...
         'Total noise',...
         'Location','NorthEast');
  xlabel('Frequency [Hz]','FontSize',24);
  ylabel('Strain [1/\surdHz]','FontSize',24);
  grid on
  
  % set axis limits
  amin = 10^(round(2 * log10(min(sqrt(ys))) + 0.2) / 2 - 1);
  amax = amin * 3000;
  axis([flo fhi amin amax]);
  title([plotTitle ' Noise Curve: P_{in} = ' legpower],'FontSize',18)  
  
  % set color table
  clrtable=[0.7   0.0   0.9
            0.6   0.4   0.0
            0.0   0.8   0.0
            0.3   0.3   1.0
            1.0   0.2   0.1
            0.0   1.0   0.9
            1.0   0.7   0.0
            0.8   1.0   0.0
            1.0   0.0   0.0
            0.6   0.6   0.6];
  for gag = 1:(length(hndls) - 1)
    set(hndls(gag), 'color',clrtable(gag,:));
  end  
end


if (nargout > 0)
  varargout{1} = 0;
end
switch modeSR
case 0
  nse.ResGas      = y4;
  nse.SuspThermal = y3;
  nse.Quantum     = y1;
  nse.Freq        = f;
  nse.Newtonian   = y9;
  nse.Seismic     = y10;
  nse.Total       = ys;
  nse.MirrorThermal.Total = y2;
  nse.MirrorThermal.SubBrown = y5;
  nse.MirrorThermal.CoatBrown = y6;
  nse.MirrorThermal.SubTE = y8;
  nse.MirrorThermal.CoatTO = y11;
otherwise
  nse.Quantum     = y1;
  nse.Total       = ys;
end

if (nargout > 1)
  varargout{2}    = nse;
end
if (nargout > 2)
%   parout.finesse = finesse;
%   parout.prfactor = prfactor;
%   parout.armpower = armpower;
%   parout.bspower = pbs;
%   parout.bsthermload = thermalLoad.BS;
%   parout.itmthermload = thermalLoad.ITM;
%   parout.ifo = ifo;
%  
%  varargout{3} = parout;
  varargout{3} = ifo;
end
if (nargout > 3)
  varargout{4} = source;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Report astrophysical scores if so desired
if (makescore == 1)
  sss = int73(nse.Freq, nse.Total, ifo, source);
  sss.Omega = intStoch(nse.Freq, nse.Total, 0, ifo, source);
  if nargout > 0
    varargout{1} = sss;
  end  
end

% Report finesse, power recycling factors
if ( fig > 0 )
  
  disp(sprintf('Finesse:                %7.2f', finesse));
  disp(sprintf('Power Recycling Factor: %7.2f', prfactor))
  disp(sprintf('Arm power:              %7.2f kW', armpower));
  disp(sprintf('Power on beam splitter: %7.2f kW', pbs / 1000))
  PowAbsITM = [finesse*2/pi*ifo.Optics.ITM.CoatingAbsorption/2;...
               ifo.Materials.MassThickness*ifo.Optics.SubstrateAbsorption/2 ]*pbs;
  M=[ifo.TCS.s_cc,ifo.TCS.s_cs;ifo.TCS.s_cs,ifo.TCS.s_ss];
  S_uncorr=transpose(PowAbsITM)*M*PowAbsITM;
  TCSeff=1-sqrt(ifo.TCS.SRCloss/S_uncorr);
  disp(sprintf('Thermal load on ITM:    %8.3f W', sum(PowAbsITM) ));
  disp(sprintf('Thermal load on BS:     %8.3f W',     ifo.Materials.MassThickness*ifo.Optics.SubstrateAbsorption    *pbs));
  %disp(sprintf(['Reqired TCS efficiency: %8.3f' ...
  %              '(estimate, see IFOModel.m for definition)'],    TCSeff));  
  if (ifo.Laser.Power*prfactor ~= pbs)
    disp(sprintf('Lensing limited input power: %7.2f W',pbs/prfactor));
  end

  if makescore == 1
    if sss.NeutronStar.horizonZ < 0.5
      disp(sprintf('BNS range:              %7.2f Mpc (comoving)', ...
                   sss.NeutronStar.comovingRangeMpc))
      disp(sprintf('BNS horizon:            %7.2f Mpc (comoving)', ...
                   sss.NeutronStar.advanced.comovingHorizonMpc))
      disp(sprintf('BNS reach:              %7.2f Mpc (comoving)', ...
                   sss.NeutronStar.advanced.comovingReachMpc))
    else
      disp(sprintf('BNS range:              %7.2f Gpc (comoving, z = %2.1f)', ...
        sss.NeutronStar.comovingRangeMpc / 1000, sss.NeutronStar.advanced.rangeZ))
      disp(sprintf('BNS horizon:            %7.2f Gpc (comoving, z = %2.1f)', ...
        sss.NeutronStar.advanced.comovingHorizonMpc / 1000,sss.NeutronStar.horizonZ))
      disp(sprintf('BNS reach:              %7.2f Gpc (comoving, z = %2.1f)', ...
        sss.NeutronStar.advanced.comovingReachMpc / 1000,sss.NeutronStar.reachZ))
    end

    if sss.BlackHole.horizonZ < 0.5
      disp(sprintf('BBH range:              %7.2f Mpc (comoving)', ...
                   sss.BlackHole.comovingRangeMpc))
      disp(sprintf('BBH horizon:            %7.2f Mpc (comoving)', ...
                   sss.BlackHole.advanced.comovingHorizonMpc))
      disp(sprintf('BBH reach:              %7.2f Mpc (comoving)', ...
                   sss.BlackHole.advanced.comovingReachMpc))
    else
      disp(sprintf('BBH range:              %7.2f Gpc (comoving, z = %2.1f)', ...
        sss.BlackHole.comovingRangeMpc / 1000, sss.BlackHole.advanced.rangeZ))
      disp(sprintf('BBH horizon:            %7.2f Gpc (comoving, z = %2.1f)', ...
        sss.BlackHole.advanced.comovingHorizonMpc / 1000,sss.BlackHole.horizonZ))
      disp(sprintf('BBH reach:              %7.2f Gpc (comoving, z = %2.1f)', ...
        sss.BlackHole.advanced.comovingReachMpc / 1000,sss.BlackHole.reachZ))
    end
      disp(sprintf('Stochastic Omega:          %4.3g',sss.Omega)) 
  end  
end

return

