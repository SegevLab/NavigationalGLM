function [metrics, psthExp, psthSim, ISI] = ...
    estimateModelPerformance(dt,expFiringRate, modelFiringRate, smoothingFilter, windowSize)

simulationLength = length(expFiringRate);
simNumOfSpikes = sum(modelFiringRate)
expNumOfSpikes = sum(expFiringRate)


psthLength = ceil(simulationLength / windowSize);
psthSim = zeros(psthLength, 1);
psthExp = zeros(psthLength, 1);

% Bin the spike rate (PSTH)
for j = 1:psthLength
    currentChange = min(simulationLength, j * windowSize);
    psthSim(j) = sum(modelFiringRate((j-1) * windowSize + 1: currentChange));
    psthExp(j) = sum(expFiringRate((j-1) * windowSize + 1: currentChange));
end

% TBD:  smooth  firing rate
psthExp = conv(psthExp, smoothingFilter,'same');
psthSim = conv(psthSim, smoothingFilter,'same'); 


%Caclulate cross correlation between psth
[vecCorrelation, vecLegs] = xcorr(psthExp,psthSim);

% Get index of the highest cross correlation
[~, index] = max(vecCorrelation);
Leg =  vecLegs(index)

% Caclulate metrics to comapre between the model and the data

% Sun of squred errors
sse = sum((psthSim - psthExp).^2);

% Total sum of squraes
sst = sum((psthExp - mean(psthExp)).^2);

% Fraction of variance explained
metrics.varExplain = 1-(sse/sst);

% Correlation ceoefficent
metrics.correlation = corr(psthExp, psthSim,'type','Pearson');
corr(psthExp, circshift(psthSim,Leg),'type','Pearson');
metrics.correlation
% Mean squared error
metrics.mse = nanmean((psthSim - psthExp).^2);

% The lag with the highest cross correlation
metrics.Leg = Leg;

% Caclulate experiment inter spike interval
expISI = diff(find(expFiringRate));

maxExpISI = max(expISI);

if isempty(maxExpISI)
    expISIPr = zeros(100, 1);
    expISITimes = linspace(1 * dt, 100 * dt, 100);
else
    expISIPr = zeros(maxExpISI, 1);
    for j = 1:maxExpISI
        expISIPr(j) = sum(expISI == j);
    end
    expISIPr = expISIPr / sum(expISIPr);
    expISITimes = linspace(1 * dt, maxExpISI * dt, maxExpISI);
end
ISI.expISIPr = expISIPr;
ISI.expISITimes = expISITimes;
end