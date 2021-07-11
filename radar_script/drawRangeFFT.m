%%
close all;
%%
% s=0;
types = ["dry","wet"];
load('empty')
p1=[-10,240,3000];
p2=[-2875/4,11625,-47000];
distance_s = [20,60,80,100];
% load('raw_data\210323\empty\empty');
% figure;
all_data = zeros(10,1,512);

% idx_all=zeros(1,8);
% j=1;
figure('units','normalized','position',[0,0,1,0.9]);
for t=1:2
    type=types(t);
    for d=1:4
        distance=distance_s(d);
%         figure;
        subplot(2,4,(t-1)*4+d);
        for i=1
    %         distance = 20;
            dataName1 = ['D:\lab\radar_script\raw_data\' num2str(distance) 'cm\'];
            dataName2 = strcat(type,num2str(i),'_Raw_0');
            dataName3 = '.bin';
            dataName = strcat(dataName1,dataName2,dataName3);
            retVal = readDCA1000(dataName); %读取雷达数据，retVal的维度是[rxnums,numChirps*numADCSamples]
            samples = 512; %采样点
            Fs = 10e6; %采样率
            slope = 29982e9; %chirp斜率
            c = 3e8; %光速
            index = 1:1:samples; 
            chirpNumber = 256;
            data = retVal(1,(chirpNumber-1)*samples+1:chirpNumber*samples); 
            range_win = hamming(samples); 
            range_win = range_win';
            din_win = data .* range_win;
            datafft = fft(din_win);
%             plot(abs(datafft));
            freq_bin = (index - 1) * Fs / samples;
            range_bin = freq_bin * c / 2 / slope;

        %     s=s+sum(abs(datafft))/1e6;
%             all_data(i,:,:) = abs(datafft);
%             temp = datafft;
            temp = abs(datafft)-empty;
%             [peak ,idx] = max(temp(1,1:32));
%             poly = polyval(p1,idx);
%             poly2 = polyval(p2,idx);
%             
%             temp(1,idx) = temp(1,idx)*poly/1000+poly2;
%             temp2 = ifft(datafft(1,1:32),512);
%             plot(range_bin,abs(fft(temp2))-empyt(1:32));
%             filter = zeros(1,512);
%             filter(1,idx-1:idx+1) = ones(1,3);
%             plot(range_bin,temp.*filter);
%             temp2 = ifft(temp.*filter);
            plot(range_bin,abs(temp))
%             axis([0,50]);
            title([num2str(distance) 'cm']);
%             axis([0,3,0,5e4]);
            hold on;
        end
%         idx_all(j) = idx;
%         j=j+1;
    end
end
% s/10
%%
types = ["dry","wet"];
% load('empty');


distance_s = [20,40,60,80,100];

% figure;
% all_data = zeros(10,1,512);

idx_all=zeros(1,8);
j=1;
% figure('units','normalized','position',[0,0,1,0.9]);
figure;

dataName = 'D:\lab\radar_script\raw_data\210323\empty\empty_Raw_0.bin';
%             dataName1 = 'D:\lab\radar_script\raw_data\long\';
% dataName2 = strcat(type,num2str(i),'_Raw_0');
% dataName3 = '.bin';
% dataName = strcat(dataName1,dataName2,dataName3);
retVal = readDCA1000(dataName); %读取雷达数据，retVal的维度是[rxnums,numChirps*numADCSamples]
samples = 512; %采样点
Fs = 10e6; %采样率
slope = 29982e9; %chirp斜率
c = 3e8; %光速
index = 1:1:samples; 
chirpNumber = 256;
data = retVal(1,(chirpNumber-1)*samples+1:chirpNumber*samples); 
range_win = hamming(samples); 
range_win = range_win';
din_win = data .* range_win;
datafft = fft(din_win);
freq_bin = (index - 1) * Fs / samples;
range_bin = freq_bin * c / 2 / slope;

%             all_data(i,:,:) = abs(datafft);
temp = abs(datafft)-empty;
[peak ,idx] = max(temp(1,1:32));

% p1=[-10,240,3000];
% p2=[-2875/4,11625,-47000];
% poly = polyval(p1,idx);
% poly2 = polyval(p2,idx);
%             temp(1,idx) = temp(1,idx)*poly/1000+poly2;

% filter = zeros(1,512);
% filter(1,idx-1:idx+1) = ones(1,3);
plot(range_bin,temp);
plot(range_bin,temp);
title([num2str(distance) 'cm']);
%             r1 = range_bin(floor(idx)-3);
%             r2 = range_bin(floor(idx)+29);
%             axis([r1,r2,0,5e4]);
% axis([0,3,0,5e4]);
%%
dataName1 = 'D:\lab\radar_script\raw_data\210323\empty\';
dataName2 = strcat('dry','1','_Raw_0');
dataName3 = '.bin';
matName = strcat(dataName1,dataName2.dataName3);
load(matName);
figure;
plot(range_bin,allData(1,:,:));
