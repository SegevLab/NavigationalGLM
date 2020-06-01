function [theta_grid,dirVec] = trigered_theta_map(thetaPhase,nbins, spiketrain, window)

theta_grid = zeros(length(thetaPhase),nbins);

% Set bins
dirVec = 2*pi/nbins/2:2*pi/nbins:2*pi-2*pi/nbins/2;

for i = window + 1:numel(thetaPhase)

    % figure out the theta index
    [~, idx] = min(abs(thetaPhase(i)-dirVec));
    if sum(spiketrain(i - window:i - 1)) == 0
        theta_grid(i,idx) = 1;
    end
end

% transform to sparse vector
theta_grid = sparse(theta_grid);
return