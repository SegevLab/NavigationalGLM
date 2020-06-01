%% Description
% This will plot the results of all the preceding analyses: the model
% performance, the model-derived tuning curves, and the firing rate tuning
% curves.
function plotPerformanceAndParameters(config, modelParams, modelMetrics, expFiringRate, ...
    simFiringRate, neuronNumber, titleEnd, numOfCoupledNeurons, ISI,expISI,  sessionName,...,
    modelFiringRate, validationData, coupledNeurons, log_ll)

% Set current sub plot index to zeros
currSubPlotIndex = 0;

% caclulate number of rows in plot base on the num of learned tuning params
numOfRows = ceil(modelParams.numOfFilters / 2);

% Set bins of tuning curves
hd_vector =  linspace(0, 2 * pi, config.numOfHeadDirectionParams);
speedBins = config.speedVec;
posXAxes = linspace(0, config.boxSize(1), config.numOfPositionAxisParams);
posYAxes = linspace(config.boxSize(2),0, config.numOfPositionAxisParams);
thetaBins = linspace(0, 2 * pi, config.numOfTheta);

% Calculate for each tuning curve the difference from mean firing rate by
% using the mean of all the others tuning curves
scale_factor = exp(modelParams.biasParam);
scale_factor_pos = mean(exp(modelParams.hd_param))*mean(exp(modelParams.speed_param))*mean(exp(modelParams.theta_param));
scale_factor_hd = mean(exp(modelParams.pos_param))*mean(exp(modelParams.speed_param))*mean(exp(modelParams.theta_param));
scale_factor_spd = mean(exp(modelParams.pos_param))*mean(exp(modelParams.hd_param))*mean(exp(modelParams.theta_param));
scale_factor_theta =  mean(exp(modelParams.pos_param))*mean(exp(modelParams.hd_param))*mean(exp(modelParams.speed_param));

if config.fPhaseLocking
    scale_factor_phaseLock = mean(exp(modelParams.pos_param))*mean(exp(modelParams.hd_param))*mean(exp(modelParams.speed_param)) * mean(exp(modelParams.theta_param));
    scale_factor_pos = scale_factor_pos * mean(exp(modelParams.phaseLockParams));
    scale_factor_hd = scale_factor_hd * mean(exp(modelParams.phaseLockParams));
    scale_factor_spd = scale_factor_spd * mean(exp(modelParams.phaseLockParams));
    scale_factor_theta = scale_factor_theta * mean(exp(modelParams.phaseLockParams));
end

figure();


% If the model includes position tuning, step in
if numel(modelParams.pos_param) == config.numOfPositionParams
    
    currSubPlotIndex = currSubPlotIndex + 1;
    
    % update mean response for each bin
    pos_response = scale_factor*scale_factor_pos*exp(modelParams.pos_param);
    
    % Plot position tuning
    subplot(numOfRows,2,currSubPlotIndex)
    imagesc(posXAxes, fliplr(posYAxes),reshape(pos_response,config.numOfPositionAxisParams,config.numOfPositionAxisParams));
    colorbar;
    axis square
    colormap jet;
    title('Learned Position');
    xlabel('X (cm)')
    ylabel('Y (cm)')
end

% If the model includes head direction tuning, step in
if  numel(modelParams.hd_param) == config.numOfHeadDirectionParams
    currSubPlotIndex = currSubPlotIndex + 1;
    
    % update mean response for each bin
    hd_response = scale_factor*scale_factor_hd* exp(modelParams.hd_param);
    
    % Plot head direction tuning
    subplot(numOfRows,2,currSubPlotIndex)
    polarplot([hd_vector hd_vector(1)],[hd_response hd_response(1)],'k','linewidth',2);
    title('Learned Head Direction');
end

% If the model includes head direction tuning, step in
if numel(modelParams.speed_param) == config.numOfSpeedBins
    currSubPlotIndex = currSubPlotIndex + 1;
    
    % update mean response for each bin
    speed_response = scale_factor*scale_factor_spd*exp(modelParams.speed_param);
    
    % Plot speed tuning
    subplot(numOfRows,2,currSubPlotIndex)
     plot(speedBins, speed_response,'k','linewidth',2);
    axis square
    title('Learned speed');
    xlabel('speed (cm/s)')
    ylabel('Hz')
    box off
end

% If the model includes theta phase tuning, step in
if numel(modelParams.theta_param) > 1
    currSubPlotIndex = currSubPlotIndex + 1;
    
    % Get the subset of theta filter
    thetaTuning = modelParams.theta_param(1:config.numOfTheta);
    
    % update mean response for each bin
    theta_response = scale_factor*scale_factor_theta*exp(thetaTuning);
    
    % Plot theta phase tuning
    subplot(numOfRows,2,currSubPlotIndex)
    polarplot([thetaBins thetaBins(1)],[theta_response theta_response(1)],'k','linewidth',2)
    title('Learned Theta Phase');
end

% If the model includes theta phase tuning, step in
if config.fPhaseLocking && numel(modelParams.phaseLockParams) == config.numOfPhaseLockingFilters
    currSubPlotIndex = currSubPlotIndex + 1;
    
    % Get the subset of theta filter
    phaseLockTuning = modelParams.phaseLockParams;
    
    % update mean response for each bin
    phaseLock_response = scale_factor*scale_factor_phaseLock*exp(phaseLockTuning);
    
    % Plot theta phase tuning
    subplot(numOfRows,2,currSubPlotIndex)
    polarplot([thetaBins thetaBins(1)],[phaseLock_response phaseLock_response(1)],'k','linewidth',2)
    title('Phase locking filter');
