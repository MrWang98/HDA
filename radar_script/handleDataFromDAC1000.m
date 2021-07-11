%%
%close all;
%test
dataName = 'D:\实验室\radar_script\采样\dry_0.bin';
retVal = readDCA1000(dataName);
tmp = retVal(1,:);
sampleSet = reshape(tmp,1024,[]);
% sampleSetT = sampleSet(5,:,:);
% sampleSetT = squeeze(sampleSetT);
% sampleSetT = tmp.';
%%
rawData = load('sampleSet');
rawData = rawData.('sampleSet');
result = sampleSet==rawData;
%%
fftPara = zeros(512,1000,1000);
for i=1:1:1000
    fftPara(512,i,:)=sampleSet;
end

