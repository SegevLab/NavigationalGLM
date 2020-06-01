function [speed_grid, speed, speedBins] = speed_map(posx,posy, sampleRate, numOfSpeedBins,speedBins)


% Calculate velocity by using the difference between preceeding positions
velx = diff([posx(1); posx]);
vely = diff([posy(1); posy]); 

% Caclulate speed for each bin
speed = sqrt(velx.^2+vely.^2) * sampleRate;

speed_grid = zeros(numel(posx),numOfSpeedBins);

for i = 2:numel(posx)
    % figure out the position index
    [~, id] = min(abs(speed(i) - speedBins));
    
    % Set index
    speed_grid(i, id) = 1;
end

% transform to sparse vector
speed_grid = sparse(speed_grid);
return