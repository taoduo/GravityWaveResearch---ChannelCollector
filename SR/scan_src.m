function [optOmega, optTransmission, optPhase, optBNSRange] = scan_src(finenessTransmission, ...
    minTransmission, maxTransmission, finenessPhase, minPhase, maxPhase, varargin)
    addpath(genpath('/Users/duotao/Desktop/gw/git/SR/gwinc'));
    % Scan to optimize the SRC parameters for stochasic search. Phase is in degrees.
    % Optionals:
    % varargin{1}: power
    % varargin{2}: if to save results
    
    % fetch the optional parameters
    power = 125;
    saveResults = true;
    if nargin == 1
        power = varargin{1};
    elseif nargin == 2
        power = varargin{1};
        saveResults = varargin{2};
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
                score = gwinc(10, 3000, ifo, src, 2, power, phase, transmission);
                dataArray(n, :) = [transmission, phase_deg, score.NeutronStar.comovingRangeMpc, score.Omega];
                n = n + 1;
                if n / size(dataArray, 1) > percentage + 0.1
                    percentage = percentage + 0.1;
                    fprintf("%%%d DONE...\n", int32(percentage * 100));
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
    fprintf('Stochastic Optimal Configurations:\n');
    fprintf('Transmission:%f\nPhase:%f\nOmega:%8.2E\nBNS Range:%f', optTransmission, ...
        optPhase, optOmega, optBNSRange);
    % save results
    if saveResults
        save('results.mat', 'dataArray');
    end
end