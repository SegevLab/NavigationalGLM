function designMatrix = getSpikeHistoryAndCouplingDataForLearning(config, learningData, numOfCoupledNeurons, couplingData)



% Get histort desifn matrix
designMatrix = buildSpikeHistoryDesignMatrix(config.numOfHistoryParams,...
    learningData.historyBaseVectors, learningData.spiketrain, config.firstSpikeWindow);

if config.fFirstSpike
    firstSpikeDesignMatrix = builFirstSpikeDesignMatrix(config.numOfHistoryParams,...
    learningData.historyBaseVectors, learningData.spiketrain, config.firstSpikeWindow);
    designMatrix = [designMatrix firstSpikeDesignMatrix];

end

for i = 1:numOfCoupledNeurons
    % Get curent coupled neuron design matrix
    currCouplingMatrix = buildCouplingDesignMatrix(config.numOfCouplingParams, learningData.couplingBaseVectors,couplingData.data(i).spiketrain,...
        config.timeBeforeSpike, config.acausalInteraction);
    
    % concatenate design matrix
    designMatrix = [designMatrix currCouplingMatrix];
end

end