clear all;
folderPath = 'all_data/';
allDir = dir(folderPath);
numOfVars = numel(allDir);
numOfVars
for i = 1:numOfVars
    [i numOfVars]
    if allDir(i).isdir == 1
        allDir(i).name
        buildDataOfNetwork(strcat(allDir(i).name), strcat(folderPath, allDir(i).name, '/'));
    end
end
    