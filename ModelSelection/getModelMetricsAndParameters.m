function [metrics, learnedParams, smoothPsthExp, smoothPsthSim, ISI, modelFiringRate, totalLogLikelihood] = ...
    getModelMetricsAndParameters(config, spiketrain, stimulus, modelParams,...
    modelType, filter, numOfCoupledNeurons, couplingData, historyBaseVectors, couplingBaseVectors, thetaGrid, kFoldParams)

numOfFilters = 4;
if config.fPhaseLocking
    numOfFilters = numOfFilters  + 1;
end
simulationLength = length(spiketrain);
modelFiringRate = zeros(simulationLength, config.numOfRepeats);
simISI = [];
mean_fr = nanmean(spiketrain);

% Get the learned parameters for the choosed model
learnedParams = getLearnedParameters(modelParams, modelType, config, kFoldParams, historyBaseVectors, numOfCoupledNeurons, couplingBaseVectors);

% In case we have interaction filter, plot the k folds learned interactions
if config.fCoupling && numOfCoupledNeurons > 0
    figure();
    plot(learnedParams.kFoldsCoupling)
    title('Confidence interval coupling ');
    close(gcf)

end


% Caclulate the mean firing rate log likelihood, we will use it to comapre
% to the model log likelihood
log_llh_mean = nansum(mean_fr - spiketrain .* log(mean_fr) + log(factorial(spiketrain))) / sum(spiketrain);
totalLogLikelihood = 0;

% Run for x repeats
for i = 1:config.numOfRepeats

    % Get simulated firing rate
    [modelFiringRate(:,i), modelLambdas, linearProjection] = simulateNeuronResponse(stimulus, learnedParams.tuningParams, learnedParams,...
        config.fCoupling, numOfCoupledNeurons, couplingData, config.dt, config,thetaGrid,0, spiketrain);  
    
    % Caclulate the log likelihood for current simulation
    log_llh_model = nansum(modelLambdas - spiketrain.*log(modelLambdas) + log(factorial(spiketrain))) / sum(spiketrain);
    
    % Caclulate the increase of currnet log likelihood from mean firing
    % rate
    log_llh = log(2) * (-log_llh_model + log_llh_mean);
    
    % Add current log likelihood to the total amount
    totalLogLikelihood = totalLogLikelihood + log_llh;
    
    % Get current simulation interspike interval
    simISI = [simISI diff(find(modelFiringRate(:,i)))'];
    
    % TBD: decide if we want to use the lambdas or the simulated spike
    % train as the firing rate
    %modelFiringRate(:,i) = modelLambdas;

end

% Get the mean of total log likelihood
totalLogLikelihood = totalLogLikelihood / config.numOfRepeats;
totalLogLikelihood

% get the mean firing rate of the model
meanModelFiringRate = sum(modelFiringRate,2) / config.numOfRepeats;

% Get psth and metrics 
[metrics, smoothPsthExp, smoothPsthSim, ISI] = ...
    estimateModelPerformance(config.dt, spiketrain, meanModelFiringRate, filter, config.windowSize);

% Get inter spike interval of the experiment
maxSimISI = max(simISI);
simISIPr = zeros(maxSimISI, 1);
for j = 1:maxSimISI
    simISIPr(j) = sum(simISI == j);
end

simISIPr = simISIPr / sum(simISIPr);
simISITimes = linspace(1 * config.dt, maxSimISI * config.dt, maxSimISI);
ISI.simISITimes = simISITimes;
ISI.simISIPr = simISIPr;

% Get the learned tuning curves
[learnedParams.pos_param, learnedParams.hd_param, learnedParams.speed_param, learnedParams.theta_param, learnedParams.phaseLockParams] = ...
    find_param(learnedParams.allTuningParams, modelType, config.numOfPositionParams, config.numOfHeadDirectionParams, ...
    config.numOfSpeedBins, config.allTheta,  config.fPhaseLocking, config.numOfPhaseLockingFilters);


% IF the curves are not configured in the model, zeroize
if numel(learnedParams.pos_param) ~= config.numOfPositionParams
    learnedParams.pos_param = 0;
    numOfFilters = numOfFilters - 1;
end
if numel(learnedParams.hd_param) ~= config.numOfHeadDirectionParams
    learnedParams.hd_param = 0;
    numOfFilters = numOfFilters - 1;
end
if numel(learnedParams.speed_param) ~= config.numOfSpeedBins
    learnedParams.speed_param = 0;
    numOfFilters = numOfFilters - 1;
end
if numel(learnedParams.theta_param) ~= config.allTheta
    learnedParams.theta_param = 0;
    numOfFilters = numOfFilters - 1;
end

learnedParams.numOfFilters = numOfFilters;
end