function [testFit,trainFit,param_mean, paramMat] = fit_model(features, spiketrain, modelType, numFolds, config, designMatrix, initTrainParam)

% **Print** - Model type
modelType

% Get the num of stimulus params
[~,numStimulusParams] = size(features);
% Calculate length of each fold
lengthOfFold = floor(numel(spiketrain) / numFolds);

% initialize metrics 

% var ex, correlation, llh increase, mse, # of spikes, length of test data
testFit = nan(numFolds,6); 
% var ex, correlation, llh increase, mse, # of spikes, length of train data
trainFit = nan(numFolds,6); 

% If we use history/coupling filter - get the number of params
if config.fCoupling
    numOfCouplingParams = size(designMatrix,2);
else
    numOfCouplingParams = 0;
end

% Num of params is include stimulus coupling and bias params
numOfLearnedParams = numStimulusParams + numOfCouplingParams + 1;

initStimParams = fillInitParams(initTrainParam, modelType, config.fPhaseLocking, config);

%Build params matrix for each fold
paramMat = nan(numFolds,numOfLearnedParams);

% perform k-fold cross validation
for k = 1:numFolds
    
    % **Print** - print current cross validation
    fprintf('\t\t- Cross validation fold %d of %d\n', k, numFolds);
    
    % Divide data to train and test
    test_ind  = (k-1) * lengthOfFold + 1:k * lengthOfFold;
    train_ind = setdiff(1:numel(spiketrain),test_ind);
     %train_ind  = (k-1) * lengthOfFold + 1:k * lengthOfFold;
     %test_ind = setdiff(1:numel(spiketrain),train_ind);

    % Get test data: spikes, stimulus and coupling information
    test_spikes = spiketrain(test_ind);
    test_features = features(test_ind,:);
    if config.fCoupling
        test_designMat = designMatrix(test_ind,:);
    end
    
    % Get train data: spikes, stimulus and coupling information
    train_spikes = spiketrain(train_ind);
    spTimes = find(train_spikes);
    isiInd = [0; diff(spTimes)];
    train_spikes(spTimes(isiInd == 1)) = 0;  
    train_features = features(train_ind,:);
    if config.fCoupling
        train_designMat = designMatrix(train_ind,:);
    end
    
    % Set optimizations params
    opts = optimset('Gradobj','on','Hessian','on','Display','off');
    
    % Set params for learning 
    trainData{1} = train_features;
    testData{1} = test_features;

    if config.fCoupling
        trainData{2} = train_designMat;
        testData{2} = test_designMat;
    end
    trainData{3} = train_spikes;
    testData{3} = test_spikes;

    % For the first fold, initalize params randomly, after this step use
    % the prev fold learned param
    if k == 1
        init_param =  1e-3*randn(numOfLearnedParams, 1);
        init_param(end - numStimulusParams + 1:end) = initStimParams;
    else
        init_param = param;
    end
    
    % Define the loss function
    lossFunc  = @(param)ln_poisson_model(param,trainData,modelType, config, numOfCouplingParams);
    
    % Run optimization to current fold
    [param] = fminunc(lossFunc, init_param, opts);

    % Get the bias param of current fold
    biasParam = param(1);

    % Get spike history and coupling as well as stimulus params that was
    % learned
    if config.fCoupling
       spikeHistoryParam = param(2:1 + numOfCouplingParams); 
       tuningParams = param(2 + numOfCouplingParams:end);
    else
        tuningParams = param(2:end);
    end
    
    % **** Test metrics *****
    
    % Get the linear filter projection
    linearFilter_hat_test = test_features * tuningParams + biasParam;
    
    % Add history and coupling information if configured
    if config.fCoupling
        linearFilter_hat_test = linearFilter_hat_test + test_designMat * spikeHistoryParam;
    end
    
    % Calculate the firing rate estimation for test set
    fr_hat_test = exp(linearFilter_hat_test) * config.dt;
        
    % compare between test fr and model fr
    
    % sse - Sum of squared errors
    sse = sum((fr_hat_test-test_spikes).^2);
    
    % sst - Total sum of squares 
    sst = sum((fr_hat_test-mean(test_spikes)).^2);
    
    % TODO: Remove if sst is not zero anymore
    if sst == 0
        sst = sse;
    end
    
    % Calculate fraction of explained variance
    varExplain_test = 1-(sse/sst);
    
    % compute correlation
    correlation_test = corr(test_spikes,fr_hat_test,'type','Pearson');
    
    % compute llh increase from "mean firing rate model" - NO SMOOTHING
    
    % The log likelihood of the model - test set
    log_llh_test_model = nansum(fr_hat_test - test_spikes.*log(fr_hat_test) + log(factorial(test_spikes))) / sum(test_spikes);
    
    mean_fr_test = nanmean(test_spikes);
    
    % Mean log likelihood - test set
    log_llh_test_mean = nansum(mean_fr_test - test_spikes .* log(mean_fr_test) + log(factorial(test_spikes))) / sum(test_spikes);
    
    % Log likelihood increase from mean - test set
    log_llh_test = log(2) * (-log_llh_test_model + log_llh_test_mean);
    
    % TODO: Remove if log_llh_test is not +-inf anymore
    if log_llh_test == inf || log_llh_test == -inf
        log_llh_test = nan;
    end
    
    
    % compute MSE - mean squared error - test set
    mse_test = nanmean((fr_hat_test-test_spikes).^2);

    % fill in all the relevant values for the test set cases
    testFit(k,:) = [varExplain_test correlation_test log_llh_test mse_test sum(test_spikes) numel(test_ind)];

    % **** Test metrics *****

    % Get the linear filter projection
    linearFilter_hat_train = train_features * tuningParams + biasParam;
    
    % Add history and coupling information if configured
    if config.fCoupling
        linearFilter_hat_train = linearFilter_hat_train + train_designMat * spikeHistoryParam;
    end
    
    % Calculate the firing rate estimation for train set
    fr_hat_train = exp(linearFilter_hat_train) / config.dt;
    
    % compare between test fr and model fr
    
    % sse - Sum of squared errors
    sse = sum((fr_hat_train-train_spikes).^2);
    
    % sst - Total sum of squares 
    sst = sum((fr_hat_train-mean(train_spikes)).^2);
    
    % Calculate fraction of explained variance
    varExplain_train = 1-(sse/sst);
    
    % compute correlation
    correlation_train = corr(train_spikes,fr_hat_train,'type','Pearson');
    
    % compute llh increase from "mean firing rate model" - NO SMOOTHING
    
    % The log likelihood of the model - train set
    log_llh_train_model = nansum(linearFilter_hat_train - train_spikes.*log(linearFilter_hat_train) + log(factorial(train_spikes))) / sum(train_spikes);
    
    mean_fr_train = nanmean(train_spikes);
    
    % Mean log likelihood - train set
    log_llh_train_mean = nansum(mean_fr_train - train_spikes .* log(mean_fr_train) + log(factorial(train_spikes))) / sum(train_spikes);
    
    % Log likelihood increase from mean - train set
    log_llh_train = log(2) * (-log_llh_train_model + log_llh_train_mean);

    % TODO: Remove if log_llh_train is not +-inf anymore
    if log_llh_train == inf || log_llh_train == -inf
        log_llh_train = 0;
    end
    
    % compute MSE - mean sqaured error - train set
    mse_train = nanmean((fr_hat_train - train_spikes).^2);
    
    % fill in all the relevant values for the train set cases
    trainFit(k,:) = [varExplain_train correlation_train log_llh_train mse_train sum(train_spikes) numel(train_ind)];
    
    % Save params of current fold
    paramMat(k,:) = param;
    

end

% Return the mean params for k folds
param_mean = nanmean(paramMat);

return
