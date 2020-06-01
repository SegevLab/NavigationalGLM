function plt = getPhaseLockingPlot(networkName, neuronNumber)
peak = 125;

load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\data_for_cell_' num2str(neuronNumber)])
numBins = 10;
edges = 0:36:360;

spikeT = find(spiketrain);
diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
theta = phase;
theta = theta * 180 / pi;
ind =  isi > peak;
numOfSpikes = sum(ind);
phaseSpike = theta(spikeT);

[mecPhaseSpikesHist, ~] = histcounts(phaseSpike(ind), edges);


load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\history_simulated_data_cell_' num2str(neuronNumber)])
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > peak;
phaseSpike = theta(spikeT);
[historySpikesHist, ~] = histcounts(phaseSpike(ind), edges);

load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\simulated_data_cell_' num2str(neuronNumber)])
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > peak;
phaseSpike = theta(spikeT);
[noHistorySpikesHist, edges] = histcounts(phaseSpike(ind), edges);
edges = edges - 30;
edges(1) = [];
edges = edges / 180 * pi;
figure();
mecPhaseSpikesHist = mecPhaseSpikesHist / sum(mecPhaseSpikesHist);
historySpikesHist = historySpikesHist / sum(historySpikesHist);
noHistorySpikesHist = noHistorySpikesHist / sum(noHistorySpikesHist);
noHistCC = corr2(mecPhaseSpikesHist, noHistorySpikesHist);
histCC = corr2(mecPhaseSpikesHist, historySpikesHist);

noHistKL = KLDiv(mecPhaseSpikesHist, noHistorySpikesHist);
histKL = KLDiv(mecPhaseSpikesHist, historySpikesHist);
plt = plot(edges, mecPhaseSpikesHist, '-k', edges, historySpikesHist, '-r',edges, noHistorySpikesHist, '-b','linewidth',2);

%polarplot([edges edges(1)],[mecPhaseSpikesHist mecPhaseSpikesHist(1)],'-k', [edges edges(1)],[historySpikesHist historySpikesHist(1)],'-b', [edges edges(1)],[noHistorySpikesHist noHistorySpikesHist(1)],'-r', 'linewidth',2);
title('Phase locking ','fontsize',20);
legend(['MEC Data - N = ' num2str(numOfSpikes)], ['History - R = ' num2str(histCC,2) ' DKL = ' num2str(histKL,2)], ['No history - R = ' num2str(noHistCC,2) ' DKL = ' num2str(noHistKL,2)]);
 ylim([1/ numBins - 0.1 0.3]);
end