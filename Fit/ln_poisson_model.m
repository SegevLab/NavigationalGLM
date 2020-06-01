function [logLikelihood, gradient, hessian] = ln_poisson_model(param, data, modelType, config, numOfCouplingParams)

% fetch stimulus, history and coupling info and spike train
stimulusFeatures = data{1};
designMatrix = data{2};
spikeTrain = data{3};


%Define regularization coefficents for each of the stimulus params
posReg = 5e-1;
hdReg = 5e-3;
speedReg = 1e-2;
thetaReg =5e-2;
phaseLockReg =1e-3;

% Get the initalized bias param
biasParam = param(1);

% The parameters are concatented difrently with and w\o coupling
% We fetch the spike history, coupling and stiumulus params
if config.fCoupling
    spikeHistoryParam = param(2:1 + numOfCouplingParams); 
    stimulusParams = param(2 + numOfCouplingParams:end);
   
    % Calculate the linear projection for this case(with history
    % information)
    linerProjection = stimulusFeatures * stimulusParams + designMatrix * spikeHistoryParam + biasParam;
else
    stimulusParams = param(2:end);
    
    % Calculate the linear projection for this case(without history
    % information)
    linerProjection = stimulusFeatures * stimulusParams + biasParam;
end

% Calculate firing rate by adding nonlinearity 
firingRate = exp(linerProjection);

% Calculate negative log likelihood
ll_Trm0 = sum(firingRate)* config.dt;
ll_Trm1 = -spikeTrain' * linerProjection;
logLL = ll_Trm0 + ll_Trm1;

% calculate gradients for Newton-Raphson method 

% calculate log likelihood derivative w.r.t the stimulus params
dlTuning0 = firingRate' * stimulusFeatures;
dlTuning1 = spikeTrain' * stimulusFeatures;
dlStimulusParams = (dlTuning0 * config.dt - dlTuning1)';

% calculate log likelihood derivative w.r.t the bias param
dlBias = sum(firingRate) * config.dt - sum(spikeTrain);

dlHistory = [];
% In case we optomize for history and/or couling we 
% calculate log likelihood derivative w.r.t the history/coupling params

if config.fCoupling
    dlHistory0 = firingRate' * designMatrix;
    dlHistory1 = spikeTrain' * designMatrix;
    dlHistory = (dlHistory0 * config.dt - dlHistory1)';
end

% Compute hessian matrix for Newton-Raphson method 

% Transform the firing rate prediction into a sparse diag
% matrix (expLength X expLength)
ratediag = spdiags(firingRate,0, length(spikeTrain), length(spikeTrain));

