clear all;
networkName = '11025-19050503';
neuronNumber = 1;
load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuronNumber)]);
addpath('../General/');
sampleRate = 1000;
%speedBins = [0 1 2 4 8  10 15 20 25 30 35 40 45 50];
speedBins = linspace(0, 50, 6);
numOfSpeed = length(speedBins);
numOfTheta = 6;
thetaBins = linspace(0, 2 * pi, numOfTheta);

% Calculate velocity by using the difference between preceeding positions
velx = diff([posx(1); posx]);
vely = diff([posy(1); posy]); 

% Caclulate speed for each bin
speed = sqrt(velx.^2+vely.^2) * sampleRate;
spTimes = find(spiketrain);
plot3(posx,posy,headDirection, '-k', posx(spTimes),posy(spTimes),headDirection(spTimes), '.r');