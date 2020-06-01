function [couplingDesignMatrix] = buildCouplingDesignMatrix(numOfBaseVectors, baseVectors,spikeTrain, timeBeforeSpike, acausalInteraction)

    % calculate the  base vectors
    [lengthOFBaseVectors,~] = size(baseVectors);
    
    % Do convolution and remove extra bins
    couplingDesignMatrix = conv2(spikeTrain,baseVectors,'full');
    
    % In case we use acausal interaction, we take some time before spike 
    if acausalInteraction 
        couplingDesignMatrix = [couplingDesignMatrix(timeBeforeSpike:end - lengthOFBaseVectors + timeBeforeSpike,:)];
    else
        couplingDesignMatrix = [zeros(1,numOfBaseVectors); couplingDesignMatrix(1:end - lengthOFBaseVectors,:)];
    end
    
end