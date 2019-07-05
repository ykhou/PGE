function [Xsa,Xta] = PGE1(Xs,Ys,Xt)
[ns,m] = size(Xs); [nt,m] = size(Xt);

%% 建立条件模型
Xs = Xs';
Ys = Ys';
Xt = Xt';
sum_m = 0;
for i = 1:ns
    for j = 1:nt
        dij(i,j) = (norm(Xt(:,j)-Xs(:,i),2))^2; % 目标域点与源域点的距离，2范式
        if i ~= j
            sum_m = sum_m + exp(-dij(i,j));
        end
    end
end 

%% 条件概率(ns行nt列)
for i = 1:ns
    for j = 1:nt
%         pij(i,j) = exp(-dij(i,j))/sum_m(j);
        pij(i,j) = exp(-dij(i,j))/sum_m;
    end
end
imagesc(pij);
%% 求Dwr(行)，Dwc(列) -- 对角矩阵
Dwr_temp = sum(pij,2); % 求Wwij每一行的和
Dwr = diag(Dwr_temp);
Dwc_temp = sum(pij); % 求Wwij每一列的和
Dwc = diag(Dwc_temp);
%% 构造矩阵B,E
B = (Xs*Dwr*Xs') + (Xt*Dwc*Xt');
E = 2*Xs*pij*Xt';

%% 广义特征值分解
[V,D] = eigs(E,B,6);
A = V;
% 经 投影向量A 映射后的 源域数据和目标域数据
Xsa = A'*Xs;
Xta = A'*Xt;
end

