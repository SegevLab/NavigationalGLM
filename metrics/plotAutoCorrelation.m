function plt = plotAutoCorrelation(networkName, neuronID)

load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuronID)]);
spikeseries = spiketrain;
spikeExp = find(spiketrain);  



load(['../rawDataForLearning/' networkName '/history_simulated_data_cell_'  num2str(neuronID)]);
spikeHistory = find(spiketrain);


load(['../rawDataForLearning/' networkName '/simulated_data_cell_'  num2str(neuronID)]);
spikeNoHistory = find(spiketrain);


 T = -305.5:10:305.5;
 Tout = -300:10:300;

corrReal = MyCrossCorrMS(spikeExp,spikeExp, T);
corrHist = MyCrossCorrMS(spikeHistory, spikeHistory, T);
corrNoHist = MyCrossCorrMS(spikeNoHistory, spikeNoHistory, T);

mseHist = immse(corrReal, corrHist);
mseNoHist = immse(corrReal, corrNoHist);


plot(Tout, corrReal,'-k',Tout, corrHist, '-r',Tout, corrNoHist, '-b', 'lineWidth', 3);
legend('MEC Data', ['History - MSE = ' num2str(mseHist,2)], ['No history - MSE = ' num2str(mseNoHist,2)]);
axis square;
box off;
if neuronID == 1
    xlabel('Lag (ms)');
    ylabel('Probability');

end
end
