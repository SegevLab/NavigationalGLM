clear all;
baseFolder = '../Graphs/';
slash = '/';
networkDirs = dir(baseFolder);

numOfRegEx = 6;
regex{1}  ='Neuron_*_NoHistory_Results_single.mat';
regex{2} = 'Neuron_*_NoHistory_Results_best.mat';
regex{3} = 'Neuron_*_History_Results_single.mat';
regex{4} = 'Neuron_*_History_Results_best.mat';
regex{5} = 'Neuron_*_Coupled_Results_single.mat';
regex{6} = 'Neuron_*_Coupled_Results_best.mat';
correlation = nan(6,700);
varExplain = nan(6,700);
mse = nan(6,700);

cellsIndex = 0;
for i = 1:length(networkDirs)
    if networkDirs(i).isdir
        currentNetwork = networkDirs(i).name;
        currentyPath = strcat(baseFolder,slash, currentNetwork);
        for j = 1:6
            currentFiles = dir(strcat(currentyPath,slash, regex{j}));
            numOfNeurons = length(currentFiles);
            for k = 1:numOfNeurons
                filePath = strcat(currentyPath, slash, currentFiles(k).name);
                load(filePath);
                correlation(j, cellsIndex + k) = modelMetrics.correlation;
                varExplain(j, cellsIndex + k) = modelMetrics.varExplain;
                mse(j, cellsIndex + k) = modelMetrics.mse;

            end
        end
        cellsIndex = cellsIndex + numOfNeurons;
    end
end
%correlation(:,4) = [];

cellsIndex
correlation
corrMat = correlation;
varMat = varExplain;
singleCorrMat = corrMat([1 3 5],:);
singleVarMat = varMat([1 3 5],:);
singleVarMat(singleVarMat < 0) = nan;
BestCorrMat = corrMat([2 4 6],:);
BestVarMat = varMat([2 4 6],:);
BestVarMat(BestVarMat < 0) = nan;
[~, numOfNeurons] = size(corrMat);

meansingleCorrMat = nanmean(singleCorrMat,2);
stdCorrSingle = nanstd(singleCorrMat') / sqrt(numOfNeurons);

meanBestCorrMat = nanmean(BestCorrMat,2);
stdCorrBest = nanstd(BestCorrMat') / sqrt(numOfNeurons);

meansingleVarMat = nanmean(singleVarMat,2);
stdVarSingle = nanstd(singleVarMat') / sqrt(numOfNeurons);

meanBestVarMat = nanmean(BestVarMat,2);
stdVarBest = nanstd(BestVarMat') / sqrt(numOfNeurons);


figure();
subplot(2,1,1);
errorbar(meansingleCorrMat, stdCorrSingle,'ok','linewidth',2);
hold on;
plot(0.5:3.5,nanmean(meansingleCorrMat) * ones(4,1),'--b','linewidth',2)
hold off;
box off
set(gca,'fontsize',10)
set(gca,'XLim',[0 4]); set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'NoHistory Single','History Single','Coupled single',});
ylabel('Correlation coefficient');
title('Single filter - Pearson correlation');

subplot(2,1,2);
errorbar(meanBestCorrMat, stdCorrBest,'ok','linewidth',2);
hold on;
plot(0.5:3.5,nanmean(meanBestCorrMat) * ones(4,1),'--b','linewidth',2)
hold off;
box off
set(gca,'fontsize',10)
set(gca,'XLim',[0 4]); set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'NoHistory Best','History Best','Coupled Best'});
ylabel('Correlation coefficient');
title('Best filters -  Pearson correlation');



figure();
subplot(2,1,1);
errorbar(meansingleVarMat, stdVarSingle,'ok','linewidth',2);
hold on;
plot(0.5:3.5,nanmean(meansingleVarMat) * ones(4,1),'--b','linewidth',2)
hold off;
box off
set(gca,'fontsize',10)
set(gca,'XLim',[0 4]); set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'NoHistory Single','History Single','Coupled single',});
ylabel('Fraction of explained variance');
title('Single filter - Fraction of explained variance');

subplot(2,1,2);
errorbar(meanBestVarMat, stdVarBest,'ok','linewidth',2);
hold on;
plot(0.5:3.5,nanmean(meanBestVarMat) * ones(4,1),'--b','linewidth',2)
hold off;
box off
set(gca,'fontsize',10)
set(gca,'XLim',[0 4]); set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'NoHistory Best','History Best','Coupled Best'});
ylabel('Fraction of explained variance');
title('Best filters - Fraction of explained variance');

figure();

meanSingle = nanmean(nanmean(singleCorrMat));
stdSingle = std(singleCorrMat);

meanBest = nanmean(nanmean(BestCorrMat));
stdBest = std(BestCorrMat') / sqrt(numOfNeurons);
bar([meanSingle, meanBest]);

% 
% subplot(3,1,2);
% errorbar(meanMSE, stdMSE,'ok','linewidth',3);hold on;
% hold on;
% plot(0.5:6.5,mean(meanMSE) * ones(7,1),'--b','linewidth',2)
% hold off;
% box off
% set(gca,'fontsize',14)
% set(gca,'XLim',[0 7]); set(gca,'XTick',1:6)
% set(gca,'XTickLabel',{'NoHistory Single','NoHistory Best','History Single','History Best','Coupled single','Coupled Best'});
% ylabel('Mean squred error');
% title(' Mean squred error');
% 
% subplot(3,1,3);
% errorbar(meanVarExp, stdVarExp,'ok','linewidth',3);f
% hold on;
% plot(0.5:6.5,mean(meanVarExp) * ones(7,1),'--b','linewidth',2)
% hold off;
% box off
% set(gca,'fontsize',14)
% set(gca,'XLim',[0 7]); set(gca,'XTick',1:6)
% set(gca,'XTickLabel',{'NoHistory Single','NoHistory Best','History Single','History Best','Coupled single','Coupled Best'});
% ylabel('Explained variance');
% title('Fraction of explained variance');
