function [theta_grid,dirVec] = theta_map(thetaPhase,nbins)

theta_grid = zeros(length(thetaPhase),nbins);

% Set bins
dirVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;


[~, coor] = min(abs(thetaPhase(1)-dirVec));
    
% transform 2 cordinates system into one;
theta_grid(1, coor) = 1;

prevSetInd = 1;


for i = 2:numel(thetaPhase)
    
    % figure out the theta index
    [~, idx] = min(abs(thetaPhase(i)-dirVec));
%     if theta_grid(prevSetInd,idx) == 0
%         theta_grid(i,idx) = 1;
%         prevSetInd = i;
%     end
    theta_grid(i,idx) = 1;

end

% transform to sparse vector
theta_grid = sparse(theta_grid);
return