function [tuning_curve] = compute_2d_tuning_curve(variable_x,variable_y,fr,numBin,minVal,maxVal)
% this assumes that the 2d environment is a square box, and that the
% variable is recorded along the x- and y-axes

% define the axes and initialize variables
xAxis = linspace(minVal(1),maxVal(1),numBin+1);
yAxis = linspace(minVal(2),maxVal(2),numBin+1);

% initialize tuning curve
tuning_curve = zeros(numBin,numBin);

% find the mean firing rate in each position bin
for i  = 1:numBin
    
    % Get current bin limits
    start_x = xAxis(i);
    stop_x = xAxis(i+1);
    
    % find the times the animal was in the bin
    if i == numBin
        x_ind = find(variable_x >= start_x);
        x_ind = find(variable_x >= start_x & variable_x <= stop_x);
    else
        x_ind = find(variable_x >= start_x & variable_x < stop_x);
    end
    
    % Run on the y axis
    for j = 1:numBin

        % Get current bin limits
        start_y = yAxis(j);
        stop_y = yAxis(j+1);
        
        % find the times the animal was in the bin
        if j == numBin
            %y_ind = find(variable_y >= start_y & variable_y <= stop_y);
            y_ind = find(variable_y >= start_y );
        else
            y_ind = find(variable_y >= start_y & variable_y < stop_y);

        end
        
        % get intersection indexes of the time for current x and y bins
        ind = intersect(x_ind,y_ind);
        
        % fill in rate map
        tuning_curve(numBin + 1 - j, i) = mean(fr(ind));

    end
end

% Remove nans
tuning_curve(isnan(tuning_curve)) = 0;

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

tuning_curve = filter2(h,tuning_curve);



return