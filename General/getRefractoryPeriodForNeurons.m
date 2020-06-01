function [refreactoryPeriod, ISIPeak] =  getRefractoryPeriodForNeurons(spiketrain, dt)

% Calculate the inter spike interval
ISI =  diff(find(spiketrain));

% Get the longest interspike interval
maxISI = max(ISI);

% Define inter spike interval length
ISIPr = zeros(maxISI, 1);

% Run for each interspike interval in the range and find intervals that
% correspond to it
for j = 1:maxISI
    ISIPr(j) = sum(ISI == j);
end

% Divide by the sum to get probability
ISIPr = ISIPr / sum(ISIPr);

% Find t that the ISI probability is bigger then a threshold
wantedIndexes = find(ISIPr >= 0.005);

% If we didn't find one, define 2 milisecond to be the wanted index
if isempty(wantedIndexes)
    wantedIndex = 1;
else
    wantedIndex = wantedIndexes(1) - 1;
end
     

% Define the refactory period to be the wantedIndex or 1
refreactoryPeriod = max(1,wantedIndex);

% Get the peak of isi
[~, ISIPeak] = max(ISIPr);

% If the peak is smaller then selected refactory period, then set one bin
% after the refractory period to be the first peak
if ISIPeak <= refreactoryPeriod
    ISIPeak = refreactoryPeriod + 1;
end

% Change values resolution of dt
ISIPeak = ISIPeak * dt;
refreactoryPeriod = refreactoryPeriod * dt;
    
end