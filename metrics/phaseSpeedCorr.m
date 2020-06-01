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
velx = velx * sampleRate;
vely = vely * sampleRate;

tuneMap = zeros(numOfTheta - 1, numOfSpeed - 1);
% find the mean firing rate in each position bin
for i  = 1:numOfTheta - 1
    
    % Get current bin limits
    start_theta = thetaBins(i);
    stop_theta = thetaBins(i+1);
    
    % find the times the animal was in the bin
    if i == numOfTheta - 1
        theta_ind = find(phase >= start_theta & phase <= stop_theta);
    else
        theta_ind = find(phase >= start_theta & phase < stop_theta);
    end
    
    % Run on the y axis
    for j = 1:numOfSpeed - 1

        % Get current bin limits
        start_speed = speedBins(j);
        stop_speed = speedBins(j+1);
        
        % find the times the animal was in the bin
        if j == numOfSpeed - 1
            speed_ind = find(speed >= start_speed );
        else
            speed_ind = find(speed >= start_speed & speed < stop_speed);

        end
        % get intersection indexes of the time for current x and y bins
        ind = intersect(theta_ind,speed_ind);
        
        % fill in rate map
        tuneMap(i, j) = mean(spiketrain(ind));
      
        
    end
end

%Smooth the tuning curve
BIN = 3;
FilterSize=10; 
FilterSize=FilterSize/2;
ind = -FilterSize/BIN : FilterSize/BIN; % 
[X, Y] = meshgrid(ind, ind);
sigma=10.5; %in cm;
sigma=sigma/BIN;
% Create Gaussian Mask
h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));
% Normalize so that total area (sum of all weights) is 1
h = h / sum(h(:));

%tuneMap = filter2(h,tuneMap);
figure();
imagesc(speedBins,thetaBins, tuneMap)
colorbar;
colormap jet;
xlabel('Speed');
ylabel('Phase');