function dumpInputToFile(sessionName, neuronNumber, features, validationFeatures, learningData, validationData,boxSize, sampleRate)
xAxisBins = features.xBins;
yAxisBins = features.yBins;
hdBins = features.hdVec;
speedBins = features.speedBins;
thetaBins = features.thetaVec;


trainPosGrid = features.posgrid;
trainHdGrid = features.hdgrid;
trainSpeedGrid = features.speedgrid;
trainSpeed = features.speed;
trainThetaGrid = features.thetaGrid;
trainPosx = learningData.posx;
trainPosy = learningData.posy;
trainThetaPhase = learningData.thetaPhase;
trainHeadDirection = learningData.headDirection;
trainSpikes = learningData.spiketrain;

testPosGrid = validationFeatures.posgrid;
testHdGrid = validationFeatures.hdgrid;
testSpeedGrid = validationFeatures.speedgrid;
testSpeed = validationFeatures.speed;
testThetaGrid = validationFeatures.thetaGrid;
testPosx = validationData.posx;
testPosy = validationData.posy;
testThetaPhase = validationData.thetaPhase;
testHeadDirection = validationData.headDirection;
testSpikes = validationData.spiketrain;

save(['../Input/' sessionName '/inputVars_' num2str(neuronNumber)], 'boxSize','sampleRate',...
    'trainPosGrid', 'xAxisBins', 'yAxisBins', 'trainHdGrid', 'hdBins',... 
    'trainSpeedGrid', 'trainSpeed', 'speedBins','trainThetaGrid', 'thetaBins',...
    'testPosGrid', 'testHdGrid', 'testSpeedGrid', 'testSpeed', 'testThetaGrid',...
    'trainPosx','trainPosy', 'trainThetaPhase', 'trainHeadDirection', '',...
    'testPosx','testPosy', 'testThetaPhase', 'testHeadDirection',...
    'testSpikes','neuronNumber', 'trainSpikes', 'testSpikes', '-v7.3');

end