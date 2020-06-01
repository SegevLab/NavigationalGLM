function psth =  computePSTH(spiketrain, windowSize)

    spikeTimes = find(spiketrain);
    spikeTrainLength = length(spiketrain);
    psthLength = ceil(spikeTrainLength / windowSize);
    psthBins = linspace(0, spikeTrainLength, psthLength + 1);
    
    % Bin to psth using histcounts
    psth = histcounts(spikeTimes', psthBins);
    psth(1:100)
end