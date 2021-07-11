close all;clear;clc;
retVal = readDCA1000_1('adc_data.bin'); %读取雷达数据，retVal的维度是[rxnums,numChirps*numADCSamples]
data = retVal(1,1:256); %取第一行中的第1至256列的数据(一个chirp)
samples = 256; %采样点
Fs = 10e6; %采样率
slope = 29982e9; %chirp斜率
c = 3e8; %光速
index = 1:1:samples; 

figure;
plot(index,abs(data));
title('before fft');
xlabel('samples');
%生成窗
range_win = hamming(256); 
figure;
plot(index,abs(range_win));
title('hammingwin');
xlabel('samples');
%加窗操作
range_win = range_win';
din_win = data .* range_win;
%fft操作
datafft = fft(din_win);
figure;
plot(index,abs(datafft));
title('after fft');
xlabel('samples');
%samples转换为freq
freq_bin = (index - 1) * Fs / samples;
figure;
plot(freq_bin,abs(datafft));
title('after fft');
xlabel('frequency(Hz)');
%freq转换为range
range_bin = freq_bin * c / 2 / slope;
figure;
plot(range_bin,abs(datafft));
title('after fft');
xlabel('range(m)');