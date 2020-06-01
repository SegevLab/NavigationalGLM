clear all;
networkName = '11025-19050503';
neuronNumber = 1;
load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuronNumber)]);
window = 250;
phase = phase -pi;
spikeExp = find(spiketrain);  
numOfSpikes = length(spikeExp);
thetaHistory = zeros(numOfSpikes, window);

for i = 1:numOfSpikes - 10
    thetaHistory(i,:) = phase(spikeExp(i) - window:spikeExp(i) - 1);
end
% figure(); 
% plot(mean(thetaHistory),'linewidth',2);
sum(mean(thetaHistory) * mean(thetaHistory)')
sum(mean(thetaHistory) * circshift(mean(thetaHistory)',140))


% figure();
% plot(thetaHistory([1 5 10 20 30 40 50 60],:)','linewidth',2);
%ylim([-1 1]);
thetaHistoryFull = zeros(length(spiketrain), window);
% for i = window + 1:length(spiketrain)
%     thetaHistoryFull(i,:) = phase(i - window:i - 1);
% end
% figure();
% plot(mean(thetaHistoryFull));
%ylim([-1 1]);