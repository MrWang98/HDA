% Main function of 2-D SAR Image reconstruction
% -------------------------------------------------------------------------
% Developed by:
% Muhammet Emin Yanik
% Prof. Murat Torlak

% -------------------------------------------------------------------------
%  Copyright 2018, The University of Texas at Dallas
% -------------------------------------------------------------------------
%%
close all;
%%
% Load rawData3D
% dataName = 'rawData3D_simple2D'; % Change only this line
% rawData = load(dataName);
% rawData = rawData.(dataName);
% dy = 2;             % Sampling distance at y (vertical) axis in mm
% z0 = 280e-3;        % Range of target (range of corresponding image slice)
% dx = 200/406;       % Sampling distance at x (horizontal) axis in mm

dataName = 'crack_on_road3';
rawData = load(dataName);
rawData = rawData.('sampleSet');
rawData = reshape(rawData,[512,1,1024]);
z0 = 150e-3;        % Range of target (range of corresponding image slice)
dx = 110/512;       % Sampling distance at x (horizontal) axis in mm
dy = 0.1;
% rawData = rawData(:,50,:);
for i = 1:1:8
    rawData = cat(2,rawData,rawData);
end

% figure;
% plot(abs(squeeze(rawData(17,:,:))))


% Define parameters, update based on the scenario
nFFTtime = 1024;    % Number of FFT points for Range-FFT

%dx = 150/512;


nFFTspace = 1024;   % Number of FFT points for Spatial-FFT

% Fixed parameters for all scenarios
c = physconst('lightspeed');
fS = 9121e3;        % Sampling rate (sps)
Ts = 1/fS;          % Sampling period
K = 63.343e12;      % Slope const (Hz/sec)

% Take Range-FFT of rawData3D
rawDataFFT = fft(rawData,nFFTtime);

% Range focusing to z0
tI = 4.5225e-10; % Instrument delay for range calibration (corresponds to a 6.78cm range offset)
k = round(K*Ts*(2*z0/c+tI)*nFFTtime); % corresponing range bin
sarData = squeeze(rawDataFFT(k+1,:,:));

% Create Matched Filter 
matchedFilter = createMatchedFilterSimplified(nFFTspace,dx,nFFTspace,dy,z0*1e3);

% Create SAR Image
imSize = 200; % Size of image area in mm
sarImage = reconstructSARimageMatchedFilterSimplified(sarData,matchedFilter,dx,dy,imSize);