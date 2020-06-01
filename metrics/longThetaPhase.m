clear all;
neuronNumber = 1;
networkName = '11084-03020501';
load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\data_for_cell_' num2str(neuronNumber)])
peak = 125;
numBins = 6;
spikeT = find(spiketrain);
diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
figure();
z = hist(isi,1:1:5000);
z = cumsum(z);
plot(z / z(end))
xlim([0 100]);
phase = phase * 180 / pi;
ind =  isi > peak;
phaseSpike = phase(spikeT);
edges = 0:60:360;

[mecPhaseSpikesHist, ~] = histcounts(phaseSpike(ind), edges);

%histogram(phaseSpike(ind), edges);
%  figure();
%  hist(phase, 0:0.3:2*pi);

load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\history_simulated_data_cell_' num2str(neuronNumber)])
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > peak;
phaseSpike = phase(spikeT);
[historySpikesHist, ~] = histcounts(phaseSpike(ind), edges);

load(['C:\projects\NavigationModels\GLM\rawDataForLearning\' networkName '\coupled_simulated_data_cell_' num2str(neuronNumber)])
spikeT = find(spiketrain);

diffSpike = [spikeT(1); spikeT];
isi = diff(diffSpike);
ind =  isi > peak;
phaseSpike = phase(spikeT);
[coupledSpikesHist, edges] = histcounts(phaseSpike(ind), edges);
edges = edges - 30;
edges(1) = [];
edges = edges / 180 * pi;
figure();
mecPhaseSpikesHist = mecPhaseSpikesHist / sum(mecPhaseSpikesHist);
historySpikesHist = historySpikesHist / sum(historySpikesHist);
coupledSpikesHist = coupledSpikesHist / sum(coupledSpikesHist);
polarplot([edges edges(1)],[mecPhaseSpikesHist mecPhaseSpikesHist(1)],'-k', [edges edges(1)],[historySpikesHist historySpikesHist(1)],'-b', [edges edges(1)],[coupledSpikesHist coupledSpikesHist(1)],'-r', 'linewidth',2);
title('Phase locking ','fontsize',20);
 legend('MEC data', 'History','coupled');
