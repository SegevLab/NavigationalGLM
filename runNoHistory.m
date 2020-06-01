clear all;
configFilePath = ['C:\projects\NavigationModels\GLM\rawDataForLearning\' 'config'];
nCount = 0;
%Get all sessions
sessions = dir('C:\projects\NavigationModels\GLM\rawDataForLearning\');
fCoupling = 0;
coupledNeurons = [];
sessionCount = length(sessions);
for sessionIndex = 1:sessionCount
    sessionName = sessions(sessionIndex).name;
    sessionName
    folderPath = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName);

    if isdir(folderPath)
        neuronsPaths = dir([folderPath '\data_for_cell_*.mat']);
        numOfNeurons = length(neuronsPaths);
        filePath = [folderPath '\data_for_cell_'];
        
        for neuronIndex = 1:numOfNeurons
            neuronIndex
            nCount = nCount + 1
        [stimulus,tuningParams, couplingFilters, historyFilter, bias, dt] =...
            runLearning(sessionName,filePath, neuronIndex, configFilePath, fCoupling, coupledNeurons); 
        end
    end
    
end

