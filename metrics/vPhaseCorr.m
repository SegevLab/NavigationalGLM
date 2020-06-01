clear all;
networkName = '11025-19050503';
neuronNumber = 1;
load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuronNumber)]);

sampleRate = 1000;
numOfPhase = 30;
phaseBins = linspace(0, 2 * pi, numOfPhase);

numOfVoltage = 60;
voltageBins = linspace(-128, 128, numOfVoltage);



tuneMap = zeros(numOfVoltage - 1, numOfPhase - 1);
% find the mean firing rate in each position bin
for i  = 1:numOfVoltage - 1
    
    % Get current bin limits
    start_voltage = voltageBins(i);
    stop_voltage = voltageBins(i+1);
    
    % find the times the animal was in the bin
    if i == numOfVoltage - 1
        voltage_ind = find(theta >= start_voltage & theta <= stop_voltage);
    else
        voltage_ind = find(theta >= start_voltage & theta < stop_voltage);
    end
    
    % Run on the y axis
    for j = 1:numOfPhase - 1

        % Get current bin limits
        start_Phase = phaseBins(j);
        stop_Phase = phaseBins(j+1);
        
        % find the times the animal was in the bin
        if j == numOfPhase - 1
            phase_ind = find(phase >= start_Phase );
        else
            phase_ind = find(phase >= start_Phase & phase < stop_Phase);

        end
        % get intersection indexes of the time for current x and y bins
        ind = intersect(voltage_ind,phase_ind);
        
        tuneMap(i, j) = nanmean(spiketrain(ind));
        
    end
end
tuneMap(isnan(tuneMap)) = 0;
%Smooth the tuning curve
BIN = 3;
FilterSize=10; 
FilterSize=FilterSize/2;
ind = -FilterSize/BIN : FilterSize/BIN; % 
[X, Y] = meshgrid(ind, ind);
sigma=10.5; %in cm;
sigma=sigma/BIN;
% Create Gaussian Mask
h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));
% Normalize so that total area (sum of all weights) is 1
h = h / sum(h(:));

tuneMap = filter2(h,tuneMap);

imagesc(phaseBins,voltageBins, tuneMap * sampleRate)
colorbar;
colormap jet;
xlabel('Phase');
ylabel('voltage');