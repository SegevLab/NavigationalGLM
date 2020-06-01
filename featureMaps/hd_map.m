function [hd_grid,dirVec] = hd_map(headDirection,nbins)

hd_grid = zeros(length(headDirection),nbins);

% Set bins
dirVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;
for i = 1:numel(headDirection)
    
    % figure out the hd index
    [~, idx] = min(abs(headDirection(i)-dirVec));
    hd_grid(i,idx) = 1;
  
end

% transform to sparse vector
hd_grid = sparse(hd_grid);
return