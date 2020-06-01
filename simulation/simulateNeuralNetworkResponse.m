function [firingRate] = simulateNeuralNetworkResponse(numOfNeurons, stimulus, tuningParames, historyFilters, couplingfilters,...
    bias,  dt, simulationLength, historyFilterLen)

% Get coupling filter length
couplingfilterLen = size(couplingfilters,1);

% Set linear projection, lambdas and interaction values and firing rate
linearProjection = zeros(simulationLength,numOfNeurons);
lambdas = zeros(simulationLength,numOfNeurons);
interactionValue = zeros(simulationLength,numOfNeurons);
firingRate = zeros(simulationLength,numOfNeurons);

numberOfSpikes = zeros(1,numOfNeurons);

% For each neuron calculate - W * X + b for every time step
for i = 1:numOfNeurons
    linearProjection(:,i) = linearProjection(:,i) + stimulus{i} * tuningParames{i}' + bias(i);
end

% draw time of next spike (in rescaled time) 
tspnext = exprnd(1,1,numOfNeurons); 

% Integrated lambdas up to current point
lambdaPrev = zeros(1,numOfNeurons); 

% How much bins to include in each loop iteration
nbinsPerEval = 1;

% loop index
currIndex = 1;

fireTogetherCounter = 0;

while currIndex < simulationLength
    
    % Bins to update in this iteration
    binsToUpddate = currIndex:min(currIndex+nbinsPerEval-1,simulationLength);
    
    % Number of bins in current iteration
    nCurrBins = length(binsToUpddate);
    
    % Get current lmbdas by using exponent function
    currLambdas = exp(linearProjection(binsToUpddate,:) + interactionValue(binsToUpddate,:))*dt; 
    
    % Save lambdas
    lambdas(binsToUpddate,:) = currLambdas;
    
    % Caclulate the cumulative intensity
    rrcum = cumsum(currLambdas+[lambdaPrev;zeros(nCurrBins-1,numOfNeurons)],1);  
    
    % If we passed the threshold(random exp value with mean 1), we have a spike 
    if all(tspnext >= rrcum(end,:)) 
        
        % No spike in this window
        
        % Update index for next iteration 
        currIndex = binsToUpddate(end)+1;
        
        % Set the prev lambda to be current cumaltive lambda
        lambdaPrev = rrcum(end,:);
    else
        
        % We had a spike in this iteration
        
        % Get i and j indexes of current spikes(j is the neuron id and i is
        % the bin in the current iteration
        [ispks,jspks] =  find(rrcum>=repmat(tspnext,nCurrBins,1));
        
        % Get the index of neurons that spike in this iteration
        spcells = unique(jspks(ispks == min(ispks)));
        
        % In case we had more two or more neurons that fired on the same
        % tim bin, record it
        if length(spcells) > 1
            fireTogetherCounter = fireTogetherCounter + 1;
        end
        
        % Get the time bin of the first spike
        ispk = binsToUpddate(min(ispks));
        
        % Get the accumulated lambda of all neurons until the spike time
        lambdaPrev = rrcum(min(ispks),:);
        
        
        % Detrime the bins to update for history and coupling
        currHistoryFilterIndex = min(simulationLength, ispk + historyFilterLen);
        currCouplingIndex = min(simulationLength, ispk + couplingfilterLen);
        
        % Specifiy the bins range
        iicouplingPost = ispk+1:currCouplingIndex;
        iiPostSpk = ispk+1:currHistoryFilterIndex;
        
        % Record neurons that spiked
        for index = 1:length(spcells)
            
            % Current neuron to udate
            currNeuron = spcells(index);
            
            % Update number of neurons
            numberOfSpikes(currNeuron) = numberOfSpikes(currNeuron)+1;
            
            % Record spike for current neuron
            firingRate(currIndex,currNeuron) = 1;
            
            % TODO: find better solution for the explosion problem
            % If the interaction value of the neurons is bigger then a
            % Threshold set the history filter instead of adding it
            if max(interactionValue(iiPostSpk,currNeuron)) > 5
                interactionValue(iiPostSpk,currNeuron) =  historyFilters(1:currHistoryFilterIndex-ispk,currNeuron);
            else
                interactionValue(iiPostSpk,currNeuron) = interactionValue(iiPostSpk,currNeuron) + historyFilters(1:currHistoryFilterIndex-ispk,currNeuron);
            end
            
            % Set the interaction filters
            interactionValue(iicouplingPost,:) = interactionValue(iicouplingPost,:) + couplingfilters(1:(currCouplingIndex-ispk),:,currNeuron);
            
            % Reset the cell lambdas
            lambdaPrev(currNeuron) = 0;
            
            % draw sample  for the next spike
            tspnext(currNeuron) = exprnd(1);
        end
        
        % Move to next iteration
        currIndex = ispk+1;
    end
end

fireTogetherCounter
end