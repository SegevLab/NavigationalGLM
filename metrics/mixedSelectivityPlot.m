sessionName = '11084-03020501';
neurons = [1];
psthdt = 1/50;
folderPath = strcat('C:\projects\NavigationModels\GLM\Graphs\', sessionName);
singleFilePath = [folderPath '\Neuron_' num2str(neurons(1)) '_history_Results_single'];
bestFilePath = [folderPath '\Neuron_' num2str(neurons(1)) '_history_Results_best'];
load(singleFilePath);
singleFiringRate = modelParams.simFiringRate;
expFiringRate = modelParams.expFiringRate;
timeBins = modelParams.timeBins;
singlePearson = modelMetrics.correlation;

load(bestFilePath);
bestFiringRate = modelParams.simFiringRate;
bestPearson = modelMetrics.correlation;

figure();
plot(timeBins, expFiringRate / psthdt, '-k', timeBins, singleFiringRate / psthdt, '-b', timeBins, bestFiringRate/ psthdt, '-r', 'linewidth',2);
legend('MEC data', ['Head direction - R = ' num2str(singlePearson,2)], ['Mixed selectivity - R = ' num2str(bestPearson,2)]);
xlabel('time (seconds)');
ylabel('spikes/s');