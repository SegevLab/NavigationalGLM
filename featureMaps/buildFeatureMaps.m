function [features] = buildFeatureMaps(config, learningData)

% Build position design matrix
[features.posgrid, features.xBins, features.yBins] = pos_map([learningData.posx learningData.posy], config.numOfPositionAxisParams, config.boxSize);

% Build head direction design matrix
[features.hdgrid, features.hdVec] = hd_map(learningData.headDirection, config.numOfHeadDirectionParams);

% Build theta design matrix
[features.thetaGrid, features.thetaVec] = theta_map(learningData.thetaPhase, config.numOfTheta);

% Build speed design matrix
[features.speedgrid, features.speed, features.speedBins] = speed_map(learningData.posx,learningData.posy, config.sampleRate,...
    config.numOfSpeedBins, config.speedVec);

if config.fPhaseLocking
    [features.phaseLockGrid,features.phaseLock_vec] = trigered_theta_map(learningData.thetaPhase,config.numOfPhaseLockingFilters, learningData.spiketrain, config.phaseLockWindow);
end
end