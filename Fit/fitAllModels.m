function [numModels, testFitMetrics, trainFitMetrics, param, modelStimulus,modelType, kfoldsParam, selected_models] = fitAllModels(learnedParameters, config, features, initTrainParam)

lengthOfTrain = length(learnedParameters.spiketrain);
designMat  = [];
validation_ind  = 1:ceil(lengthOfTrain * config.validationRatio);
train_ind = setdiff(1:lengthOfTrain,validation_ind);

% Get all grids of sttimuls
posgrid = features.posgrid(train_ind,:);
hdgrid = features.hdgrid(train_ind,:);
speedgrid = features.speedgrid(train_ind,:);
thetaGrid = features.thetaGrid(train_ind,:);
if config.fPhaseLocking
    phaseLockGrid = features.phaseLockGrid(train_ind,:);
end
if config.fCoupling
    designMat = features.designMatrix(train_ind,:);
end
% Set the number of models we want to learn
numModels = config.numModels;

% Set the number of folds we would like to use
numFolds = config.numFolds;

% Init the metrics for train and test - numModels X kFolds X 6
testFitMetrics = cell(numModels,1);
trainFitMetrics = cell(numModels,1);

% Init params structures

% Store mean param for each model
param = cell(numModels,1);

% Store  k fold params for each model
kfoldsParam = cell(numModels,1);

% Store the stimulus for each model
modelStimulus = cell(numModels,1);

% model Type - [Position, head direction, speed, theta]
modelType = cell(numModels,1);

% ALL stimulus
modelStimulus{1} = [posgrid hdgrid speedgrid thetaGrid];
modelType{1} = [1 1 1 1];

% Three stimulus variables 
modelType{2} = [1 1 1 0];
modelType{3} = [1 1 0 1];
modelType{4} = [1 0 1 1];
modelType{5} = [0 1 1 1];

modelStimulus{2} = [posgrid hdgrid speedgrid];
modelStimulus{3} = [posgrid hdgrid thetaGrid];
modelStimulus{4} = [posgrid speedgrid thetaGrid];
modelStimulus{5} = [hdgrid speedgrid thetaGrid];

% Two stimulus variables 
modelType{6} = [1 1 0 0];
modelType{7} = [1 0 1 0];
modelType{8} = [1 0 0 1];
modelType{9} = [0 1 1 0];
modelType{10} = [0 1 0 1];
modelType{11} = [0 0 1 1];

modelStimulus{6} = [posgrid hdgrid];
modelStimulus{7} = [posgrid speedgrid];
modelStimulus{8} = [posgrid thetaGrid];
modelStimulus{9} = [hdgrid speedgrid];
modelStimulus{10} = [hdgrid thetaGrid];
modelStimulus{11} = [speedgrid thetaGrid];

% One stimulus variable
modelType{12} = [1 0 0 0];
modelType{13} = [0 1 0 0];
modelType{14} = [0 0 1 0];
modelType{15} = [0 0 0 1];

modelStimulus{12} = [posgrid];
modelStimulus{13} = [hdgrid];
modelStimulus{14} = [speedgrid];
modelStimulus{15} = [thetaGrid];

% Use all models
selected_models = 1:(numModels);
% For each model fit the parameters of the model
for n = selected_models
    
    % **Print** Current model
    fprintf('\t- Fitting model %d of %d\n', n, numModels);
    currStimulus = modelStimulus{n};
    if config.fPhaseLocking
        currStimulus = [currStimulus phaseLockGrid];
    end

    [testFitMetrics{n},trainFitMetrics{n},param{n}, kfoldsParam{n}] = fit_model(currStimulus,  learnedParameters.spiketrain(train_ind), ...
        modelType{n}, numFolds, config, designMat, initTrainParam);
end

% If we have not learned a certain model - put nans in his metrics ans zero
% in his params
notselected = setdiff(1:numModels, selected_models);
for j = notselected
    testFitMetrics{j} =  nan(numFolds,6);
    trainFitMetrics{j} =  nan(numFolds,6);
    param{j} = 0;
end

end