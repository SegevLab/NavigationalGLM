function buildDataOfNetwork(sessionName, folderPath)

neuronsSpikesFiles = dir(strcat(folderPath,'/', sessionName, '_T*.mat'));
numOfNeurons = numel(neuronsSpikesFiles)
neuronsPosition = dir(strcat(folderPath,'/', sessionName, '_POS*.mat'));
neuronsEEGFile = dir(strcat(folderPath,'/', sessionName, '_EEG*.mat'));

if numel(neuronsPosition) == 1
    positionPath = strcat(folderPath, '/', neuronsPosition(1).name);
else
    return;
end

if numel(neuronsEEGFile) == 1
    eegPath = strcat(folderPath, '/', neuronsEEGFile(1).name);
else
    return;
end

for i = 1:numOfNeurons
    currentSpikesPath = strcat(folderPath, neuronsSpikesFiles(i).name);
    moserBuildDataForLearning(currentSpikesPath, positionPath, sessionName, i, neuronsSpikesFiles(i).name, eegPath)
end
end