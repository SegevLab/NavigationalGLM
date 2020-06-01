function [tuning_curve] = compute_1d_tuning_curve_withInputVec(variable,fr,numBin, var_vec)
% Set tuning curve
tuning_curve = nan(numBin,1);

% compute mean fr for each bin
for n = 1:numBin
    tuning_curve(n) = mean(fr(variable >= var_vec(n) & variable < var_vec(n+1)));
    
    if n == numBin
        tuning_curve(n) = mean(fr(variable >= var_vec(n) & variable <= var_vec(n+1)));
    end
    
end

return