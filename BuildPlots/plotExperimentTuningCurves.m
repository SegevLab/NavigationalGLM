function plotExperimentTuningCurves(config, features, pos_curve, hd_curve, speed_curve, theta_curve, neuronNumber, learningData, sessionName, mean_fr)

% Set Bins of tuning curves
hd_vector =  linspace(0, 2 * pi, config.numOfHeadDirectionParams);
speedBins = config.speedVec;
posXAxes = linspace(0, config.boxSize(1), config.numOfPositionAxisParams);
posYAxes = linspace(config.boxSize(2),0, config.numOfPositionAxisParams);

figure('units', 'normalized', 'outerposition', [0 0 1 1]);

% Get the spike indices 
spikedInd = find(learningData.spiketrain);

% Plot trajectory
subplot(3,2,1);
plot(learningData.posx, learningData.posy,'-k', learningData.posx(spikedInd), learningData.posy(spikedInd), '.r');
axis square
title(['trajectory - mean firing rate ' num2str(mean_fr) ' Hz']);
xlim([0 config.boxSize(1)]);
ylim([0 config.boxSize(2)]);

% --- plot the tuning curves ----

% Position tuning curve
subplot(3,2,2)
imagesc(posXAxes, fliplr(posYAxes), pos_curve); 
colorbar;
colormap jet;
axis square
box off;
title('Position')
xlabel('X (cms)')
ylabel('Y (cms)')

% Head direction tuning curve
subplot(3,2,3)
polarplot([hd_vector hd_vector(1)],[hd_curve; hd_curve(1)],'k','linewidth',2)
title('Head direction')

% Speed tuning curve
subplot(3,2,4)
plot(speedBins, speed_curve,'k','linewidth',2); 
axis square
box off;
title('Speed');
xlabel('Speed (cm/s)')
ylabel('Hz');

% Theta tuning curve
subplot(3,2,5)
polarplot([features.thetaVec features.thetaVec(1)],[theta_curve; theta_curve(1)],'k','linewidth',2)
title('Theta phase')


% Save and plot figure
mkdir(['./Graphs/' sessionName]);
savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) 'expeimentCurves']);
drawnow;
close(gcf)

end