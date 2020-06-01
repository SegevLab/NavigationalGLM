function PlotLogLikelihood(LLH_values, numFolds, selected_model, sessionName, neuronNumber, fCoupling, numOfCoupledNeurons)

% Calculate the mean and variance of the log likelihood increase from mean
% firing rate
LLH_increase_mean = mean(LLH_values);
LLH_increase_sem = std(LLH_values)/sqrt(numFolds);

% Plot the mean and variance for each model
figure();
errorbar(LLH_increase_mean,LLH_increase_sem,'ok','linewidth',3)
ylabel('Log likelihood');

title('Log likelihood increase from mean firing rate');
hold on
plot(selected_model,LLH_increase_mean(selected_model),'.r','markersize',25)
plot(0.5:15.5,zeros(16,1),'--b','linewidth',2)
hold off
box off
set(gca,'fontsize',20)
set(gca,'XLim',[0 16]); set(gca,'XTick',1:15)
set(gca,'XTickLabel',{'PHST','PHS','PHT','PST','HST','PH','PS','PT','HS',...
    'HT','ST','P','H','S','T'});
legend('Model performance','Selected model','Baseline', 'Location', 'bestoutside')
ylim([-1 1.5]);

if fCoupling == 1
    if numOfCoupledNeurons > 0
        save(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_logLikelihood'], 'LLH_values', 'LLH_values');
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_Coupled_logLikelihood']);
    else
        save(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_History__logLikelihood'], 'LLH_values', 'LLH_values');
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_History_logLikelihood']);
    end
else
     save(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_NoHistory_logLikelihood'], 'LLH_values', 'LLH_values');
        savefig(['./Graphs/' sessionName '/Neuron_' num2str(neuronNumber) '_NoHistory_logLikelihood']);
end
close(gcf)
end