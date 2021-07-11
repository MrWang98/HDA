dataName1 = 'D:\lab\radar_script\raw_data\';
matName1 = 'D:\lab\radar_script\mat_data\raw_data\';
samples = 512; %采样点

types = ["dry","wet"];
for type = types
    allData = rand(512,256,5120,"double");
    for number=1:10

        dataName2 = append(type,num2str(number),'_Raw_0');
        dataName3 = '.bin';
        dataName = [dataName1 dataName2 dataName3];
        matName = append(matName1,dataName2);
        
        data = load(matName).allData;
        data(isinf(data)) = -10;
        allData(:,:,(number-1)*512+1:number*512) = permute(data,[3,2,1]);
    end
    save(append(matName1,'data_4\',type,'_train'),'allData');
    
    allData = rand(512,256,2560,"double");
    for number=11:15

        dataName2 = append(type,num2str(number),'_Raw_0');
        dataName3 = '.bin';
        dataName = [dataName1 dataName2 dataName3];
        matName = append(matName1,dataName2);
        
        data = load(matName).allData;
        data(isinf(data)) = -10;
        allData(:,:,(number-11)*512+1:(number-10)*512) = permute(data,[3,2,1]);
    end
    save(append(matName1,'data_4\',type,'_test'),'allData');
end
%%
load("allData.mat");
x = allData;
load(".\mat_data\raw_data\dry1_Raw_0.mat")
y = allData;
%%
matName1 = 'D:\lab\radar_script\mat_data\';
type = 'wet';
% figure;
train_data = [];
val_data = [];
test_data = [];
for number=1:20
    dataName2 = [type num2str(number) '_Raw_0'];
    matName = [matName1 dataName2];
    data = load(matName,'allData');
    data = data.allData;
    train_data = [train_data;data(1:256,:)];
    val_data = [val_data;data(257:384,:)];
    test_data = [test_data;data(385:512,:)];
end
%%
save([matName1 'data_2\' type '_train'],'allData');
% save([matName1 'data\' type '_val'],'val_data');
% save([matName1 'data_2\' type '_test'],'allData');