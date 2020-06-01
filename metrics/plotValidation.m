%%
clear all;
networkName = '11025-19050503';
addpath('featureMaps');
addpath('General');

sessionName = networkName;
neuron1 = 1;
neuron2 = 3;
dt = 0.001;
filter1 = [ 0.5; 0.4; 0.3; 0.2; 0.1; zeros(40,1)];
filter2 = [zeros(10,1);0.1;0.2;0.3;0.4; 0.5;0.5;0.5; 0.4; 0.3; 0.2; 0.1; zeros(10,1)];
filter3 = [0.2 * ones(25,1); 0.2; 0.1; zeros(10,1)];

rawDatafolderPath = strcat('C:\projects\NavigationModels\GLM\rawDataForLearning\', sessionName);
filePath = [rawDatafolderPath '\data_for_cell_'];
learnedParamsFolderPath = strcat('C:\projects\NavigationModels\GLM\Graphs\', sessionName);
Neuron1leanredParamsFilePath = [learnedParamsFolderPath '\Neuron_' num2str(neuron1) '_coupled_Results_single'];
Neuron2leanredParamsFilePath = [learnedParamsFolderPath '\Neuron_' num2str(neuron2) '_coupled_Results_single'];
Neuron1Validation = [learnedParamsFolderPath '-SpecialFilter\Neuron_' num2str(neuron1) '_coupled_Results_single'];
Neuron2Validation = [learnedParamsFolderPath '-SpecialFilter\Neuron_' num2str(neuron2) '_coupled_Results_single'];

%% Get first neuronParams
load(Neuron1leanredParamsFilePath);

neuronParams(1).bias = modelParams.biasParam;
neuronParams(1).history = modelParams.spikeHistory;
neuronParams(1).couplingFilter = modelParams.couplingFilters;
%neuronParams(1).couplingFilter(1:20) = 0;
%neuronParams(1).couplingFilter = filter2;

% Get second neuron params
load(Neuron2leanredParamsFilePath);

neuronParams(2).bias = neuronParams(1).bias;
neuronParams(2).history =  modelParams.spikeHistory;
neuronParams(2).couplingFilter = zeros(40, 1);


%% Get first neuronParams
load(Neuron1Validation);

validationParams(1).bias = modelParams.biasParam;
validationParams(1).history = modelParams.spikeHistory;
validationParams(1).couplingFilter = modelParams.couplingFilters;

% Get second neuron params
load(Neuron2Validation);

validationParams(2).bias = modelParams.biasParam;
validationParams(2).history = modelParams.spikeHistory;
validationParams(2).couplingFilter = modelParams.couplingFilters;

figure();
subplot(2,1,1);
t1 = linspace(dt, dt * length(neuronParams(1).history), length(neuronParams(1).history));
t2 = linspace(dt, dt * length(validationParams(1).history), length(validationParams(1).history));
z = ones(length(t1), 1);
p = plot(t1, exp(neuronParams(1).history),'-k', t2, exp(validationParams(1).history),'-r', t1,z,'--b','linewidth', 2);
legend('ground truth', 'learned param');
title('spike history filter - neuron 1');
xlabel('time (s)');
ylabel('gain');

ylim([0 4]);

subplot(2,1,2);
t1 = linspace(dt, dt * length(neuronParams(2).history), length(neuronParams(2).history));
t2 = linspace(dt, dt * length(validationParams(2).history), length(validationParams(2).history));
z = ones(length(t1), 1);

plot(t1, exp(neuronParams(2).history),'-k', t2, exp(validationParams(2).history),'-r',t1,z, '--b', 'linewidth', 2);
legend('ground truth', 'learned param');
title('spike history filter - neuron 2');
xlabel('time (s)');
ylabel('gain');
ylim([0 4]);

figure();
subplot(1,2,1);
t1 = linspace(dt, dt * length(neuronParams(1).couplingFilter), length(neuronParams(1).couplingFilter));
z = ones(length(t1), 1);
t2 = linspace(dt, dt * length(validationParams(1).couplingFilter), length(validationParams(1).couplingFilter));
plot(t1, exp(neuronParams(1).couplingFilter),'-k', t2, exp(validationParams(1).couplingFilter), '-r',t1,z, '--b', 'linewidth', 2);
legend('ground truth', 'learned param'); 
title('interaction filter - neuron 1');
xlabel('time (s)');
ylabel('gain');
ylim([0 3]);
axis square;
subplot(1,2,2);
t = linspace(dt, dt * length(validationParams(2).couplingFilter), length(validationParams(2).couplingFilter));
z = ones(length(t), 1);

x = zeros(length(t),1);
t1 = linspace(dt, dt * length(neuronParams(2).couplingFilter), length(neuronParams(2).couplingFilter));
plot(t1, exp(neuronParams(2).couplingFilter),'-k', t, exp(validationParams(2).couplingFilter), '-r',t,z,  '--b', 'linewidth', 2);
legend('ground truth', 'learned param');
title('interaction filter - neuron 2');
xlabel('time (s)');
ylabel('gain');
ylim([0 3]);
axis square;
