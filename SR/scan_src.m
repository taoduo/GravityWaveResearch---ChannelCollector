function [optOmega, optTransmission, optPhase, optBNSRange] = scan_src(finenessTransmission, ...
    minTransmission, maxTransmission, finenessPhase, minPhase, maxPhase, varargin)
    % Scan to optimize the SRC parameters for stochasic search. Phase is in degrees.
    % Optionals:
    % varargin{1}: power
    % varargin{2}: .mat file to save the results. Empty not to save
    % varargin{3}: print results to file, not to terminal. Empty not to
    % save.
    % varargin{4}: lower frequency cutoff. Default at 10Hz.
    
    % fetch the optional parameters
    power = 125;
    saveResults = '';
    saveFileID = -1;
    cutoff = 10;
    if nargin == 6 + 1
        power = varargin{1};
    elseif nargin == 6 + 2
        power = varargin{1};
        saveResults = varargin{2};
    elseif nargin == 6 + 3
        power = varargin{1};
        saveResults = varargin{2};
        saveFileID = fopen(varargin{3},'a');
    elseif nargin == 6 + 4
        power = varargin{1};
        saveResults = varargin{2};
        saveFileID = fopen(varargin{3},'a');
        cutoff = varargin(4);
    end
    % initialize
    dataArray = zeros(int64(((maxTransmission - minTransmission) / finenessTransmission) ...
        * ((maxPhase - minPhase) / finenessPhase)), 4);
    n = 1;
    ifo = IFOModel;
    src = SourceModel;
    percentage = 0;
    % scanning...
    for transmission = minTransmission : finenessTransmission : maxTransmission
        for phase_deg = minPhase : finenessPhase : maxPhase
            try
                phase = deg2rad(phase_deg); % change to radian
                score = gwinc(cutoff, 3000, ifo, src, 2, power, phase, transmission);
                dataArray(n, :) = [transmission, phase_deg, score.NeutronStar.comovingRangeMpc, score.Omega];
                n = n + 1;
                if n / size(dataArray, 1) > percentage + 0.1
                    percentage = percentage + 0.1;
                    fprintf('%%%d DONE...\n', int32(percentage * 100));
                end
            catch e
                disp(e);
                fprintf('transmission:%f\tphase:%d\tERROR\n', transmission, phase_deg);
            end
        end
    end
    % find the optimal and print
    [~, opt_ind] = min(dataArray(:, 4));
    optOmega = dataArray(opt_ind, 4);
    optTransmission = dataArray(opt_ind, 1);
    optPhase = dataArray(opt_ind, 2);
    optBNSRange = dataArray(opt_ind, 3);
    if saveFileID == -1
        fprintf('%dW Stochastic Optimal Configurations:\n', power);
        fprintf('Transmission:%f\nPhase:%f\nOmega:%8.2E\nBNS Range:%f\n', optTransmission, ...
            optPhase, optOmega, optBNSRange);
    else
        fprintf(saveFileID, '%dW Stochastic Optimal Configurations:\n', power);
        fprintf(saveFileID, 'Transmission:%f\nPhase:%f\nOmega:%8.2E\nBNS Range:%f\n', optTransmission, ...
            optPhase, optOmega, optBNSRange);
        fprintf(saveFileID, '-------------------------\n');
        fclose(saveFileID);
    end
    % save results
    if ~strcmp(saveResults, '')
        save(saveResults, 'dataArray');
    end
end