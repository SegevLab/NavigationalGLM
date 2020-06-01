function [stimBins,expBins, lambdasBins, simspikesBins] = getNonLinearEstimator(linearProjection, expSpikes, simSpikes, lambdas, windowSize)

dataLength = length(linearProjection);
psthLength = ceil(dataLength / windowSize);
stimBinned = zeros(psthLength, 1);
frBinned = zeros(psthLength, 1);
simfrBinned = zeros(psthLength, 1);
lambdasBinned = zeros(psthLength, 1);

for i = 1:psthLength - 1
   stimBinned(i) = sum(linearProjection((i-1) * windowSize + 1:i * windowSize));
   frBinned(i) = sum(expSpikes((i-1) * windowSize + 1:i * windowSize));
   simfrBinned(i) = sum(simSpikes((i-1) * windowSize + 1:i * windowSize));
   lambdasBinned(i) = sum(lambdas((i-1) * windowSize + 1:i * windowSize));

end
numOfBins = 20;

stimBins = linspace(min(stimBinned), max(stimBinned) + 0.001, numOfBins);
expBins = zeros(numOfBins - 1,1);
lambdasBins = zeros(numOfBins - 1,1);
simspikesBins = zeros(numOfBins - 1,1);

for i = 1:length(stimBins) - 1;
    currBins = find(stimBinned > stimBins(i) & stimBinned <= stimBins(i + 1));
    if sum(currBins) > 0
        expBins(i) = mean(frBinned(currBins));
        lambdasBins(i) = mean(lambdasBinned(currBins));
        simspikesBins(i) = mean(simfrBinned(currBins));

    end
end
stimBins = stimBins(1:end-1);
end