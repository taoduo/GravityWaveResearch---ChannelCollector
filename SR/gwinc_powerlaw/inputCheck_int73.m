function  inputCheck_int73(cbcStruct)
%
% Just a little function to check inputs
% Trying to avoid code duplication
%

m1  = cbcStruct.Mass1;
m2  = cbcStruct.Mass2;
s1  = cbcStruct.Spin1;
s2  = cbcStruct.Spin2;

%Black holes don't have tidal effects
if isfield(cbcStruct, 'Tidal')
    tidal = cbcStruct.Tidal;
else
    tidal = 0;
end


%Some checking of inputs
switch cbcStruct.Waveform
    
  case 'Inspiral'
        if  (s1~=0 | s2~=0)%Spin is only included with IMR waveforms
        warning('calcHorizon:NoIMRSpin',['You are trying to use spin with a pure inspiral waveform. ' ...
                            'Spin effects will be ignored. Select an IMR waveform to include spin.'])
        
        end
        
  case 'IMRPhenomB'
        chi       = (m1 * s1 + m2 * s2) / (m1 + m2); % Spin parameter. Our s_i is Chi_i in Ajith2011
    q = m1/m2;
    if (q>10 | q<0.1 | abs(chi)>0.85)
        warning('IMRPhenomB:IMRParams','\nRecommended parameter range for IMRPhenomB is is 0.1<=q<=10, abs(chi)<0.85  (Ajith2011). You have q = %f, chi = %f.\n',q, chi)
    end
    
    if (abs(s1)>1 | abs(s2)>1) %Spin must lie between -1 and +1
        error('IMRPheonomB:IMRSpin','\nReduced spin must be in the range -1 to +1. You have s1 = %f, s2 = %f.\n',s1, s2)
    end
    
    
    if tidal%If you use IMR waveforms the tidal option does nothing
        warning('calcHorizon:IMRTidal','You have selected tidal option with an IMR waveform. Tidal disruption effects are not estimated when using imr waveforms. Ignoring tidal option.')
    end

  case 'IMRPhenomD'
    %Get more error checking
    warning('IMRPhenomD:Beta','\nUsing IMRPhenomD\nWORK IN PROGRESS - correct but slow.\n')
    q = m1/m2;

    if (q>5000)
        warning('IMRPhenomD:IMRParams','\nRecommended parameter range for IMRPhenomD waveforms is q<=5000, You have q = %f.\n',q)
    end

    if (abs(s1)>1 | abs(s2)>1) %Spin must lie between -1 and +1
        error('IMRPheonomD:IMRSpin','\nReduced spin must be in the range -1 to +1. You have s1 = %f, s2 = %f.\n',s1, s2)
    end
    
    M         = m1 + m2;
    eta       = m1 * m2 / M^2; % Symmetric mass ratio

    if (eta > 0.25 | eta < 0.0)
        error('IMRPheonomD:eta','\nEta must be in the range 0 to 0.25. You have eta = %f.\n',eta)
    end

    if tidal%If you use IMR waveforms the tidal option does nothing
        warning('calcHorizon:IMRTidal','You have selected both tidal option with an IMR waveform. Tidal disruption effects are not estimated when using imr waveforms. Ignoring tidal option.')
    end

end



