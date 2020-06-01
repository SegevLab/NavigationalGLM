function [top1, selectedModel, modelScores] = selectBestModelBySimulation(modelInd, modelTypes, modelParams, numOfRepeats, config, historyBaseVectors, simFeatures, simspiketrain,kFoldParams, numOfCoupledNeurons,couplingBaseVectors, couplingData)

modelScores = nan(numOfRepeats, config.numModels);
% Get length of the validation set
validationLength = length(simspiketrain) * config.validationRatio;
validInd = 1:validationLength;
validationCoupling = couplingData;
validationSpiketrain = simspiketrain(validInd);

% Get only current fold spike train for each coupled neuron
for k = 1:numOfCoupledNeurons
    validationCoupling.data(k).spiketrain = couplingData.data(k).spiketrain(validInd);
end
% Calculate the length of each fold in the validation set
foldLength = ceil(validationLength / numOfRepeats);
'current model '

for i = modelInd
    i
    
    % Get model info: type, params etc'
    modelParam = modelParams{i};
    modelType = modelTypes{i};
    kfoldParam = kFoldParams{i};
    
    % Fetch the curent model params
    learnedParam = getLearnedParameters(modelParam, modelType, config, kfoldParam, historyBaseVectors,...
        numOfCoupledNeurons, couplingBaseVectors);
    
    % Get current model stimulus
    stimulus = getStimulusByModelNumber(i, simFeatures.posgrid(validInd,:), simFeatures.hdgrid(validInd,:),...
        simFeatures.speedgrid(validInd,:), simFeatures.thetaGrid(validInd,:));
    % Run for x repeats
    for j = 1:numOfRepeats
        
        % Get current iteration last index
        cuurStep = min(j * foldLength,validationLength);
        
        % Get current iteration spike train
        currspiketrain = validationSpiketrain((j-1) * foldLength + 1:cuurStep,:);
        
        % Get current iteration mean firing rate
        curr_mean_fr = nanmean(currspiketrain);
        
        % Mean firing rate log likelihood
        log_llh_mean = nansum(curr_mean_fr - currspiketrain .* log(curr_mean_fr) + log(factorial(currspiketrain))) / sum(currspiketrain);
        
        % Get curr stimulus
        currStimulus = stimulus((j-1) * foldLength + 1:cuurStep,:);
        
        currCoupling = validationCoupling;
        
        % Get only current fold spike train for each coupled neuron
        for k = 1:numOfCoupledNeurons
            currCoupling.data(k).spiketrain = currCoupling.data(k).spiketrain((j-1) * foldLength + 1:cuurStep);
        end
        
        % Simulate model response and get lambdas 
        [~, modelLambdas, linearProjection] = simulateNeuronResponse(currStimulus, learnedParam.tuningParams, learnedParam, config.fCoupling, numOfCoupledNeurons, currCoupling, config.dt, config,simFeatures.thetaGrid, 0, []);   
        
        % Calculate model log likelihood
        log_llh_model = nansum(modelLambdas - currspiketrain.*log(modelLambdas) + log(factorial(currspiketrain))) / sum(currspiketrain);
        
        % Caclulate log likelihodd increase from mean firing rate
        log_llh = log(2) * (-log_llh_model + log_llh_mean);
        
        % record log likelihood increase from mean firing rate
        modelScores(j,i) = log_llh;
    end
end


% find the best single model
singleModels = 12:15;
[max1, top1] = max(nanmean(modelScores(:,singleModels))); top1 = top1 + singleModels(1)-1;

% find the best double model that includes the single model
 if top1 == 12 % P -> PH,PS, PT
     [~,top2] = max(nanmean(modelScores(:,[6 7 8])));
     vec = [6 7 8]; top2 = vec(top2);
 elseif top1 == 13 % H -> PH, HS, HT
     [~,top2] = max(nanmean(modelScores(:,[6 9 10])));
     vec = [6 9 10]; top2 = vec(top2);
 elseif top1 == 14 % S -> PS, HS, ST
     [~,top2] = max(nanmean(modelScores(:,[7 9 11])));
     vec = [7 9 11]; top2 = vec(top2);
 elseif top1 == 15 % T -> PT, HT, ST
     [~,top2] = max(nanmean(modelScores(:,[8 10 11])));
     vec = [8 10 11]; top2 = vec(top2);
end
 
if top2 == 6 % PH -> PHS, PHT
     [~,top3] = max(nanmean(modelScores(:,[2 3])));
     vec = [2 3]; top3 = vec(top3);
 elseif top2 == 7 % PS -> PHS,  PST
     [~,top3] = max(nanmean(modelScores(:,[2 4])));
     vec = [2 4]; top3 = vec(top3);
 elseif top2 == 8 % PT -> PHT,  PST
     [~,top3] = max(nanmean(modelScores(:,[3 4])));
     vec = [3 4]; top3 = vec(top3);
 elseif top2 == 9 % HS -> PHS,  HST
     [~,top3] = max(nanmean(modelScores(:,[2 5])));
     vec = [2 5]; top3 = vec(top3);
 elseif top2 == 10 % HT -> PHT, HST
     [~,top3] = max(nanmean(modelScores(:,[3 5])));
     vec = [3 5]; top3 = vec(top3);
 elseif top2 == 11 % ST -> PST, HST,
     [~,top3] = max(nanmean(modelScores(:,[4 5])));
     vec = [4 5]; top3 = vec(top3);
end

top4 = 1;
 
% If we have model that is nan, put -1 insted
modelScores(isnan(modelScores)) = -1;

% Get Log likelihood values for each step
LL1 = modelScores(:,top1);
LL2 = modelScores(:,top2);
LL3 = modelScores(:,top3);
LL4 = modelScores(:,top4);

% signifacne test for increase of n step from n+1 step model
[p_LL_12,~] = signrank(LL2,LL1,'tail','right');
[p_LL_23,~] = signrank(LL3,LL2,'tail','right');
[p_LL_34,~] = signrank(LL4,LL3,'tail','right');

% If the increase is signifacnt choose the better model

if p_LL_12 < 0.01 
    if p_LL_23 < 0.01
        if p_LL_34 < 0.01
            selectedModel = top4;
        else
            selectedModel = top3;
        end
    else
        selectedModel = top2;
    end
else
    selectedModel = top1;
end

end
