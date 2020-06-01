function [firingRate, finalLambdas, linearProjection] = simulateNeuronResponse(stimulus, tuningCurves, learnedParams, fCoupling,  numOfCoupledNeurons, couplingData,...
    dt, config,phaseGrid,fPlot,realSpikes)

simulationLength = size(stimulus, 1);

% Set linear projection, lambdas  history interaction values mixed stimulus
% and firing rate
firingRate = zeros(simulationLength, 1);
linearProjection = zeros(simulationLength, 1);
historyInteraction = zeros(simulationLength, 1);
thetaPhaseCurrent = zeros(simulationLength, 1);
lambdas =  zeros(simulationLength, 1);
mixedStimulus = zeros(simulationLength, 1);
if config.fFirstSpike && config.fCoupling
    firstSpikeFilterLen = length(learnedParams.firstSpikeFilter);
end

% Number of bins to update in each iteration
nbinsPerEval = 1;

% calculate - W * X + b for every time step
linearProjection = stimulus * tuningCurves' + learnedParams.biasParam;

% In case we have history/coupling interaction
if fCoupling
    
    % Get the history filter length
    spikeHistoryFilterLength = length(learnedParams.spikeHistory);
    
    % Run for each coupled neuron
    for j = 1:numOfCoupledNeurons
        
        % Caclulatr the influence of the inteacted neuron on the simulated
        % neuron(using pre-defined spikes)
        coupledConv = conv2(couplingData.data(j).spiketrain, learnedParams.couplingFilters(:,j),'full');
        
        % In case of causal interaction, the interaction starts
        % one time bin after the coupled neuron spike, if we use acuasal
        % interaction the interaction starts in a pre defined window(timeBeforeSpike) before the coupled neuron spike
        if config.acausalInteraction
        coupledConv = [coupledConv(config.timeBeforeSpike:end - length(learnedParams.couplingFilters(:,j)) + config.timeBeforeSpike)];
        else 
            coupledConv = [0; coupledConv(1:end - length(learnedParams.couplingFilters(:,j)))];
        end
        
        % Update the linear projection to include the interaction
        % information
        linearProjection = linearProjection + coupledConv;
    end
end

% Integrated lambdas up to current point
lambdaPrev = 0;

numOfSpikes = 0;

% draw time of next spike (in rescaled time) 
tspnext = exprnd(1);

% Loop index
currIndex = 2;

while currIndex < simulationLength 
    
    phaseLockingInd = max(1, currIndex - config.phaseLockWindow);
    if config.fPhaseLocking &&  sum(firingRate(phaseLockingInd:currIndex - 1)) == 0
        linearProjection(currIndex) = linearProjection(currIndex) +  learnedParams.phaseLockParams(phaseGrid(currIndex,:) > 0);
    end
    
    % Get indexes to update in current iteration
    currBins = currIndex:min(currIndex+nbinsPerEval-1,simulationLength);

    % Linear projection of both stimulus history and coupling(if used)
    mixedStimulus(currBins) = linearProjection(currBins) + historyInteraction(currBins);

    % Get current lmbdas by using exponent function
    currLambdas=  exp(mixedStimulus(currBins)) * dt;
    
    if fCoupling
        currLambdas = min(0.3, currLambdas);
    end
    
    % Update lambdas of current bins
    lambdas(currBins) = currLambdas;

    % Caclulate the cumulative intensity
    rrcum = cumsum(currLambdas) + lambdaPrev;
    
    % If we passed the threshold(random exp value with mean 1), we have a spike 
    if (tspnext >= rrcum(end)) 
        
        % No spike in this window
        
        % Update index for next iteration 
        currIndex = currBins(end)+1;
        
        % Set the prev lambda to be current cumaltive lambda
        lambdaPrev = rrcum(end);
        
    else
        
        % We had a spike in this iteration
        
        % Get spike index
        ispk =  currBins(find(rrcum>=tspnext, 1, 'first'));
        
        % Update number of spikes
        numOfSpikes = numOfSpikes + 1;
        
        % Record spike
        firingRate(ispk) = 1;
        
        % If we have an history filter
        if fCoupling
            
            minInd = max(1,ispk - config.firstSpikeWindow);
            if config.fFirstSpike && sum(firingRate(minInd:ispk - 1)) == 0
                filterEnd = min(simulationLength, ispk+firstSpikeFilterLen); 
                iiPostSpk = ispk+1:filterEnd; 
                historyInteraction(iiPostSpk) =  historyInteraction(iiPostSpk) + learnedParams.firstSpikeFilter(1:length(iiPostSpk));

            end          
            
            % determine bins for adding post spike filter
            currHistoryFilterIndex = min(simulationLength, ispk+spikeHistoryFilterLength); 
            
            % time bins affected by post-spike filter
            iiPostSpk = ispk+1:currHistoryFilterIndex; 
            
            % TODO: find better solution for the explosion problem
            % If the interaction value of the neurons is bigger then a
            % Threshold set the history filter instead of adding it
            historyInteraction(iiPostSpk) = historyInteraction(iiPostSpk) + learnedParams.spikeHistory(1:length(iiPostSpk));
            
        end
        
        % draw next spike time
        tspnext = exprnd(1);  
        
        % Reset the neuron lambda
        lambdaPrev = 0; 
        
        % Update index of next iteration
        currIndex = ispk+1;
        muISI = currIndex/(sum(numOfSpikes));
%        nbinsPerEval = max(20, round(1.5*muISI)); 
    end
    
end

% Plot the information of current simulation if configured
if fPlot
    figure();
    subplot(6,1,1);
    tmp = ones(sum(firingRate), 1);
    tmp2 = ones(sum(realSpikes), 1);

    real = find(realSpikes);
    time = linspace(dt, simulationLength * dt, simulationLength);
    spiketimes = find(firingRate);
    plot(spiketimes * dt + dt/2, tmp, '.k', real* dt, tmp2, '.r');
    title(['spike train, exp:  ' num2str(sum(realSpikes)) ' , sim:  ' num2str(sum(firingRate))]);
    subplot(6,1,2);
    plot(time, linearProjection,'-k', spiketimes * dt, linearProjection(spiketimes), '.b',real * dt, linearProjection(real), '.r');
    title('stimulus');
    subplot(6,1,3);
    plot(time, historyInteraction,'-k', spiketimes * dt, historyInteraction(spiketimes), '.b',real * dt, historyInteraction(real), '.r');
    title('spike history');

    subplot(6,1,4);
    plot(time, lambdas,'-k', spiketimes * dt, lambdas(spiketimes), '.b',real * dt, lambdas(real), '.r');
    title('lambda');
    subplot(6,1,5);
    plot(time, mixedStimulus,'-k', spiketimes * dt, mixedStimulus(spiketimes), '.b',real * dt, mixedStimulus(real), '.r');
    title('mixedStimulus');
    subplot(6,1,6);
    plot(time, cumsum(firingRate),'-k', time , cumsum(realSpikes), '-r');
    title('Cumulative spikes');
    drawnow;
end

% Record lambdas
finalLambdas = exp(linearProjection + historyInteraction) * dt;
linearProjection = linearProjection + historyInteraction;
end


