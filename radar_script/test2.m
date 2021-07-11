%% 雷达参数（使用mmWave Studio默认参数）
c=3.0e8;  
B=4e9;       %调频带宽
K=29982e6;       %调频斜率
T=B/K;         %采样时间
Tc=60e-6;     %chirp总周期
fs=1e4;       %采样率
f0=77e9;       %初始频率
lambda=c/f0;   %雷达信号波长
d=lambda/2;    %天线阵列间距
n_samples=512; %采样点数/脉冲
N=512;         %距离向FFT点数
n_chirps=64;  %每帧脉冲数
M=64;         %多普勒向FFT点数 未动
n_RX=4;        %RX天线通道数
Q = 180;       %角度FFT
xx = 200;        %第xx帧 未动

n_samples = 512; %采样点
SampFreq = 100;
t = 1/SampFreq : 1/SampFreq : 4;
Sig = sin(2*pi*(17*t + 6*sin(1.5*t)))+sin(2*pi*(40*t + 1*sin(1.5*t)));
n=length(Sig);
time=(1:n)/SampFreq;
fre=(SampFreq/2)/(n/2):(SampFreq/2)/(n/2):(SampFreq/2);
%%
types = ["dry","wet"];
t = 1;
type = types(t);
number = 2;
% data_path = strcat("D:\lab\radar_script\raw_data\210324\20cm_withBreath2\",type,num2str(number),"_Raw_0.bin");
% data_path = strcat("D:\lab\radar_script\raw_data\210324\20cm_onlyBreath\",num2str(number),"_Raw_0.bin");
% data_path = strcat("D:\lab\radar_script\raw_data\210325\20cm_withMetal\",num2str(number),"_Raw_0.bin");
% data_path = strcat("D:\lab\radar_script\raw_data\210324\20cm_woodWithBreath\",num2str(number),"_Raw_0.bin");
data_path = strcat("D:\lab\radar_script\raw_data\210330\20cm\",type,"_Raw_0.bin");
retVal = readDCA1000(data_path);
cdata = zeros(n_RX,n_chirps*n_samples);
cdata(1,:) = retVal(1,(xx-1)*n_samples*n_chirps+1:xx*n_samples*n_chirps);
cdata(2,:) = retVal(2,(xx-1)*n_samples*n_chirps+1:xx*n_samples*n_chirps);
cdata(3,:) = retVal(3,(xx-1)*n_samples*n_chirps+1:xx*n_samples*n_chirps);
cdata(4,:) = retVal(4,(xx-1)*n_samples*n_chirps+1:xx*n_samples*n_chirps);
data_radar_1 = reshape(cdata(1,:),n_samples,n_chirps);   %RX1
data_radar_2 = reshape(cdata(2,:),n_samples,n_chirps);   %RX2
data_radar_3 = reshape(cdata(3,:),n_samples,n_chirps);   %RX3
data_radar_4 = reshape(cdata(4,:),n_samples,n_chirps);   %RX4
data_radar=[];            
data_radar(:,:,1)=data_radar_1;     %三维雷达回波数据
data_radar(:,:,2)=data_radar_2;
data_radar(:,:,3)=data_radar_3;
data_radar(:,:,4)=data_radar_4;
%3维FFT处理
%距离FFT
range_win = hamming(n_samples);   %加海明窗
doppler_win = hamming(n_chirps);
range_profile = [];
for k=1:n_RX
   for m=1:n_chirps
%       range_win = range_win';
%       temp = data_radar(:,m,k) .* range_win;
%       datafft = fft(din_win);
      temp=data_radar(:,m,k).*range_win;    %加窗函数
      temp_fft=fft(temp,N);    %对每个chirp做N点FFT
      range_profile(:,m,k)=temp_fft;
   end
end
x = squeeze(data_radar(:,m,k));
%多普勒FFT
speed_profile = [];
for k=1:n_RX
    for n=1:N
      temp=range_profile(n,:,k).*(doppler_win)';    
      temp_fft=fftshift(fft(temp,M));    %对rangeFFT结果进行M点FFT
      speed_profile(n,:,k)=temp_fft;  
    end
end
%角度FFT
angle_profile = [];
for n=1:N   %range
    for m=1:M   %chirp
      temp=speed_profile(n,m,:);    
      temp_fft=fftshift(fft(temp,Q));    %对2D FFT结果进行Q点FFT
      angle_profile(n,m,:)=temp_fft;  
    end
end
%绘制2维FFT处理三维视图
figure;
speed_profile_temp = reshape(speed_profile(:,:,1),N,M);   
speed_profile_Temp = speed_profile_temp';
[X,Y]=meshgrid((0:N-1)*fs*c/N/2/K,(-M/2:M/2-1)*lambda/Tc/M/2);

arg1 = abs(speed_profile_Temp);

mesh(X,Y,(abs(speed_profile_Temp))); 
% view(2)
view(90,0);
%         axis ([0 3 -10 10 0 14e5])

xlabel('距离(m)');ylabel('速度(m/s)');zlabel('信号幅值');
title('2维FFT处理三维视图');
xlim([0 (N-1)*fs*c/N/2/K]); ylim([(-M/2)*lambda/Tc/M/2 (M/2-1)*lambda/Tc/M/2]);zlim([0 14e5]);
%%
files = dir("D:\lab\radar_script\raw_data\210324\20cm_withBreath2\");
[file_number,~] = size(files);
for idx=2:file_number
    flag =strfind(files(idx).name,'wet');
    if(flag==1)
%         file_path = strcat(files(idx).folder,'\',files(idx).name)
        test = strsplit(files(idx).folder,'\');
        dirpath = [test{5} '\' test{6}];
        mkdir(dirpath);
    end
end
%%
% figure;
% train_data = zeros(50*20,256,128);
% test_data = zeros(14*20,256,128);
types = ["dry","wet"];

% data_path = "D:\lab\radar_script\raw_data\210324\20cm_withBreath2\";
% data_path = "D:\lab\radar_script\raw_data\210324\20cm_onlyBreath\";
% data_path = "D:\lab\radar_script\raw_data\210325\20cm_withMetal\";
% data_path = "D:\lab\radar_script\raw_data\210324\20cm_woodWithBreath\";
% data_path = "E:\radar\210330\20cm_withBottle\";
data_path = "D:\lab\radar_script\raw_data\210330\20cm";
path_list = strsplit(data_path,'\');
parent_folder = [path_list{5} '\' path_list{6}];
mkdir("mat_data", parent_folder);
files = dir(data_path);
[file_number,~] = size(files);
for t=1:2
    type = types(t);
%     all_data = zeros(1,256,128);
%     count=0;
    for idx=2:file_number
        
%         subplot(2,5,number+(t-1)*5);
        flag =strfind(files(idx).name,type);
        if(flag==1)
            all_data = zeros(1,256,128);
            count=0;
%             count=count+1;
            file_path = strcat(files(idx).folder,'\',files(idx).name);
            retVal = [];
            retVal = readDCA1000(file_path);
            [size1,size2] = size(retVal);
            frame_number = size2 / n_samples / n_chirps;
            for xx=1:frame_number
                cdata = zeros(n_RX,n_chirps*n_samples);
                cdata(1,:) = retVal(1,(xx-1)*n_samples*n_chirps+1:xx*n_samples*n_chirps);
                cdata(2,:) = retVal(2,(xx-1)*n_samples*n_chirps+1:xx*n_samples*n_chirps);
                cdata(3,:) = retVal(3,(xx-1)*n_samples*n_chirps+1:xx*n_samples*n_chirps);
                cdata(4,:) = retVal(4,(xx-1)*n_samples*n_chirps+1:xx*n_samples*n_chirps);
                data_radar_1 = reshape(cdata(1,:),n_samples,n_chirps);   %RX1
                data_radar_2 = reshape(cdata(2,:),n_samples,n_chirps);   %RX2
                data_radar_3 = reshape(cdata(3,:),n_samples,n_chirps);   %RX3
                data_radar_4 = reshape(cdata(4,:),n_samples,n_chirps);   %RX4
                data_radar=[];            
                data_radar(:,:,1)=data_radar_1;     %三维雷达回波数据
                data_radar(:,:,2)=data_radar_2;
                data_radar(:,:,3)=data_radar_3;
                data_radar(:,:,4)=data_radar_4;
                %3维FFT处理
                %距离FFT
                range_win = hamming(n_samples);   %加海明窗
                doppler_win = hamming(n_chirps);
                range_profile = [];
                for k=1:n_RX
                   for m=1:n_chirps
                      temp=data_radar(:,m,k).*range_win;    %加窗函数
                      temp_fft=fft(temp,N);    %对每个chirp做N点FFT
                      range_profile(:,m,k)=temp_fft;
                   end
                end
                %多普勒FFT
                speed_profile = [];
                for k=1:n_RX
                    for n=1:N
                      temp=range_profile(n,:,k).*(doppler_win)';    
                      temp_fft=fftshift(fft(temp,M));    %对rangeFFT结果进行M点FFT
                      speed_profile(n,:,k)=temp_fft;  
                    end
                end
                %角度FFT
        %             angle_profile = [];
        %             for n=1:N   %range
        %                 for m=1:M   %chirp
        %                   temp=speed_profile(n,m,:);    
        %                   temp_fft=fftshift(fft(temp,Q));    %对2D FFT结果进行Q点FFT
        %                   angle_profile(n,m,:)=temp_fft;  
        %                 end
        %             end
                %绘制2维FFT处理三维视图
        %         figure;
                speed_profile_temp = reshape(speed_profile(:,:,1),N,M);   
                speed_profile_Temp = speed_profile_temp';
                [X,Y]=meshgrid((0:N-1)*fs*c/N/2/K,(-M/2:M/2-1)*lambda/Tc/M/2);
                data = squeeze(breath(1,:,:))-abs(speed_profile_Temp).*normalization;
                pink=max(data(:));
                [row,col,pag]=ind2sub(size(data),find(data==pink));
                temp = abs(data(row,:));
                [Ts1_6]=wmsst(temp',50,6);

                image = abs(Ts1_6);
                arg2 = image(:,1:128);
                all_data(count+xx,:,:) = arg2;
%                 figure
%                 imagesc(time,fre,arg2);axis xy;
%                 xlabel('Time / s');
%                 ylabel('Fre / Hz');
%                 axis xy;
%                 all_data(xx,:,:) = arg2;
%                 mesh(X,Y,(abs(speed_profile_Temp))); 
%                 view(2)
%                 view(90,0);
%                 xlabel('距离(m)');ylabel('速度(m/s)');zlabel('信号幅值');
%                 title('2维FFT处理三维视图');
%                 xlim([0 (N-1)*fs*c/N/2/K]); ylim([(-M/2)*lambda/Tc/M/2 (M/2-1)*lambda/Tc/M/2]);zlim([0 14e5]);
                
%                 figure;
%                 mesh(X,Y,data);
%                 view(90,0);
%                 xlabel('距离(m)');ylabel('速度(m/s)');zlabel('信号幅值');
%                 title('2维FFT处理三维视图');
%                 xlim([0 3]); ylim([(-M/2)*lambda/Tc/M/2 (M/2-1)*lambda/Tc/M/2]);zlim([0 2e6]);
            end
            mat_path = strcat("D:\lab\radar_script\mat_data\",parent_folder);
            temp = strsplit(files(idx).name,'.');
            mat_filename = temp{1};
            save_path = strcat(mat_path,'\',mat_filename ,'.mat');
            save(save_path,'all_data');

        end
%         count = count+frame_number;
%         tmp = (t-1)*10+number-1;
%         train_data(tmp*50+1:(tmp+1)*50,256,128) = all_data(1:50,256,128);
%         test_data(tmp*14+1:(tmp+1)*14,256,128) = all_data(51:64,256,128);
%         all_data = permute(all_data,[3,2,1]);
%         save(strcat("D:\lab\radar_script\raw_data\210328\",type,num2str(number),".mat"),'all_data');

    end
%     mat_path = strcat("D:\lab\radar_script\mat_data\",parent_folder);
%     save_path = strcat(mat_path,'\',type,'.mat');
%     save(save_path,'all_data');
end
%%
dry_train = zeros(500,256,128);
wet_train = zeros(500,256,128);
dry_test = zeros(140,256,128);
wet_test = zeros(140,256,128);

dry_train(:,:,:) = train_data(1:500,:,:);
wet_train(:,:,:) = train_data(501:1000,:,:);
dry_test(:,:,:) = test_data(1:140,:,:);
wet_test(:,:,:) = test_data(141:280,:,:);
%%
reverse = permute(wet_train,[3,2,1]);
%%
figure;
plot(abs(corr'));
%%
normalization=mapminmax(squeeze(breath(1,:,:)));
%%
filter = zeros(64,512);
for i=1:64
   filter(i,:)=coeff; 
end
%%
figure;
mesh(X,Y,squeeze(dry(6,:,:)));
% view(90,0);
view(2);
xlabel('距离(m)');ylabel('速度(m/s)');zlabel('信号幅值');
title('2维FFT处理三维视图');
xlim([0 50]); ylim([(-M/2)*lambda/Tc/M/2 (M/2-1)*lambda/Tc/M/2]);zlim([0 4e6]);
%%
figure;
mesh(X,Y,squeeze(dry(6,:,:)).*normalization);
% view(90,0);
view(2);
xlim([0 (N-1)*fs*c/N/2/K]); ylim([(-M/2)*lambda/Tc/M/2 (M/2-1)*lambda/Tc/M/2]);zlim([0 4e6]);
%%
image = squeeze(breath(1,:,:))-squeeze(wet(6,:,:)).*normalization;
figure;
mesh(X,Y,image);

% view(90,0);
% view(2);
xlim([0 (N-1)*fs*c/N/2/K]); ylim([(-M/2)*lambda/Tc/M/2 (M/2-1)*lambda/Tc/M/2]);zlim([0 4e6]);
pink=max(image(:));
[row,col,pag]=ind2sub(size(image),find(image==pink));
%%
figure;
plot(X,image(row,:));
%%
ti = zeros(64,512);
ti(row,:) = pink;
figure;
mesh(X,Y,ti);
view(2);
%%
load('raw_data/210326/breath');
load('raw_data/210326/dry');
load('raw_data/210326/wet');
%%
coeff = pearson(breath,dry);
%%
close all;