networkName = '11025-19050503';
neurons = 1:8;
numOfNeurons = length(neurons);
numOfTypes = 3;
numOfFeatures = 2;
type = {};
type{1} = 'NoHistory';
type{2} = 'History';
type{3} = 'Coupled';
classes = categorical({'No History','History','Coupled'});

features = {};
features{1} = 'single';
features{2} = 'best';

path = ['../Graphs/' networkName '/Neuron_'];
correlation = nan(numOfNeurons,numOfFeatures,numOfTypes);
for i = 1:numOfNeurons
    for j = 1:numOfFeatures
        for k = 1:numOfTypes
            load([path num2str(i) '_' type{k} '_Results_' features{j}]);
            correlation(i,j,k) = modelMetrics.correlation;
        end
    end
end

figure();
for i = 1:numOfNeurons
   subplot(numOfNeurons / 2,2,i);
   bar(squeeze(correlation(i,2,:)));
   ylim([0 0.7]);
   set(gca,'XTickLabel',type);

end

corrTypes = [];
stdTypes = [];
for i = 1:numOfTypes
    corrTypes  = [corrTypes nanmean(correlation(:,2,i))];
    stdTypes  = [stdTypes nanstd(correlation(:,2,i))];
end


figure
hold on
bar(1:3,corrTypes)
   set(gca,'XTickLabel',type);

errorbar(1:3,corrTypes,stdTypes,'.')
