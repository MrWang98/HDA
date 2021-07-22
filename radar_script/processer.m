function processer(name)
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
    % load("breath");

    % figure;
    % train_data = zeros(50*20,256,128);
    % test_data = zeros(14*20,256,128);


    % data_path = "D:\lab\radar_script\raw_data\210324\20cm_withBreath2\";
    % data_path = "D:\lab\radar_script\raw_data\210324\20cm_onlyBreath\";
    % data_path = "D:\lab\radar_script\raw_data\210325\20cm_withMetal\";
    % data_path = "D:\lab\radar_script\raw_data\210324\20cm_woodWithBreath\";
    % data_path = "D:\lab\radar_script\raw_data\210402\20cm_withCloth_1_4\";
    % data_path = "D:\lab\radar_script\raw_data\210402\20cm_1_4\";
    % data_path = "D:\lab\radar_script\raw_data\210403\20cm_1_2\";
    % data_path = "D:\lab\radar_script\raw_data\210402\20cm_withQuilt\";
    % data_path = "D:\lab\radar_script\raw_data\210609\adult\";
    % data_path = "D:\lab\radar_script\raw_data\210611\phone_nobreath\";
    % data_path = "D:\lab\radar_script\raw_data\210611\phone_breath\";
    % data_path = "D:\lab\radar_script\raw_data\210611\adult_bg\";
    % data_path = "D:\lab\radar_script\raw_data\210621\adult_150cm\";
    data_path = strcat('../raw_data/data/',name,'/');
    data_list = strsplit(data_path,'/');
    kinds = ["35cm","50cm","65cm","80cm","down","left","right","15d","30d","45d","60d","15h","30h"];
    % kinds = ["50cm_100ml","50cm_200ml"];
    types = ["dry","wet"];
    for kind=kinds
        data_list{end}=char(kind);
        data_path2=data_list(1);
        for str=data_list(2:end)
            data_path2 = strcat(data_path2,'/',str);
        end
        data_path2 = strcat(data_path2,'/')
        % load(strcat(data_path,'normalization'));
        % bg = load('raw_data\210611\adult_bg\bg');
        % bg = bg.speed_profile_Temp;
%        data_path2(1,1)
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
        %     all_data = zeros(1,256,128);
            count=0;
        %     train_data=zeros(1,256,128);
        %     test_data=zeros(1,256,128);
            for idx=list

        %         subplot(2,5,number+(t-1)*5);
                flag =strfind(files(idx).name,type);
                flag2 = strfind(files(idx).name,'LogFile');
                if(~isempty(flag) && isempty(flag2))
                    all_data = zeros(1,256,128);
        %             count=0;
        %             count=count+1;
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

        %                 range_win = hamming(samples);
        %                 range_win = range_win';
        %                 din_win = data .* range_win;
        %                 freq_bin = (index - 1) * Fs / samples;
        %                 range_bin = freq_bin * c / 2 / slope;

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
        %                 data = squeeze(breath(1,:,:))-abs(speed_profile_Temp).*normalization;
                        data = abs(speed_profile_Temp).*normalization;
        %                 data(isinf(data)) = -10;
                        pink=max(data(:));
                        [row,col,pag]=ind2sub(size(data),find(data==pink));
                        temp = abs(data(row,:));
                        temp = temp(1:256);
        %                 temp = data(row,:);
                        temp = abs(ifft(temp));
        %                 figure
        %                 plot(abs(temp));
                        [Ts1_6,f]=wmsst(temp',512,10000);
    %                     time=(1:256);
    %                     figure;
    %                     hp = pcolor(time,f,abs(Ts1_6));
    %                     colormap(jet);
    %                     colorbar;
    %                     hp.EdgeColor = 'none';
    %                     title('Wavelet Multisynchrosqueezed Transform');
    %                     xlabel('Time'); ylabel('Hz');
        %
                        image = abs(Ts1_6);
        %                 arg2 = image(:,1:128);
        %                 all_data(xx,:,:) = arg2;
                        img_path = strcat("mat_data/",parent_folder,type,"/",num2str(idx),"_",num2str(xx),".png");
                        imwrite(image,img_path{1});
                        x=1;

        %                 figure
        %                 imagesc(time,fre,image);
        %                 xlabel('Time / s');
        %                 ylabel('Fre / Hz');
        %                 axis xy;
        %                 all_data(xx,:,:) = arg2;
        %                 mesh(X,Y,data);
        %                 mesh(X,Y,abs(data));
        %                 view(2)
        %                 view(90,0);
        %                 plot(temp);
        %                 title('1维FFT处理视图');
        %                 xlabel('距离(m)');ylabel('速度(m/s)');
        %                 zlabel('信号幅值');
        %                 title('2维FFT处理三维视图');
        %                 xlim([0 (N-1)*fs*c/N/2/K]); ylim([(-M/2)*lambda/Tc/M/2 (M/2-1)*lambda/Tc/M/2]);
        %                 zlim([0 14e5]);
        %                 figure
        %                 plot(range_bin,abs(temp));
        %                 xlim([0 3]);
        %                 xlabel('距离(m)');
        %                 figure;
        %                 mesh(X,Y,data);
        %                 view(90,0);
        %                 xlabel('距离(m)');ylabel('速度(m/s)');zlabel('信号幅值');
        %                 title('2维FFT处理三维视图');
        %                 xlim([0 3]); ylim([(-M/2)*lambda/Tc/M/2 (M/2-1)*lambda/Tc/M/2]);zlim([0 2e6]);
                    end
        %             mat_path = strcat("D:\lab\radar_script\mat_data\",parent_folder);
        %             temp = strsplit(files(idx).name,'.');
        %             mat_filename = temp{1};
        %             save_path = strcat(mat_path,'\',mat_filename ,'.mat');
        %             save(save_path,'all_data');

                    %保存为mat
        %             train_data((count*50)+1:(count+1)*50,256,128) = all_data(1:50,256,128);
        %             test_data((count*14)+1:(count+1)*14,256,128) = all_data(51:64,256,128);
        %             count=count+1;

                end
        %         count = count+frame_number; tmp = (t-1)*10+number-1;
        %         all_data = permute(all_data,[3,2,1]);
        %         save(strcat("D:\lab\radar_script\raw_data\210519\",type,num2str(number),".mat"),'all_data');
            end
        %     train_data=permute(train_data,[3,2,1]);
        %     test_data=permute(test_data,[3,2,1]);
        %     save(strcat("D:\lab\radar_script\mat_data\",parent_folder,type,"_train.mat"),'train_data');
        %     save(strcat("D:\lab\radar_script\mat_data\",parent_folder,type,"_test.mat"),'test_data');

        %     mat_path = strcat("D:\lab\radar_script\mat_data\",parent_folder);
        %     save_path = strcat(mat_path,'\',type,'.mat');
        %     save(save_path,'all_data');
        end
    end
end