clear all;

%Get all sessions
sessions = dir('C:\projects\NavigationModels\GLM\Graphs\');
fCoupling = 0;
neuronsnoHistSingleCorr = [];
neuronsnoHistBestCorr = [];
coupledNeurons = [];
sessionCount = length(sessions);
for sessionIndex = 1:sessionCount
    sessionName = sessions(sessionIndex).name;
    sessionName
    folderPath = strcat('C:\projects\NavigationModels\GLM\Graphs\', sessionName);

    if isdir(folderPath)
        single_no_history_neuronsPaths = dir([folderPath '\Neuron_*_NoHistory_Results_single.mat']);
        
        numOfNeurons = length(single_no_history_neuronsPaths);
        for neuronIndex = 1:numOfNeurons
            load([folderPath '\' single_no_history_neuronsPaths(neuronIndex).name]);
            neuronsnoHistSingleCorr = [neuronsnoHistSingleCorr modelMetrics.correlation];
        end
        
        best_no_history_neuronsPaths = dir([folderPath '\Neuron_*_NoHistory_Results_best.mat']);
        numOfNeurons = length(best_no_history_neuronsPaths);
        
        for neuronIndex = 1:numOfNeurons
            load([folderPath '\' best_no_history_neuronsPaths(neuronIndex).name]);
            neuronsnoHistBestCorr = [neuronsnoHistBestCorr  modelMetrics.correlation];
        end
    end
    
end

figure();
subplot(2,1,1);
hist(neuronsnoHistSingleCorr, -1:0.05:1);
title('Population corr - Single');
subplot(2,1,2);
hist(neuronsnoHistBestCorr, -1:0.05:1);
title('Population corr - Best');

sum(neuronsnoHistBestCorr > 0.3 & neuronsnoHistSingleCorr > 0.3)