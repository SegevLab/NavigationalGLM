clear all;
neuronNumber = 4;
networkName = '11025-19050503';
load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\data_for_cell_' num2str(neuronNumber)])
peak = 125;
numBins = 10;
edges = 0:36:360;

spikeT = find(spiketrain);
length(spikeT)
diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);

phase = phase * 180 / pi;
ind =  isi > peak;
numOfSpikes = sum(ind);
phaseSpike = phase(spikeT);

[mecPhaseSpikesHist, ~] = histcounts(phaseSpike(ind), edges);


load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\history_simulated_data_cell_' num2str(neuronNumber)])
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > peak;
phaseSpike = phase(spikeT);
[historySpikesHist, ~] = histcounts(phaseSpike(ind), edges);

load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\simulated_data_cell_' num2str(neuronNumber)])
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > peak;
phaseSpike = phase(spikeT);
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
plot(edges, mecPhaseSpikesHist, '-k', edges, historySpikesHist, '-r',edges, noHistorySpikesHist, '-b','linewidth',2);

%polarplot([edges edges(1)],[mecPhaseSpikesHist mecPhaseSpikesHist(1)],'-k', [edges edges(1)],[historySpikesHist historySpikesHist(1)],'-b', [edges edges(1)],[noHistorySpikesHist noHistorySpikesHist(1)],'-r', 'linewidth',2);
title('Phase locking ','fontsize',20);
legend(['MEC Data - N = ' num2str(numOfSpikes)], ['History - R = ' num2str(histCC,2) ' DKL = ' num2str(histKL,2)], ['No history - R = ' num2str(noHistCC,2) ' DKL = ' num2str(noHistKL,2)]);
 ylim([1/ numBins - 0.1 0.3]);
