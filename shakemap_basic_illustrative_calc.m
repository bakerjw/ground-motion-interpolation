% Simple calculations for exploring conditioning ground motions with
% uncertainty. This basic script will consider just two parameters along a
% 1D line segment, for simplity of bookkeeping. Inter-IM and distance
% correlations are also Markovian, for simplicity.
%
% This script was used to produce results for the following manuscript:
% 
% Worden et al. (2017), "Spatial and Spectral Interpolation of Ground
% Motion Intensity Measure Observations" (in review).
%
% Jack Baker
% 4/10/2017

clear; close all; clc;

%% INITIAL SETUP OF PARAMETERS
% specify coordinates (roughly in units of km, for the correlation function
% to be realistic
x = 0:0.1:20; 
nLocations = length(x);

% parameter labels
paramLabel{1} = 'X_{1,m}';
paramLabel{2} = 'X_{2,m}';

% means and variances of the parameters (assume constant, and assume we're
% dealing with just the log-residuals of the parameters)
mu = [0; 0];
sigma = [1 1];
rhoIM = 0.6; % correlation between IMs at a given location
nIM = length(mu);

% observations (row number is the IM index and column number is the location index)
obs = nan * ones(nIM, nLocations); % initialize a matrix of nans for all locations and parameters. Non-nan values will indicate observations.

%% parameters to specify

% values for first example
obs(1,40) = 1; 
obs(1,140) = -1; 
figureName = '1st_example'; % filename for figure

% values for second example
% obs(1,40) = -1; 
% obs(2,100) = 1; 
% figureName = '2nd_example'; % filename for figure


%% CALCULATIONS

%% Set up initial probability distributions
% matrix of distances between all sites
[XX, YY] = meshgrid(x, x);
dist = abs(XX-YY);

% correlations for a given IM
rhoDist = exp(-dist./10); % an approximate distance correlation function--assume it is constant for all IMs of interest

% build mean matrix
MU = [mu(1)*ones(nLocations,1); mu(2)*ones(nLocations,1)];

% build covariance matrix
SIGMA = [sigma(1)^2*rhoDist                 rhoIM*sigma(1)*sigma(2)*rhoDist;
         rhoIM*sigma(2)*sigma(1)*rhoDist    sigma(2)^2*rhoDist];

% Find indices of IMs and locations with conditioning values
obsCol = reshape(obs',[],1); % reshape obs into a column vector with indexing that matches MU and SIGMA
idxObs = find(~isnan(obsCol)); % indices of locations with obervations
idxNoObs = find(isnan(obsCol)); % indices of locations with no obervations

%% get mean and coveriance matrices, partitioned according to observations
MU_1 = MU(idxObs);
MU_2 = MU(idxNoObs);
SIGMA_11 = SIGMA(idxObs,idxObs);
SIGMA_12 = SIGMA(idxObs,idxNoObs);
SIGMA_22 = SIGMA(idxNoObs,idxNoObs);

% conditional mean and covariance matrices 
MU_cond = MU_2 + SIGMA_12'*inv(SIGMA_11)* (obsCol(idxObs) - MU_1);
SIGMA_cond = SIGMA_22 - SIGMA_12'*inv(SIGMA_11)*SIGMA_12;

% add observed values back in
MU_final = zeros(size(MU)); % initialize
MU_final(idxObs) = obsCol(idxObs); % observed values are the means at those points
MU_final(idxNoObs) = MU_cond;
SIGMA_final = zeros(size(SIGMA)); % initialize (observed values just remain at zero)
SIGMA_final(idxNoObs,idxNoObs) = SIGMA_cond;

%% plot the results
sigmaIM = sqrt(diag(SIGMA_final)); % extract the standard deviations for each IM

figure
for i = 1:nIM
    subplot(nIM,1,i)
    idx = ((i-1)*nLocations+1):i*nLocations; % indices of values for this IM
    plot(x,MU(idx), ':k')                    % original mean values
    hold on
    plot(x,MU_final(idx), '-k')              % conditional mean values
    plot(x,MU_final(idx)+sigmaIM(idx), '--k') % conditional mean + sigma
    plot(x,MU_final(idx)-sigmaIM(idx), '--k') % conditional mean - sigma
    plot(x, obs(i,:), 'ok')                  % observed values for this IM
    xlabel('Location (km)')
    ylabel(paramLabel{i})
    set(gca, 'ylim', [-2 2])
end
FormatFigure % set font sizes, figure size
print('-dpdf', [ figureName '.pdf']); % save the figure to pdf format
    