% Second deravative of log likelihood w.r.t stimulus
HStimulus = (stimulusFeatures' * (bsxfun(@times,stimulusFeatures,firingRate))) *  config.dt; 

% Second deravative of log likelihood w.r.t bias
HBias = sum(firingRate) *  config.dt;

% Second deravative of log likelihood w.r.t stimulus & bias
HTuningBias = (sum(ratediag,1) * stimulusFeatures)' *  config.dt;

% In case we optimized for history/coupling caclulate the needed hessians
if config.fCoupling
    
    % Second deravative of log likelihood w.r.t history/coupling 
    HHistory = (designMatrix' * (bsxfun(@times,designMatrix,firingRate))) * config.dt;
    
    % Second deravative of log likelihood w.r.t history/coupling & stimulus
    HStimulusHistory = ((designMatrix' * ratediag) * stimulusFeatures)' *  config.dt;
    
    % Second deravative of log likelihood w.r.t history/coupling & bias
    HHistoryBias = (firingRate' * designMatrix)' *  config.dt;
else
    HHistory = [];
    HStimulusHistory = [];
    HHistoryBias = [];
end

% find the position, head direction, speed and theta  parameters and compute their roughness penalties

% initialize parameter-relevant variables
J_pos = 0; J_pos_g = []; J_pos_h = []; 
J_phaseLock = 0; J_PhaseLock_g = []; J_PhaseLock_h = []; 

J_hd = 0; J_hd_g = []; J_hd_h = [];  
J_speed = 0; J_speed_g = []; J_speed_h = [];  
J_theta = 0; J_theta_g = []; J_theta_h = [];  

% find the parameters
[param_pos,param_hd,param_speed, param_theta, param_phaseLock] = find_param(stimulusParams, modelType, config.numOfPositionParams,...
    config.numOfHeadDirectionParams, config.numOfSpeedBins, config.allTheta, config.fPhaseLocking, config.numOfPhaseLockingFilters);

% compute the contribution for f, df, and the hessian
if ~isempty(param_pos)
    [J_pos,J_pos_g,J_pos_h] = rough_penalty_2d(param_pos,posReg, 0);
end

if ~isempty(param_hd)
    [J_hd,J_hd_g,J_hd_h] = rough_penalty_1d_circ(param_hd,hdReg, 0);
end

if ~isempty(param_speed)
    [J_speed,J_speed_g,J_speed_h] = rough_penalty_1d(param_speed,speedReg, 0);
end


if ~isempty(param_theta)
    [J_theta, J_theta_g, J_theta_h] = rough_penalty_1d_circ(param_theta(1:config.numOfTheta),thetaReg, 0);
end

if ~isempty(param_phaseLock)
    [J_phaseLock, J_PhaseLock_g, J_PhaseLock_h] = rough_penalty_1d_circ(param_phaseLock,phaseLockReg, 1e0);
end




% Calculate the log likelihood with regularization
logLikelihood = logLL + J_pos + J_hd + J_speed + J_theta + J_phaseLock;

% Calculate the stimulus gradients with the regularization
dlStimulusParams = dlStimulusParams + [J_pos_g; J_hd_g; J_speed_g; J_theta_g; J_PhaseLock_g];

% Concatente all gradients
gradient = [dlBias; dlHistory; dlStimulusParams];

% Caclulate stimulus hessian with regularization
HStimulus = HStimulus + blkdiag(J_pos_h,J_hd_h, J_speed_h, J_theta_h, J_PhaseLock_h);

% Concatente all hessians
hessian = [[HBias HHistoryBias' HTuningBias']; [HHistoryBias HHistory HStimulusHistory']; [HTuningBias HStimulusHistory HStimulus]];


function [J,J_g,J_h] = rough_penalty_2d(param, smoothPanelty, l1Reg)

    numParam = numel(param);
    D1 = spdiags(ones(sqrt(numParam),1)*[-1 1],0:1,sqrt(numParam)-1,sqrt(numParam));
    DD1 = D1'*D1;
    M1 = kron(eye(sqrt(numParam)),DD1); M2 = kron(DD1,eye(sqrt(numParam)));
    M = (M1 + M2);
 
    J = smoothPanelty*0.5*param'*M*param + l1Reg * sum(abs(param));
    J_g = smoothPanelty*M*param + l1Reg * sign(param);
    J_h = smoothPanelty*M;

function [J,J_g,J_h] = rough_penalty_1d_circ(param, smoothPanelty, l1Reg)
    
    numParam = numel(param);
    D1 = spdiags(ones(numParam,1)*[-1 1],0:1,numParam-1,numParam);
    DD1 = D1'*D1;
    
    % to correct the smoothing across first and last bin
    DD1(1,:) = circshift(DD1(2,:),[0 -1]);
    DD1(end,:) = circshift(DD1(end-1,:),[0 1]);
    
    J = smoothPanelty*0.5*param'*DD1*param  + l1Reg * sum(abs(param));
    J_g = smoothPanelty*DD1*param + l1Reg * sign(param);
    J_h = smoothPanelty*DD1;

function [J,J_g,J_h] = rough_penalty_1d(param, smoothPanelty, l1Reg)

    numParam = numel(param);
    D1 = spdiags(ones(numParam,1)*[-1 1],0:1,numParam-1,numParam);
    DD1 = D1'*D1;
    J = smoothPanelty*0.5*param'*DD1*param + l1Reg * sum(abs(param));
    J_g = smoothPanelty*DD1*param+ l1Reg * sign(param);
    J_h = smoothPanelty*DD1;



