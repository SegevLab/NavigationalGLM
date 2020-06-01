function params = fillInitParams(initParams, modelFlags, fPhaseLocking, config)
params = [];
if modelFlags(1) == 1
    params = [params; initParams.pos];
end

if modelFlags(2) == 1
    params = [params; initParams.hd];
end

if modelFlags(3) == 1
    params = [params; initParams.speed];
end

if modelFlags(4) == 1
    params = [params; initParams.theta];
end
if fPhaseLocking
    initPhaseLock = 1e-3*randn(config.numOfPhaseLockingFilters,1);
   params = [params; initPhaseLock];
end
params(isnan(params)) = 0;
params = params / max(params);
end