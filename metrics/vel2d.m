clear all;
networkName = '11084-03020501';
neuronNumber = 6;
load(['../rawDataForLearning/' networkName '/data_for_cell_' num2str(neuronNumber)]);
addpath('../General/');
sampleRate = 1000;
%speedBins = [0 0.5 1 2 4 8  10 15 20 25 30 35 40 45 50];
speedBins = linspace(0, 50, 10);
numOfSpeed = length(speedBins);
numOfTheta = 30;

% Calculate velocity by using the difference between preceeding positions
velx = diff([posx(1); posx]) * sampleRate;
vely = diff([posy(1); posy]) * sampleRate; 

tuneMap = compute_2d_tuning_curve(velx, vely,spiketrain,10,[-50 -50], [50 50]);
imagesc(tuneMap * sampleRate)
colorbar;
colormap jet;
xlabel('Speed');
ylabel('Phase');