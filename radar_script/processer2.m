function processer2(name,kind)
    addpath(genpath('/home/xuemeng/matlab/toolbox/shared'));
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
    data_path = strcat('../raw_data/data/',name,'/');
    data_list = strsplit(data_path,'/');
%    kinds = ["35cm","50cm","65cm","80cm","down","left","right","15d","30d","45d","60d","15h","30h"];
    types = ["dry","wet"];
    data_list{end}=char(kind);
    data_path2=data_list(1);
    for str=data_list(2:end)
        data_path2 = strcat(data_path2,'/',str);
    end
    data_path2 = strcat(data_path2,'/')
    breath_list = strsplit(data_path2{1},'/');
    type = breath_list(end-1);
    breath_list{end-1}='breath';
    breath_path = breath_list(1);
    for str=breath_list(2:end)
        breath_path = strcat(breath_path,'/',str);
    end
    files = dir(breath_path{1});
    [file_number,~] = size(files);
    list = 3:file_number;
    for idx=list
        flag =strfind(files(idx).name,type);
        flag2 = strfind(files(idx).name,'LogFile');
        if(~isempty(flag) && isempty(flag2))
            all_data = zeros(1,256,128);
            file_path = strcat(files(idx).folder,'/',files(idx).name);
            retVal = [];
            retVal = readDCA1000(file_path);
            [size1,size2] = size(retVal);
            frame_number = size2 / n_samples / n_chirps;
            frame_number = round(frame_number/2);

            for xx=frame_number
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
                speed_profile = [];
                for k=1:n_RX
                    for n=1:N
                      temp=range_profile(n,:,k).*(doppler_win)';
                      temp_fft=fftshift(fft(temp,M));    %对rangeFFT结果进行M点FFT
                      speed_profile(n,:,k)=temp_fft;
                    end
                end
                speed_profile_temp = reshape(speed_profile(:,:,1),N,M);
                speed_profile_Temp = speed_profile_temp';
                normalization = normalize(abs(speed_profile_Temp),2,'range');
                save_path = strcat(data_path2,'normalization.mat');
                save(save_path{1},'normalization');
            end
        end
    end


    path_list = strsplit(data_path2{1},'/');
    parent_folder = [path_list{end-2} '/' path_list{end-1} '/' path_list{end}];
    mkdir("mat_data/", parent_folder);
    files = dir(data_path2{1});
    [file_number,~] = size(files);
    list = 3:file_number;
    for t=1:2
        type = types(t);
        path = strcat("mat_data","/",parent_folder);
        mkdir(path{1}, type);
        count=0;
        for idx=list
            flag =strfind(files(idx).name,type);
            flag2 = strfind(files(idx).name,'LogFile');
            if(~isempty(flag) && isempty(flag2))
                all_data = zeros(1,256,128);
                file_path = strcat(files(idx).folder,'/',files(idx).name);
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
                    speed_profile = [];
                    for k=1:n_RX
                        for n=1:N
                          temp=range_profile(n,:,k).*(doppler_win)';
                          temp_fft=fftshift(fft(temp,M));    %对rangeFFT结果进行M点FFT
                          speed_profile(n,:,k)=temp_fft;
                        end
                    end
                    speed_profile_temp = reshape(speed_profile(:,:,1),N,M);
                    speed_profile_Temp = speed_profile_temp';
                    [X,Y]=meshgrid((0:N-1)*fs*c/N/2/K,(-M/2:M/2-1)*lambda/Tc/M/2);
                    data = abs(speed_profile_Temp).*normalization;
                    pink=max(data(:));
                    [row,col,pag]=ind2sub(size(data),find(data==pink));
                    temp = abs(data(row,:));
                    temp = temp(1:256);
                    temp = abs(ifft(temp));
                    [Ts1_6,f]=wmsst(temp',512,10000);
                    image = abs(Ts1_6);
                    img_path = strcat("mat_data/",parent_folder,type,"/",num2str(idx),"_",num2str(xx),".png");
                    imwrite(image,img_path{1});
                    x=1;
                end
            end
        end
    end
end