function image = drawMSST(data)
% data = allData(512,:)';
n=length(data);
SampFreq=2000;
time=(1:n)/SampFreq;
fre=(SampFreq/2)/(n/2):(SampFreq/2)/(n/2):(SampFreq/2);
% [Ts tfr]=MSST_Y_new(detrend(data),50,30);
[Ts tfr]=wmsst(detrend(data),50,30);
% [Cs] = brevridge_mult(abs(Ts), (1:2)/7.8, 3, 1, 5);
% n=length(data);
% ds=2;
% for k=1:3
% for j=1:n
% Tssig(k,j)=sum(real(Ts(max(1,Cs(k,j)-ds):min(round(n/2),Cs(k,j)+ds),j)));
% end
% end

image = log(abs(Ts));
% figure;
% subtitle('Fig. 13');
% imagesc(time,fre,log(abs(Ts)));
% ylabel('Freq / Hz');
% xlabel('Time / Sec');
% axis xy