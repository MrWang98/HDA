% clear all;close all;clc;
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
xx = 1;        %第xx帧 未动
%%
% retVal = readDCA1000("D:\lab\radar_script\raw_data\long\wet1_long_Raw_0.bin");
load("normalization");
types = ["dry","wet"];
for t = 1:2
    type = types(t);
    for number=6:10
        data_path = strcat("D:\lab\radar_script\raw_data\210324\20cm_withBreath2\",type,num2str(number),"_Raw_0.bin");
%         data_path = strcat("D:\lab\radar_script\raw_data\210324\20cm_onlyBreath\",num2str(number),"_Raw_0.bin");
%         data_path = strcat("D:\lab\radar_script\raw_data\210325\20cm_withMetal\",num2str(number),"_Raw_0.bin");
%         data_path = strcat("D:\lab\radar_script\raw_data\210324\20cm_woodWithBreath\",num2str(number),"_Raw_0.bin");
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

        % index = 1:1:n_samples; 
        % freq_bin = (index - 1) * fs / n_samples;
        % range_bin = freq_bin * c / 2 / K;
        % t_metrix = zeros(512,128);
        % [t_X,t_Y,t_Z] = ind2sub(size(angle_profile),find(angle_profile>=0.5e+05));
        % temp = abs(angle_profile);
        % t_a=(0:N-1)*fs*c/N/2/K;
        % t_b=(-M/2:M/2-1);
        % t_c=-90:90;
        % scatter3(t_a(t_X(:)),t_b(t_Y(:)),t_Z(:),1);
        % set(gca,'XLim',[0 3]);% X轴的数据显示范围
        % set(gca,'YLim',[0,128]);% X轴的数据显示范围
        % set(gca,'ZLim',[-90,90]);% X轴的数据显示范围
        % set(gca,'XTick',[0:50:N-1] );% X轴的记号点
        % set(gca,'XTicklabel',num2str(t_a));% X轴的记号
        %
%         mesh(X,Y,(abs(speed_profile_Temp))); 
        mesh(X,Y,(normalization.*abs(speed_profile_Temp)));
%         view(2)
        view(90,0);
%         axis ([0 3 -10 10 0 14e5])
        
        xlabel('距离(m)');ylabel('速度(m/s)');zlabel('信号幅值');
        title('2维FFT处理三维视图');
        xlim([0 (N-1)*fs*c/N/2/K]); ylim([(-M/2)*lambda/Tc/M/2 (M/2-1)*lambda/Tc/M/2]);zlim([0 14e5]);
        % 计算峰值位置
        angle_profile=abs(angle_profile);
        pink=max(angle_profile(:));
        [row,col,pag]=ind2sub(size(angle_profile),find(angle_profile==pink));
%         filter = zeros();
        % 计算目标距离、速度、角度
        fb = ((row-1)*fs)/N;         %差拍频率
        fd = ((col-M/2-1)*fs)/(N*M); %多普勒频率
        fw = (pag-Q/2-1)/Q;          %空间频率
        R = c*(fb-fd)/2/K;          %距离公式
        v = lambda*fd/2;            %速度公式
        theta = asin(fw*lambda/d);  %角度公式
        angle = theta*180/pi;
    end
end
% fprintf('目标距离： %f m\n',R);
% fprintf('目标速度： %f m/s\n',v);
% fprintf('目标角度： %f°\n',angle);
%%
close all;