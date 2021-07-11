dataName1 = 'D:\lab\radar_script\raw_data\40cm\';
matName1 = 'D:\lab\radar_script\mat_data\raw_data\';

dataName3 = '.bin';

% load('vibdata.mat')
samples = 512; %采样点
SampFreq = 100;
t = 1/SampFreq : 1/SampFreq : 4;
Sig = sin(2*pi*(17*t + 6*sin(1.5*t)))+sin(2*pi*(40*t + 1*sin(1.5*t)));
n=length(Sig);
time=(1:n)/SampFreq;
fre=(SampFreq/2)/(n/2):(SampFreq/2)/(n/2):(SampFreq/2);
range_win = hamming(samples); 
range_win = range_win';
types = ["dry","wet"];

for type=types
    all = zeros(256,128);
%     allData = rand(128,256,5120,"double");
    for number=1:10
        dataName2 = append(type,num2str(number),'_Raw_0');
        dataName = append(dataName1,dataName2,dataName3);
%         matName = append(matName1,'MSST\',type,num2str(number));
%         data = load(matName).data;
%         data(isinf(data)) = -10;
%         allData(:,:,(number-11)*512+1:(number-10)*512) = permute(data,[3,2,1]);
        
        retVal = readDCA1000(dataName); %读取雷达数据，retVal的维度是[rxnums,numChirps*numADCSamples]
        allData = [];
        for chirpNumber=1
            data = retVal(1,(chirpNumber-1)*samples+1:chirpNumber*samples); %取第一行中的第1至256列的数据(一个chirp)
            din_win = data .* range_win;
            datafft = fft(din_win);
            data = abs(datafft);
            data = data';
            [Ts1_6]=wmsst(data,50,6);

            data = abs(Ts1_6);
            image = data(:,1:128);
            all = all+image;
%             allData = [allData;image];
%             image = reshape(allData((chirpNumber-1)*256+1:chirpNumber*256,:),[1,256,128]);
%             all(1,:,:) = repmat(image,1,256,128);
%             data = [data;image];
            figure
            imagesc(time,fre,image);axis xy;
            xlabel('Time / s');
            ylabel('Fre / Hz');
            axis xy;
        end
%         save(append(matName1,'MSST_2\',type,num2str(number)),'data');
    end
%     save(append(matName1,'data\',type,'_train'),'allData');
%     
%     allData = rand(128,256,2560,"double");
%     for number=5:10
% %         allData = rand(128,256,2560,"double");
%         dataName2 = append(type,num2str(number),'_Raw_0');
%         dataName = append(dataName1,dataName2,dataName3);
%         matName = append(matName1,'MSST\',type,num2str(number));
%         data = load(matName).data;
%         data(isinf(data)) = -10;
%         allData(:,:,(number-5)*512+1:(number-4)*512) = permute(data,[3,2,1]);
%     end
%     save(append(matName1,'data\',type,'_test'),'allData');
    figure
    imagesc(time,fre,image);axis xy;
end

%%
close all;