function [config, learningData, couplingData, validationData, validationCouplingData,...
    isi, posx, posy, boxSize,sampleRate,headDirection, phase,spiketrain, allCouplingData] = loadDataForLearning(folderPath,  configFilePath, neuronNumber, fCoupling, coupledNeurons)

% First load the config file
load(configFilePath);

% Deefine phase to be non for cases we don't have theta phase data
phase = [];

% *********** Global config **************

% Box size is loaded from config
config.boxSize = boxSize;

% The window size to use for psth
config.windowSize = 20;

config.fCoupling = fCoupling;
config.fFirstSpike = 1;

config.firstSpikeWindow = 35;
% The rate that we use for the analysis
config.sampleRate = 1000;
config.dt = 1/1000;

% The rate for the psth 
config.psthdt = 1/1000 * config.windowSize;

% Number of folds to use
config.numFolds = 4;

% Num of models we compare
config.numModels = 15;

% Num of repeats for simulation
config.numOfRepeats = 100;


% *********** Learned parametrs config **************

% Num of head direction params
config.numOfHeadDirectionParams = 30;

% num of spedd params
config.numOfSpeedBins = 8;
% Num of theta phase params
config.numOfTheta = 10;

config.allTheta = config.numOfTheta ;
% num of position in an axis params
config.numOfPositionAxisParams = 25;

% For a square 2D env, the number of position params is the power of one
% axis
config.numOfPositionParams = config.numOfPositionAxisParams * config.numOfPositionAxisParams;

% The number of all stimulus params
%config.numofTuningParams = config.numOfHeadDirectionParams + config.allTheta + config.numOfPositionParams + config.numOfSpeedBins;

% Max speed to use
config.maxSpeed = 50;

% speed bins
config.speedVec = [0 1 4 8 14 26 38 50];

%  ********************* Phase lock config *********************
config.fPhaseLocking = 1;
if fCoupling == 0
    config.fPhaseLocking = 0;
end
config.numOfPhaseLockingFilters = 10;
config.phaseLockWindow = 125;

%  ********************* History and coupling config *********************

% Num of history coefficent params
config.numOfHistoryParams = 16;

% num of coupling params
config.numOfCouplingParams = 1;

% Set to 1 in case we use acausal interaction
config.acausalInteraction = 0;

% In case we use acausal interaction, how much time before spike to model
config.timeBeforeSpike = 0;

% Last peak time for history(in seconds)
config.lastPeakHistory = 0.15;

% How linear is the change in the cosine bumps (bigger is more linear)
config.bForHistory = 0.02;

% Last peak time for coupling(in seconds)
config.lastPeakCoupling = 0.032;

% How linear is the change in the cosine bumps (bigger is more linear)
config.bForCoupling = 1;

% compute a filter, which will be used to smooth the firing rate
filter = gaussmf(-4:4,[2 0]);
filter = filter/sum(filter); 
config.filter = filter;

% ********** Load params for learning **********
load([folderPath num2str(neuronNumber)]);
spTimes = find(spiketrain);
isiInd = [0; diff(spTimes)];
spiketrain(spTimes(isiInd == 1 | isiInd == 2)) = 0;

% The ratio of training from the session
trainRatio = 0.8;
testRatio = 1 - trainRatio;
config.validationRatio = 0.25;
% Number of bins for training
% train_ind = 1:ceil(length(posx) * trainRatio);
% test_ind = setdiff(1:numel(posx),train_ind);

test_ind  = 1:ceil(length(posx) * testRatio);
train_ind = setdiff(1:numel(posx),test_ind);

% Get neuron number, position, head direction and spike train data of the neuron we want to
% learn
learningData.neuronNumber = neuronNumber;
learningData.posx = posx(train_ind);
learningData.posy = posy(train_ind);
learningData.headDirection = headDirection(train_ind);
learningData.spiketrain = spiketrain(train_ind);

fPhaseExist = 1;

% Check if we have phase data, add phase data in case we have, otherwise
% use zeros 
if length(phase) ~= length(posx)
    fPhaseExist = 0;
    'No phase in this neuron'
    learningData.thetaPhase = zeros(length(train_ind), 1);
else
    learningData.thetaPhase = phase(train_ind);
end

% Set valildation data
validationData.neuronNumber = neuronNumber;
validationData.posx = posx(test_ind);
validationData.posy = posy(test_ind);
validationData.headDirection = headDirection(test_ind);
validationData.spiketrain = spiketrain(test_ind);

% Check if we have phase data, add phase data in case we have, otherwise
% use zeros 
if fPhaseExist == 0
    validationData.thetaPhase = zeros(length(validationData.posx), 1);
else
    validationData.thetaPhase = phase(test_ind);
end

% ********** Calculate interspike interval **********
spikeDistance = diff(find(spiketrain));
maxISI = max(spikeDistance);
isi = zeros(maxISI, 1);
for i = 1:maxISI
    isi(i) = sum(i == spikeDistance);
end

isi = isi / length(spikeDistance);
% figure();
% subplot(2,1,1);
% plot(isi);
% xlim([0 50]);
% subplot(2,1,2);
% plot(cumsum(isi));
% xlim([0 100]);
ind = find(cumsum(isi) > 0.65);
config.firstSpikeWindow = min(150,ind(1));
%config.phaseLockWindow = config.firstSpikeWindow;

% ************ Base vectors for history and coupling ************

% Get refractory params
[learningData.refreactoryPeriod , learningData.ISIPeak] =  getRefractoryPeriodForNeurons(spiketrain, config.dt);

% Set first peak to be one time step after refactort period
firstPeak = learningData.refreactoryPeriod + config.dt;

% Set history peaks
historyPeaks = [firstPeak config.lastPeakHistory];

% Get history base vectors
[~, ~, learningData.historyBaseVectors] = buildBaseVectorsForPostSpikeAndCoupling(config.numOfHistoryParams,...
    config.dt, historyPeaks, config.bForHistory, learningData.refreactoryPeriod);

% Set coupling base vectors
couplingFilter = exp(-2:0.1:3);
couplingFilter = couplingFilter / max(couplingFilter);
couplingFilter = [0 0 fliplr(couplingFilter) 0];
learningData.couplingBaseVectors = couplingFilter';


couplingData = [];
validationCouplingData = [];
allCouplingData = [];
% ****** Add coupled neurons information for test and train
if config.fCoupling == 1

    % Get the position head direction and spike train of the coupled neurons
    % that we want to combine in the model
    for i = 1:length(coupledNeurons)
        
        % train params
        load([folderPath num2str(coupledNeurons(i))]);
        couplingData.data(i).posx  = posx(train_ind);
        couplingData.data(i).posy  = posy(train_ind);
        couplingData.data(i).headDirection  = headDirection(train_ind);
        couplingData.data(i).spiketrain  = spiketrain(train_ind);
        allCouplingData.data(i).spiketrain = spiketrain;
        % test params
        validationCouplingData.data(i).spiketrain  = spiketrain(test_ind);
    end
end

end