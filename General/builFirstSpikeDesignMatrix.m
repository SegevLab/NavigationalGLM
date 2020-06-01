function [spikeHistoryDesignMatrix] = builFirstSpikeDesignMatrix(numOfBaseVectors, baseVectors,spikeTrain, firstSpikeWindow)

    % calculate the  base vectors
    [lengthOFBaseVectors,~] = size(baseVectors);
    
    % Do convolution and remove extra bins, shift one been for time after
    % spike
    spTimes= find(spikeTrain);
    isi = diff(spTimes);
    isi = [firstSpikeWindow; isi];
    ind = isi < firstSpikeWindow;
    spTimesClean = spTimes(ind);
    spikeTrain(spTimesClean) = 0;
    spikeHistoryDesignMatrix = conv2(spikeTrain,baseVectors,'full');
    spikeHistoryDesignMatrix = [zeros(1,numOfBaseVectors); spikeHistoryDesignMatrix(1:end - lengthOFBaseVectors,:)];
end