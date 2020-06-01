clear all;

% Seesion if of the experiment
sessionName = '11025-19050503';

% The neurons we choose to learn in this run
neurons = [1];

% Get number of neurons in this run
numOfNeurons = length(neurons);

% Paths ...
folderPath = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName);
configFilePath = ['C:\projects\NavigationModels\GLM\rawDataForLearning\' 'config'];
filePath = [folderPath '\data_for_cell_'];
 
%% Learn single neurons, w/o history
fCoupling = 0;
coupledNeurons = [];
for neuronNumber = 1:length(neurons)
    [stimulus,tuningParams, couplingFilters, historyFilter, bias, dt] =...
        runLearning(sessionName,filePath, neurons(neuronNumber), configFilePath, fCoupling, coupledNeurons);
end

%% Learn single neurons with history
fCoupling = 1;

coupledNeurons = [];
for neuronNumber = 1:length(neurons)
    [stimulus,tuningParams, couplingFilters, historyFilter, bias, dt] =...
        runLearning(sessionName,filePath,  neurons(neuronNumber), configFilePath, fCoupling, coupledNeurons);
end

%% Learn network - with history and coupling
fCoupling = 1;

% init vars
stimulus = {};
tuning = {};
couplingFilters = {};
historyFilters = {};
bias = zeros(numOfNeurons, 1);
maxCouplingLength = [];
maxHistoryLength = [];

% Run for each neuron we want to learn
for neuronNumber = 1:length(neurons);
    % Get the coupled neurons that we want to include
    coupledNeurons = neurons;
    coupledNeurons(neuronNumber) = [];
    
    % Run learning
    [stimulus{neuronNumber},tuning{neuronNumber}, couplingFilters{neuronNumber}, historyFilters{neuronNumber}, bias(neuronNumber), dt] =...
        runLearning(sessionName, filePath,  neurons(neuronNumber), configFilePath, fCoupling, coupledNeurons);
    
    % Record history and coupling length for each neuron
    maxCouplingLength = [maxCouplingLength; size(couplingFilters{neuronNumber},1)];
    maxHistoryLength = [maxHistoryLength; length(historyFilters{neuronNumber})];
end

% get the max history and coupling filter length
historyLen = max(maxHistoryLength);
couplingLen = max(maxCouplingLength);

% Init history and coupling filters for all neurons
historyFilt = zeros(historyLen, numOfNeurons);
couplingFilt = zeros(couplingLen,numOfNeurons,numOfNeurons);

% Story all history and coupling neurons in a matrix
for neuronNumber = 1:length(neurons)
    currNeuron = neuronNumber;
    coupledNeurons = 1:numOfNeurons;
    coupledNeurons(neuronNumber) = [];
    currCouplingLen = size(couplingFilters{neuronNumber},1);
    currHistoryLen =  length(historyFilters{neuronNumber});
    couplingFilt(1:currCouplingLen,neuronNumber, coupledNeurons) = couplingFilters{neuronNumber};
    historyFilt(1:currHistoryLen, neuronNumber) = historyFilters{neuronNumber};
end
%% Simulate the network simulatonisouly

simulationLength = size(stimulus{1},1);
firingRate = [];
numOfSimulations = 10;

% Simulate network response
for i = 1:numOfSimulations
    firingRate = [firingRate; simulateNeuralNetworkResponse(numOfNeurons, stimulus, tuning, historyFilt, couplingFilt, bias,  dt, simulationLength, historyLen)];
end

% Save network response for each neuron
for neuronNumber = 1:length(neurons)
    spiketrain = firingRate(:,neuronNumber);
    save(['rawDataForLearning/' sessionName '/fullyCoupled_' num2str(neurons(neuronNumber))], 'spiketrain');
end

% **Plot** sum of simulated firing rate
sum(firingRate)

%profile viewer