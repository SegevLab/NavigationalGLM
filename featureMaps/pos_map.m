function [posgrid, xBins, yBins] = pos_map(pos, nbins, boxSize)

% Set bins
xBins = linspace(0, boxSize(1), nbins);
yBins = linspace(0, boxSize(2), nbins);

% store grid
posgrid = zeros(length(pos), nbins * nbins);

% Run for each position sample
for idx = 1:size(pos,1)
    
    % figure out the position index
    [~, xcoor] = min(abs(pos(idx,1)-xBins));
    [~, ycoor] = min(abs(pos(idx,2)-yBins));
    
    % transform 2 cordinates system into one;
    bin_idx = sub2ind([nbins nbins],nbins  - ycoor + 1, xcoor);
    
    % Set position bin
    posgrid(idx, bin_idx) = 1;
    
end

% transform to sparse vector
posgrid = sparse(posgrid);
end