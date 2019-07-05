function [Xsa,Xta] = PGE1(Xs,Ys,Xt)
[ns,m] = size(Xs); [nt,m] = size(Xt);

%% ��������ģ��
Xs = Xs';
Ys = Ys';
Xt = Xt';
sum_m = 0;
for i = 1:ns
    for j = 1:nt
        dij(i,j) = (norm(Xt(:,j)-Xs(:,i),2))^2; % Ŀ�������Դ���ľ��룬2��ʽ
        if i ~= j
            sum_m = sum_m + exp(-dij(i,j));
        end
    end
end 

%% ��������(ns��nt��)
for i = 1:ns
    for j = 1:nt
%         pij(i,j) = exp(-dij(i,j))/sum_m(j);
        pij(i,j) = exp(-dij(i,j))/sum_m;
    end
end
imagesc(pij);
%% ��Dwr(��)��Dwc(��) -- �ԽǾ���
Dwr_temp = sum(pij,2); % ��Wwijÿһ�еĺ�
Dwr = diag(Dwr_temp);
Dwc_temp = sum(pij); % ��Wwijÿһ�еĺ�
Dwc = diag(Dwc_temp);
%% �������B,E
B = (Xs*Dwr*Xs') + (Xt*Dwc*Xt');
E = 2*Xs*pij*Xt';

%% ��������ֵ�ֽ�
[V,D] = eigs(E,B,6);
A = V;
% �� ͶӰ����A ӳ���� Դ�����ݺ�Ŀ��������
Xsa = A'*Xs;
Xta = A'*Xt;
end

