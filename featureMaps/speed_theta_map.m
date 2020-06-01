function  speedThetaGrid  = speed_theta_map(posx,posy, sampleRate, maxSpeed, thetaPhase, nAxisBins)

% Calculate velocity by using the difference between preceeding positions
velx = diff([posx(1); posx]);
vely = diff([posy(1); posy]); 

% Caclulate speed for each bin
speed = sqrt(velx.^2+vely.^2) * sampleRate;


% Set bins
thetaBins = 2*pi/nAxisBins/2:2*pi/nAxisBins:2*pi-2*pi/nAxisBins/2;
sppedBins = linspace(0, maxSpeed, nAxisBins);
% store grid
speedThetaGrid = zeros(length(speed), nAxisBins * nAxisBins);


    % figure out the position index
[~, xcoor] = min(abs(speed(1)-sppedBins));
[~, ycoor] = min(abs(thetaPhase(1)-thetaBins));
    
% transform 2 cordinates system into one;
bin_idx = sub2ind([nAxisBins nAxisBins],nAxisBins  - ycoor + 1, xcoor);
speedThetaGrid(1, bin_idx) = 1;

prevSetInd = 1;


for idx = 2:length(speed)
    
    % figure out the position index
    [~, xcoor] = min(abs(speed(idx)-sppedBins));
    [~, ycoor] = min(abs(thetaPhase(idx)-thetaBins));
    
    % transform 2 cordinates system into one;
    bin_idx = sub2ind([nAxisBins nAxisBins],nAxisBins  - ycoor + 1, xcoor);
    
    if speedThetaGrid(prevSetInd, bin_idx) == 0
        % Set position bin
        speedThetaGrid(idx, bin_idx) = 1;
        prevSetInd = idx;
    end
    
end

% transform to sparse vector
speedThetaGrid = sparse(speedThetaGrid);

end

