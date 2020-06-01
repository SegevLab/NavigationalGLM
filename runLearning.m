function [allStimulus,tuningParams, couplingFilters, historyFilter, bias, dt] = runLearning(sessionName, data_path, neuronNumber, configFilePath,...
    fCoupling, coupledNeurons)

% Define paths to use 
addpath('General');
addpath('featureMaps');
addpath('Fit');
addpath('simulation');
addpath('BuildPlots');
addpath('ModelSelection');

% Define empty vars
allStimulus = [];
tuningParams = [];
couplingFilters = [];
historyFilter = [];
couplingData = [];
designMatrix = [];

bias = nan;


% Caclulate the number of coupled neurons we have
if fCoupling == 0
    numOfCoupledNeurons = 0;
else
    fCoupling = 1;
    numOfCoupledNeurons = length(coupledNeurons);
end


% Get learning data
[config, learningData, couplingData, testData, testCouplingData, expISI, posx, posy, boxSize,sampleRate,headDirection,phase,fr,  allCouplingData] =...
    loadDataForLearning(data_path, configFilePath, neuronNumber, fCoupling, coupledNeurons);


% Build feature maps from the loaded data
trainFeatures = buildFeatureMaps(config, learningData);
testFeatures = buildFeatureMaps(config, testData);

% TBD: Dump features into file if needed
%dumpInputToFile(sessionName, neuronNumber, trainFeatures, testFeatures, learningData, testData,boxSize, sampleRate);

% Get spike history & coupling design matrix if defined
if fCoupling
    designMatrix = getSpikeHistoryAndCouplingDataForLearning(config, learningData, numOfCoupledNeurons, couplingData);
end

trainFeatures.designMatrix = designMatrix;

% Smooth experiment spike train
smooth_fr = conv(learningData.spiketrain, config.filter, 'same');

% Get experiment mean firing rate
mean_fr = sum(learningData.spiketrain) / length(learningData.spiketrain) / config.dt;

% Get experiment tuning curves
[pos_curve, hd_curve, speed_curve, theta_curve] = ...
    computeTuningCurves(learningData, trainFeatures, config, smooth_fr);

initTrainParam.pos = reshape(pos_curve, config.numOfPositionParams,1);
initTrainParam.hd = hd_curve;
initTrainParam.speed = speed_curve;
initTrainParam.theta = theta_curve;
% Plot experiment tuning curve
plotExperimentTuningCurves(config, trainFeatures, pos_curve, hd_curve, speed_curve, theta_curve, neuronNumber, learningData, sessionName, mean_fr);


% Fit model
[numModels, testFit, trainFit, param, Models,modelTypes, kFoldParams, selected_models] = ...
    fitAllModels(learningData, config, trainFeatures, initTrainParam);

% Define number of folds to use to select the best model
numOfFoldsForSelection = 8;

% Select best model
[topSingleModelID, topModelID, scores] = selectBestModelBySimulation(selected_models, modelTypes, param, numOfFoldsForSelection,...
    config,learningData.historyBaseVectors, trainFeatures, learningData.spiketrain,kFoldParams, numOfCoupledNeurons,...
    learningData.couplingBaseVectors, couplingData);

% Plot log likelihood of all models
PlotLogLikelihood(scores, config.numFolds, topModelID, sessionName, neuronNumber, fCoupling, numOfCoupledNeurons)

% Get test set stimulus of the best single model 
testStimulusSingle = getStimulusByModelNumber(topSingleModelID, testFeatures.posgrid, testFeatures.hdgrid, testFeatures.speedgrid, testFeatures.thetaGrid);

% Get best Single model perfomace and parameters
[metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate, log_ll] = ...
    getModelMetricsAndParameters(config, testData.spiketrain, testStimulusSingle, param{topSingleModelID},...
    modelTypes{topSingleModelID}, config.filter, numOfCoupledNeurons, testCouplingData,...
    learningData.historyBaseVectors, learningData.couplingBaseVectors, testFeatures.thetaGrid, kFoldParams{topSingleModelID});

% Record top single model
learnedParams.modelNumber = topSingleModelID;

% plot results of top single model
plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
    smoothPsthSim, neuronNumber, 'single', numOfCoupledNeurons, ISI,ISI.expISIPr,  sessionName,modelFiringRate,testData, coupledNeurons, log_ll)

% Get test set stimulus of the best  model 
testStimulusBest = getStimulusByModelNumber(topModelID, testFeatures.posgrid, testFeatures.hdgrid, testFeatures.speedgrid, testFeatures.thetaGrid);

