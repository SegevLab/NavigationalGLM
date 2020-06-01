clear all;
networkName = '11025-19050503';
neuron = 4;

load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron)]);
spikeseries = spiketrain;
spikeExp = find(spiketrain);  



load(['../rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuron)]);
spikeHistory = find(spiketrain);


load(['../rawDataForLearning/' networkName '/simulated_data_cell_'  num2str(neuron)]);
spikeNoHistory = find(spiketrain);


 T = -505.5:10:505.5;
 Tout = -500:10:500;

corrReal = MyCrossCorrMS(spikeExp,spikeExp, T);
corrHist = MyCrossCorrMS(spikeHistory, spikeHistory, T);
corrNoHist = MyCrossCorrMS(spikeNoHistory, spikeNoHistory, T);

mseHist = immse(corrReal, corrHist);
mseNoHist = immse(corrReal, corrNoHist);

figure();

plot(Tout, corrReal,'-k',Tout, corrHist, '-r',Tout, corrNoHist, '-b', 'lineWidth', 3);
legend('MEC Data', ['History - MSE = ' num2str(mseHist,2)], ['No history - MSE = ' num2str(mseNoHist,2)]);
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
