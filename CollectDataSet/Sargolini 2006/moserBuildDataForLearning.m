function moserBuildDataForLearning(neuronSpikesPath, poitionPath, sessionName, neuronNumber, neuronName, eegPath)

load(neuronSpikesPath);
load(poitionPath);
load(eegPath);
boxSize = [100 100];

dtStimulus = 0.02;
dtEEG = 1/Fs;
sampleRate = 1000;
dtSpike = 1 / sampleRate;
totlalLengthOfExp =  length(posx) * dtStimulus;
post = post + dtSpike;
post(end)
totlalLengthOfExp
posx = interp1(post, posx, post(1):dtSpike:totlalLengthOfExp);
posx2 = interp1(post, posx2, post(1):dtSpike:totlalLengthOfExp);
posy = interp1(post, posy, post(1):dtSpike:totlalLengthOfExp);
posy2 = interp1(post, posy2, post(1):dtSpike:totlalLengthOfExp);
length(EEG)
length(dtSpike:dtEEG:totlalLengthOfExp)
fPhase = 1;
if length(EEG) ~= length(dtSpike:dtEEG:totlalLengthOfExp)
    fPhase = 0;
    'No phse'
    
    scaledEEG = zeros(length(dtSpike:dtSpike:totlalLengthOfExp),1);
else
    scaledEEG = interp1(dtSpike:dtEEG:totlalLengthOfExp, EEG, dtSpike:dtSpike:totlalLengthOfExp)';
end
posx = posx' + 50;
posx2 = posx2' + 50;
posy = posy' + 50;
posy2 = posy2' + 50;

spikeTimes = floor(cellTS * 1000);
spiketrain = double(ismember(1:totlalLengthOfExp / dtSpike, spikeTimes))';

allnans = [find(isnan(posx)); find(isnan(posy)); find(isnan(posx2)); find(isnan(posy2)); find(isnan(scaledEEG))];
posx(allnans) = [];posx2(allnans) = [];posy(allnans) = []; posy2(allnans) = []; scaledEEG(allnans) = []; spiketrain(allnans) = [];

headDirection = atan2(posy2-posy,posx2-posx)+pi/2;
headDirection(headDirection < 0) = headDirection(headDirection<0)+2*pi; % go from 0 to 2*pi, without any negative numbers

if min(posx) < 0
    posx = posx -min(posx);
end

if min(posy) < 0
    posy = posy -min(posy);
end

posx = posx / max(posx) * 100;
posy = posy / max(posy) * 100;


hdNan = find(isnan(headDirection));

spiketrain(hdNan) = []; posx(hdNan) = []; posy(hdNan) = []; headDirection(hdNan) = []; scaledEEG(hdNan) = [];
if fPhase
    hilb_eeg = hilbert(scaledEEG); % compute hilbert transform
    filt_eeg = atan2(imag(hilb_eeg),real(hilb_eeg))'; %inverse tangent (-pi to pi)
    ind = filt_eeg <0; filt_eeg(ind) = filt_eeg(ind)+2*pi; % from 0 to 2*pi
    phase = filt_eeg';
else
    phase = scaledEEG;
end

phaseNan2 = find(isnan(phase));
if length(phaseNan2) > 0
    'error'
end

spiketrain(phaseNan2) = [];
posx(phaseNan2) = [];
posy(phaseNan2) = [];
headDirection(phaseNan2) = [];
phase(phaseNan2) = [];



mkdir(['../GLM/rawDataForLearning/'  sessionName]);
save(['../GLM/rawDataForLearning/'  sessionName '/data_for_cell_'  num2str(neuronNumber)], 'boxSize', 'post', 'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain', 'phase');
save(['../GLM/rawDataForLearning/'  sessionName '/'  num2str(neuronNumber) '_' neuronName], 'boxSize', 'post', 'posx', 'posy', 'sampleRate', 'headDirection', 'spiketrain', 'phase');

end