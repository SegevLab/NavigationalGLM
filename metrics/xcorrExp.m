clear all;
networkName = '11025-01060511';
neuron1 = 1;
neuron2 = 1;
load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron1)]);
spikeseries1 = spiketrain;
spikeExp1 = find(spiketrain);  
length(spikeExp1)


load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron2)]);
spikeseries2 = spiketrain;

spikeExp2 = find(spiketrain);  
length(spikeExp2)

 T = -305.5:10:305.5;
 Tout = -300:10:300;

[corrReal1] = MyCrossCorrMS(spikeExp1,spikeExp2, T);

figure();

plot(Tout, corrReal1,'-k', 'lineWidth', 3);
axis square;
xlabel('Lag (ms)');
ylabel('Probability');
%ylim([0.05 0.3]);
% 
% fr1 = histcounts(spikeExp1, 0:5:length(spikeseries1));
% fr2 = histcounts(spikeExp2, 0:5:length(spikeseries2));
% figure();
% 
% [acor,lag] = xcorr(fr1, fr2);
% acor = acor / sum(spikeseries2);
% plot(lag,acor)
% xlim([-100 100]);
% ylim([0 0.3]);
