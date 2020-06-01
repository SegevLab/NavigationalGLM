function plotNetworkResults(sessionName)
figure();
folderPath = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName);

if isdir(folderPath)
    neuronsPaths = dir([folderPath '\data_for_cell_*.mat']);
    numOfNeurons = length(neuronsPaths);
        
    for neuronIndex = 1:numOfNeurons
        subplot(ceil(numOfNeurons / 2),2, neuronIndex);
        plotAutoCorrelation(sessionName, neuronIndex);
        drawnow;
        
    end
end

end