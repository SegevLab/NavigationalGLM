
addpath('../../../Tools/append_pdfs');

networks = dir('../Graphs/');
numOfNetworks = length(networks)
for i = 1:numOfNetworks
    networks(i).name
   figs = dir(strcat('../Graphs/', networks(i).name, '/*.fig'));
   numOfFigs = length(figs);
   for j = 1:numOfFigs
       figs(j).name
    openfig(['../Graphs/' networks(i).name '/' figs(j).name], 'invisible');
    fileName = ['../Results/tmp/fig_' num2str(i) '_' num2str(j) '.pdf'];

    print(fileName, '-dpdf', '-fillpage');
    append_pdfs(['../Results/network_' networks(i).name '_results.pdf'], fileName);
   end
end