function [pos_curve, hd_curve, speed_curve, thetaCurve] = computeTuningCurves(dataForLearning, features, config, spiketrain)

% calculate the firing rate
firingRate = spiketrain / config.dt;

% Use pre-defined speed vec 
speedVec = [config.speedVec config.maxSpeed];

% compute tuning curves for position, head direction, speed, and theta phase
[pos_curve] = compute_2d_tuning_curve(dataForLearning.posx, dataForLearning.posy,firingRate,config.numOfPositionAxisParams, [0 0], config.boxSize);
[hd_curve] = compute_1d_tuning_curve(dataForLearning.headDirection, firingRate, config.numOfHeadDirectionParams, 0, 2*pi);

[speed_curve] = compute_1d_tuning_curve_withInputVec(features.speed,  firingRate, config.numOfSpeedBins, speedVec);
[thetaCurve] = compute_1d_tuning_curve(dataForLearning.thetaPhase, firingRate, config.numOfTheta, 0, 2*pi);

end