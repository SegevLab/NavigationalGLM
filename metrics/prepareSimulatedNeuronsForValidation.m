%%
clear all;
networkName = '11025-20050501';
addpath('../featureMaps');
addpath('../General');
addpath('../simulation');

sessionName = networkName;
neuron1 = 2;
neuron2 = 6;
stimulus = {};
tuning = {};
numOfNeurons = 2;
bias = zeros(numOfNeurons,1);
rawDatafolderPath = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName);
rawDatafolderPathSpecialFilter = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName, '-SpecialFilter');
filePath = [rawDatafolderPath '\data_for_cell_'];
learnedParamsFolderPath = strcat('C:\projects\NavigationModels\GLM\Graphs\', sessionName);
Neuron1leanredParamsFilePath = [learnedParamsFolderPath '\Neuron_' num2str(neuron1) '_coupled_Results_single'];
Neuron2leanredParamsFilePath = [learnedParamsFolderPath '\Neuron_' num2str(neuron2) '_coupled_Results_single'];

config.numOfPositionAxisParams = 25;
config.numOfPositionParams = config.numOfPositionAxisParams * config.numOfPositionAxisParams;
config.numOfHeadDirectionParams = 30;
config.numOfSpeedBins = 8;
config.numOfTheta = 20;
config.sampleRate = 1000;
config.maxSpeed = 50;
config.boxSize = [100 100];
boxSize = config.boxSize;
config.dt = 1/1000;
config.speedVec = [0 1 4 8 14 26 38 50];

% load general data
load([filePath num2str(neuron1)]);
data.posx = posx;
data.posy = posy;
data.headDirection = headDirection;
data.spiketrain = zeros(length(posx),1);
data.thetaPhase = phase;
[features] = buildFeatureMaps(config, data, 0);
filter1 = [0.5; 0.4; 0.3; 0.2; 0.1; zeros(40,1)];
filter2 = [zeros(10,1);0.1;0.2;0.3;0.4; 0.5;0.5;0.5; 0.4; 0.3; 0.2; 0.1; zeros(10,1)];
filter3 = [0.2 * ones(25,1);0.2; 0.1; zeros(10,1)];
datalen = length(posx);

%% Get first neuronParams
load(Neuron1leanredParamsFilePath);
load([filePath num2str(neuron1)]);
selectedModel = modelParams.modelNumber;
stimulus{1} = getStimulusByModelNumber(selectedModel, features.posgrid, features.hdgrid, features.speedgrid, features.thetaGrid);
bias(1) = modelParams.biasParam;
history1 = modelParams.spikeHistory;
coupling1 = modelParams.couplingFilters;
%coupling1 = filter2;

tuning{1} = modelParams.tuningParams;
% Get second neuron params
load(Neuron2leanredParamsFilePath);
load([filePath num2str(neuron2)]);
selectedModel = modelParams.modelNumber;

stimulus{2} = getStimulusByModelNumber(selectedModel, features.posgrid, features.hdgrid, features.speedgrid, features.thetaGrid);
bias(2) = modelParams.biasParam;
tuning{2} = modelParams.tuningParams;

history2 = modelParams.spikeHistory;
coupling2 = zeros(40, 1);

historyLen = max(length(history1), length(history2));
couplingLen = max(length(coupling1), length(coupling2));
historyFilt = zeros(historyLen,numOfNeurons);
historyFilt(1:min(historyLen, length(history1)),1) = history1;
historyFilt(1:min(historyLen, length(history2)),2) = history2;

couplingFilt = zeros(couplingLen, numOfNeurons,numOfNeurons);
couplingFilt(1:min(couplingLen, length(coupling1)),1,2) = coupling1;
couplingFilt(1:min(couplingLen, length(coupling2)),2,1) = coupling2;
simulationLength = length(posx);
%%
repeats = 1;
response = [];
for i = 1:repeats
    response = [response; simulateCoupledNetworkResponse(numOfNeurons, stimulus, tuning, historyFilt, couplingFilt, bias,  config.dt, simulationLength, historyLen)];
end
posx = repmat(posx,repeats,1);
posy = repmat(posy,repeats,1);
headDirection = repmat(headDirection,repeats,1);
phase = repmat(phase,repeats,1);

spiketrain = response(:,1);
sum(spiketrain)
mkdir(rawDatafolderPathSpecialFilter);
save([rawDatafolderPathSpecialFilter '\data_for_cell_' num2str(neuron1)], 'spiketrain', 'posx', 'posy', 'boxSize', 'sampleRate', 'headDirection','phase');


spiketrain = response(:,2);
save([rawDatafolderPathSpecialFilter '\data_for_cell_' num2str(neuron2)], 'spiketrain', 'posx', 'posy', 'boxSize', 'sampleRate', 'headDirection','phase');
sum(spiketrain)

%%
figure();
a = reshape(tuning{1}, 25,25);
a = exp(a + bias(1));
b = reshape(tuning{2}, 25,25);
b = exp(b + bias(2) );
c = xcorr2(a,b);
subplot(1,2,1);
imagesc(0.5:1:99.5,0.5:1:99.5,a);
title('Neuron 1 - Position');
colorbar;
colormap jet;
axis square;
subplot(1,2,2);
imagesc(0.5:1:99.5,0.5:1:99.5,b);
colorbar;
title('Neuron 2 - Position');
colormap jet;
axis square;
figure()
imagesc(0.5:1:99.5,0.5:1:99.5,c);
colormap jet;
axis square;
title('Cross Correlogram');