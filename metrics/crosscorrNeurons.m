clear all;
networkName = '11025-19050503';
neuron1 = 3;
neuron2 = 1;
load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron1)]);
spikeExp1 = find(spiketrain);  
length(spikeExp1)
load(['../rawDataForLearning/' networkName '/fullyCoupled_'  num2str(neuron1)]);
fullyCoupled1 = find(spiketrain);

load(['../rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuron1)]);
spikeHistory1 = find(spiketrain);

load(['../rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron1)]);
spikeCoupled1 = find(spiketrain);


load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuron2)]);
spikeExp2 = find(spiketrain);  
length(spikeExp2)
% load(['../rawDataForLearning/' networkName '/fullyCoupled_'  num2str(neuron2)]);
% fullyCoupled2 = find(spiketrain);

load(['../rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuron2)]);
spikeHistory2 = find(spiketrain);

load(['../rawDataForLearning/' networkName '/coupled_simulated_data_cell_'  num2str(neuron2)]);
spikeCoupled2 = find(spiketrain);
 T = -205.5:10:205.5;
 Tout = -200:10:200;

[corrReal1] = MyCrossCorrMS(spikeExp2,spikeExp1, T);
[corrHistory1] = MyCrossCorrMS(spikeHistory2, spikeExp1,T);
[corrCoupled1] = MyCrossCorrMS(spikeCoupled2, spikeExp1, T);
%[corrFully1] = MyCrossCorrMS(fullyCoupled2, fullyCoupled1,T);
[corrReal2] = MyCrossCorrMS(spikeExp1,spikeExp2, T);
[corrHistory2] = MyCrossCorrMS(spikeHistory1,spikeExp2, T);
[corrCoupled2] = MyCrossCorrMS(spikeCoupled1,spikeExp2, T);
%[corrFully2] = MyCrossCorrMS(fullyCoupled1,fullyCoupled2,T);
corrHistoryOnly = MyCrossCorrMS(spikeHistory1,spikeHistory2,T);


figure();

plot(Tout, corrReal2,'-k', Tout, corrCoupled2 ,'-r', Tout, corrHistory2,'-b', 'lineWidth', 3);
legend('Experiment',['Coupled - Separately, neuron ' num2str(neuron1)], 'History');

xlabel('time (ms)');
ylabel('Cross correlation');
title(['Cross correlation - First side']);
%ylim([0 inf]);
axis square;

figure();

plot(Tout, corrReal1,'-k', Tout, corrCoupled1 ,'-r', Tout, corrHistory1,'-b','lineWidth', 3);
legend('Experiment', ['Coupled - Separately, neuron ' num2str(neuron2)], 'History');

xlabel('time (ms)');
ylabel('Cross correlation');
title(['Cross correlation - Second side']);
axis square;


% figure();
% Tout = Tout * 1/1000;
% plot(Tout, corrReal1,'-k', Tout, corrFully1 ,'-r', Tout, corrHistoryOnly,'-b','lineWidth', 3);
% legend('MEC data','Model - Coupled', 'Model - History only');
% 
% xlabel('Lag (s)');
% ylabel('Probability');
% title(['Cross correlation']);
% axis square;
% ylim([0 inf]);