% Create synthetic data for the best model

% Get model info
modelParam = param{topModelID};
modelType = modelTypes{topModelID};
kFoldParam = kFoldParams{topModelID};
learnedParams = getLearnedParameters(modelParam, modelType, config, kFoldParam, learningData.historyBaseVectors, numOfCoupledNeurons, learningData.couplingBaseVectors);
learningStimulus = getStimulusByModelNumber(topModelID, trainFeatures.posgrid, trainFeatures.hdgrid, trainFeatures.speedgrid, trainFeatures.thetaGrid);

if config.fCoupling == 0 || (config.fCoupling == 1 && numOfCoupledNeurons == 0)
    couplingData = [];
end

simStim = [testStimulusBest; learningStimulus];
simPhaseGrid = [testFeatures.thetaGrid; trainFeatures.thetaGrid];

% Simulate response to the all experiment (train & test sets)
[simFiringRate, ~, ~] = simulateNeuronResponse(simStim, learnedParams.tuningParams, learnedParams, config.fCoupling,  numOfCoupledNeurons, allCouplingData, config.dt, config,simPhaseGrid, 0,fr);
dt = config.dt;

% windowSize = 20;
% [trainstimBins,trainexpBins, trainlambdasBins, trainsimspikesBins] = getNonLinearEstimator(trainlinearProjection, learningData.spiketrain, trainFiringRate, trainLambdas, windowSize);
% [teststimBins, testexpBins, testlambdasBins, testsimspikesBins] = getNonLinearEstimator(testlinearProjection, testData.spiketrain, testFiringRate, testLambdas, windowSize);
% 
% 
% 
% figure();
% timeConst = 1/1000 * windowSize;
% subplot(1,2,1);
% plot(trainstimBins, trainexpBins / timeConst ,'-k', trainstimBins, trainlambdasBins / timeConst, '-r', trainstimBins, trainsimspikesBins / timeConst, '-b',...
%     'linewidth',2);
% title('Nonlinear Fit - train'); 
% legend('MEC ', 'Simulation - lambdas', 'Simulation - spikes');
% xlabel('Linear projection');
% ylabel('Firing Rate');
% axis square;
% 
% subplot(1,2,2);
% plot(teststimBins, testexpBins / timeConst ,'-k', teststimBins, testlambdasBins / timeConst, '-r', teststimBins, testsimspikesBins / timeConst, '-b',...
%     'linewidth',2);
% title('Nonlinear Fit - test'); 
% legend('MEC ', 'Simulation - lambdas', 'Simulation - spikes');
% xlabel('Linear projection');
% ylabel('Firing Rate');
% axis square;
% drawnow;

% Record the results 
if (config.fCoupling == 1 && numOfCoupledNeurons > 0)
    allStimulus = [learningStimulus; testStimulusBest];
    tuningParams = learnedParams.tuningParams;
    couplingFilters = learnedParams.couplingFilters;
    historyFilter = learnedParams.spikeHistory;
    bias = learnedParams.biasParam;
end

spiketrain = simFiringRate;

% Save the simulation information
if config.fCoupling == 0
    %savefig(['Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_CurveFit_NoHistory']);
    save(['rawDataForLearning/' sessionName '/simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
elseif config.fCoupling == 1 && numOfCoupledNeurons == 0
    %savefig(['Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_CurveFit_History']);
    save(['rawDataForLearning/' sessionName '/history_simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
else
     %savefig(['Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_CurveFit_Coupled']);
    save(['rawDataForLearning/' sessionName '/coupled_simulated_data_cell_' num2str(neuronNumber)], 'posx', 'posy', 'boxSize','sampleRate','headDirection', 'spiketrain');
end

 % Get best model perfomace and parameters
[metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate, log_ll] = ...
    getModelMetricsAndParameters(config, testData.spiketrain, testStimulusBest, param{topModelID},...
    modelTypes{topModelID}, config.filter, numOfCoupledNeurons, testCouplingData,...
    learningData.historyBaseVectors, learningData.couplingBaseVectors, testFeatures.thetaGrid, kFoldParams{topModelID});
learnedParams.modelNumber = topModelID;

% plot results
plotPerformanceAndParameters(config, learnedParams, metrics, smoothPsthExp, ...
    smoothPsthSim, neuronNumber, 'best', numOfCoupledNeurons, ISI,ISI.expISIPr,  sessionName, modelFiringRate, testData, coupledNeurons, log_ll)
end