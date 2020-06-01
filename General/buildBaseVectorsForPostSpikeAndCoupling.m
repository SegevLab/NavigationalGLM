% Make basis for spike history and coupling 
% (based on pillowLab work)
% -------
% Inputs: 
%            numOfVectors = numberOfVectorsTooBuild
%            hpeaks = 2-vector containg [1st_peak  last_peak], the peak 
%                     location of first and last raised cosine basis vectors
%            b = offset for nonlinear stretching of x axis:  y = log(x+b) 
%                     (larger b -> more nearly linear stretching)
%
%     dt = grid of time points for representing basis
%  --------
%  Outputs:  iht = time lattice on which basis is defined
%            ihbas = orthogonalized basis
%            ihbasis = original (non-orthogonal) basis 
%
function [iht, ihbas, ihbasis] = buildBaseVectorsForPostSpikeAndCoupling(numOfVectors,dt,hpeaks, b, absoulteRefactory)

% Check input values
if (hpeaks(1)+b) < 0, 
    error('b + first peak location: must be greater than 0'); 
end

% In case we have refractory period that is longer then the time constant,
% step in
if absoulteRefactory >= dt
    % Num of vectors is subtract by one for refactory basis
    numOfVectors = numOfVectors - 1;
    
    % In case that the first peak is more then one time step from the
    % refractory period length, we consider each time step between the
    % refractory period to the first peak as a bump
    if hpeaks(1) > absoulteRefactory + dt
        numOFOneValueVectors = ceil((hpeaks(1) - absoulteRefactory -dt)/ dt);
        numOfVectors = numOfVectors - numOFOneValueVectors;
    end
        
end
% nonlinearity for stretching x axis (and its inverse)
nlin = @(x)log(x+1e-20);

% inverse nonlinearity
invnl = @(x)exp(x)-1e-20;

% Generate basis of raised cosines

% nonlinearly transformed first & last bumps
yrnge = nlin(hpeaks+b);        

% spacing between cosine bump peaks
db = diff(yrnge)/(numOfVectors-1);    

% centers (peak locations) for basis vectors
ctrs = yrnge(1):db:yrnge(2);   

% maximum time bin
mxt = invnl(yrnge(2)+2*db)-b;  
iht = (dt:dt:mxt)';

% number of points in iht
nt = length(iht);        

% raised cosine basis vector
ff = @(x,c,dc)(cos(max(-pi,min(pi,(x-c)*pi/dc/2)))+1)/2; 


ihbasis = ff(repmat(nlin(iht+b), 1, numOfVectors), repmat(ctrs, nt, 1), db);

% In case we have refractory period that is longer then the time constant,
% step in
if absoulteRefactory >= dt
    
    % Create absolut refractory basis and zeroize refactory period bins in
    % the other base vectors
    absrefIndexes = find(iht <= absoulteRefactory);
    ih0 = zeros(size(ihbasis, 1), 1);
    ih0(absrefIndexes,1) = 1;
    ihbasis(absrefIndexes,:) = 0;
    
    ihOneValued = [];
    
    % In case that the first peak is more then one time step from the
    % refractory period length, we consider each time step between the
    % refractory period to the first peak as a bump and adds a base vector
    % for it
    if hpeaks(1) > absoulteRefactory + dt
        OneValuedIndexes = find(iht > absoulteRefactory & iht < hpeaks(1));
        ihOneValued = zeros(size(ihbasis, 1), numOFOneValueVectors);
        for i = 1:length(OneValuedIndexes)
            ihOneValued(OneValuedIndexes(i),i) = 1;
        end
        
        ihbasis(OneValuedIndexes,:) = 0;
    end
    
    % concatenate the base vectors of refactory, one hot bumps and long cosine
    % bumps
    ihbasis = [ih0,ihOneValued, ihbasis];
end

% compute orthogonalized basis
ihbas = orth(ihbasis);