end


% Save figure
if config.fCoupling
    if numOfCoupledNeurons > 0
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_ParametersLearned_' titleEnd]);
    else
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_ParametersLearned_' titleEnd]);
    end
else
    savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_NoHistory_ParametersLearned_' titleEnd]);
end
close(gcf)

% In case we learned post spike filter or coupling, plot their parameters
if config.fCoupling
    if config.fPhaseLocking
        figure();    
        % Get post spike filter length and time ticks
        historyLen = length(modelParams.firstSpikeFilter);
        timeSeriesHistory = linspace(1 * config.dt, historyLen * config.dt, historyLen);
        dashline = ones(historyLen,1);

        % Plot post spike filter
        plot(timeSeriesHistory, exp(modelParams.spikeHistory + modelParams.firstSpikeFilter),'-r',...
            timeSeriesHistory, exp(modelParams.spikeHistory ),'-b',...
            timeSeriesHistory, dashline, '--k','linewidth',2);
        ylim([0 5]);
        legend('First spike in session', 'All spikes');
       
        title('Post Spike Filter');
        xlabel('Time (s)')
        ylabel('Gain');
            % Save figure
        if numOfCoupledNeurons > 0
            savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_post-spike_' titleEnd]);
        else
            savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_post-spike_' titleEnd]);
        end
        close(gcf)

    end
    figure();
    
    % Get post spike filter length and time ticks
    historyLen = length(modelParams.spikeHistory);
    timeSeriesHistory = linspace(1 * config.dt, historyLen * config.dt, historyLen);
    dashline = ones(historyLen,1);
    
    % Plot post spike filter
    subplot(2 ,1,1)
    plot(timeSeriesHistory, exp(modelParams.spikeHistory),'-r',...
        timeSeriesHistory, dashline, '--k','linewidth',2);
    ylim([0 5]);
    title('Post Spike Filter');
    xlabel('Time (s)')
    ylabel('Gain');
    
    % In case we have coupled neurons, plot them
    if numOfCoupledNeurons > 0
        
        % Get the length of the coupling filters
        couplingLen = length(modelParams.couplingFilters(:,1));
        
        % Set the ticks of the filter for causal/acausal interaction
        if config.acausalInteraction
            timeSeriesCoupling = linspace(-config.timeBeforeSpike * config.dt, (couplingLen - config.timeBeforeSpike) * config.dt, couplingLen);
        else
            timeSeriesCoupling = linspace(1 * config.dt, couplingLen * config.dt, couplingLen);
        end
        dashline = ones(couplingLen,1);
        
        % Plot coupling filters
        subplot(2 ,1,2)
        legendLabels = strtrim(cellstr(num2str(coupledNeurons'))');
        plot(timeSeriesCoupling, exp(modelParams.couplingFilters), timeSeriesCoupling, dashline, '--k', 'linewidth',2)
        xlabel('Time (s)')
        ylabel('Gain');
        ylim([0 5]);
        title('Coupling filters');
        legend(legendLabels, 'Location', 'bestoutside');
    end

    % Save figure
    if numOfCoupledNeurons > 0
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_interactionLearned_' titleEnd]);
    else
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_interactionLearned_' titleEnd]);
    end
    close(gcf)

end

figure();

% Set time ticks of the test set
timeBins = linspace(config.psthdt, length(expFiringRate) * config.psthdt,length(expFiringRate));

% Plot the firing rate
plot(timeBins, expFiringRate / config.psthdt,'-k', timeBins, simFiringRate / config.psthdt,'-r');
xlabel('Time (s)')
ylabel('Hz');
title('Firing rate');
legend(['MEC Data'], ['Model - ' ' R: ' num2str(modelMetrics.correlation,2)]);

% Copy firing rate
modelParams.expFiringRate  = expFiringRate;
modelParams.simFiringRate = simFiringRate;
modelParams.timeBins = timeBins;

% Save figure
if config.fCoupling == 1
    if numOfCoupledNeurons > 0
        save(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_Results_' titleEnd], 'modelParams', 'modelMetrics', 'log_ll');
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_ModelResponse_' titleEnd]);
    else
        save(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_Results_' titleEnd], 'modelParams', 'modelMetrics', 'log_ll');
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_ModelResponse_' titleEnd]);
    end
else
    save(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_NoHistory_Results_' titleEnd], 'modelParams', 'modelMetrics', 'log_ll');
    savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_NoHistory_ModelResponse_' titleEnd]);
end

%close(gcf)

% Plot Inter spike interval
figure();
isiTicks = config.dt:config.dt:length(expISI)* config.dt;
plot(isiTicks, expISI,'-k', ISI.simISITimes, ISI.simISIPr,'-r', 'linewidth',2);
xlabel('Time (s)')
xlim([0 0.05]);
title('Inter Spike Interval');
ylabel('Probability (spike)');
legend('MEC Data','Model');
mkdir(['./Graphs/' sessionName '/']);

% Save figure
if config.fCoupling == 1
    if numOfCoupledNeurons > 0
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_ISI_' titleEnd]);
    else
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_history_ISI_' titleEnd]);
    end
else
    savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_NoHistory_ISI_' titleEnd]);
end
drawnow;

close(gcf)

end