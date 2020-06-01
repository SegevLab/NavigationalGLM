% function to find the right parameters given the model type
function [param_pos,param_hd,param_speed, param_Theta, param_PhaseLock] = find_param(param,modelType,numPos,numHD, numSpeed, numTheta, fPhaseLocking, nPhaseLocking)

param_pos = []; param_hd = []; param_speed = []; param_Theta = []; param_PhaseLock = [];

if all(modelType == [1 0 0 0]) 
    param_pos = param(1:numPos);
elseif all(modelType == [0 1 0 0]) 
    param_hd = param(1:numHD);
elseif all(modelType == [0 0 1 0]) 
    param_speed = param(1:numSpeed);
elseif all(modelType == [0 0 0 1]) 
    param_Theta = param(1:numTheta);
    
elseif all(modelType == [1 1 0 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
elseif all(modelType == [1 0 1 0 ]) 
    param_pos = param(1:numPos);
    param_speed = param(numPos+1:numPos+numSpeed);
elseif all(modelType == [1 0 0 1]) 
    param_pos = param(1:numPos);
    param_Theta = param(numPos+1:numPos+numTheta);
elseif all(modelType == [0 1 1 0]) 
    param_hd = param(1:numHD);
    param_speed = param(numHD+1:numHD+numSpeed);
elseif all(modelType == [0 1 0 1]) 
    param_hd = param(1:numHD);
    param_Theta = param(numHD+1:numHD+numTheta);
elseif all(modelType == [0 0 1 1]) 
    param_speed = param(1:numSpeed);
    param_Theta = param(numSpeed+1:numSpeed+numTheta);
    
elseif all(modelType == [1 1 1 0])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_speed = param(numPos+numHD+1:numPos+numHD+numSpeed);
elseif all(modelType == [1 1 0 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_Theta = param(numPos+numHD+1:numPos+numHD+numTheta);
elseif all(modelType == [1 0 1 1])
    param_pos = param(1:numPos);
    param_speed = param(numPos+1:numPos+numSpeed);
    param_Theta = param(numPos+numSpeed+1:numPos+numSpeed+numTheta);
 elseif all(modelType == [0 1 1 1])
    param_hd = param(1:numHD);
    param_speed = param(numHD+1:numHD+numSpeed);
    param_Theta = param(numHD+numSpeed+1:numHD+numSpeed+numTheta);
elseif all(modelType == [1 1 1 1])
    param_pos = param(1:numPos);
    param_hd = param(numPos+1:numPos+numHD);
    param_speed = param(numPos+numHD+1:numPos+numHD+numSpeed);
    param_Theta = param(numPos+numHD+numSpeed+1:numPos+numHD+numSpeed+numTheta);
end
if fPhaseLocking
    param_PhaseLock = param(end - nPhaseLocking + 1:end);
end

end
    