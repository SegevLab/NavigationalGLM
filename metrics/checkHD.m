clear all;
networkName = '11084-03020501';
neuronNumber = 5;
load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuronNumber)]);
window = 200;
%headDirection = headDirection -pi;
spikeExp = find(spiketrain);  
numOfSpikes = length(spikeExp);
hdHistory = zeros(numOfSpikes, window);

for i = 1:numOfSpikes
    hdHistory(i,:) = headDirection(spikeExp(i) - window:spikeExp(i) - 1);
end
figure();
plot(mean(hdHistory));
%ylim([-1 1]);
hdHistoryFull = zeros(length(spiketrain), window);

for i = window + 1:length(spiketrain)
    hdHistoryFull(i,:) = headDirection(i - window:i - 1);
end
figure();
plot(mean(hdHistoryFull));
%ylim([-1 1]);