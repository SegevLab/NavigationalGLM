boxSize = [140, 20];
maxDistanceFromBorder = 8;
maxVelocityXAxis = 30;
maxVelocityYAxis = 30;
numOfDistanceFromBorderParams =  8;
numOfHeadDirectionParams = 20;
numOfPositionAxisParams = 20;
numOfVelocityAxisParams = 40;
sampleRate = 1000;
save('config','boxSize', 'maxDistanceFromBorder', 'maxVelocityXAxis', 'maxVelocityYAxis', 'numOfDistanceFromBorderParams',...
    'numOfHeadDirectionParams', 'numOfPositionAxisParams', 'numOfVelocityAxisParams', 'sampleRate');