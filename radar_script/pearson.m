function coeff = pearson(X , Y)
% 本函数实现了皮尔逊相关系数的计算操作
%
% 输入：
%   X：输入的数值序列
%   Y：输入的数值序列
%
% 输出：
%   coeff：两个输入数值序列 X，Y 的相关系数
%

if length(X) ~= length(Y)
    error('两个数值数列的维数不相等');
    return;
end
s = size(X);
N_p = ones(s(2:3));
N_p(:,:)=10;

s_1 = squeeze(sum(X .* Y));
s_2 =  squeeze((sum(X) .* sum(Y)));
s_3 = squeeze(sum(X .^2));
s_4 = squeeze(sum(X));
s_5 = squeeze(sum(Y .^2));
s_6 = squeeze(sum(Y));
fenzi = s_1 - s_2 ./ N_p;
fenmu = sqrt((s_3 - s_4.^2 ./ N_p) .* (s_5 - s_6 ./ N_p));
coeff = fenzi ./ fenmu;

end