function [Xsa,Xta] = PGE(Xs,Ys,Xt)
[ns,m] = size(Xs); [nt,m] = size(Xt);

%% ��������ģ��
Xs = Xs';
Ys = Ys';
Xt = Xt';
% sum_m = double(zeros(1,nt)); % sum_m��ʽ��2���ķ�ĸ
sum_m = 0;
for i = 1:ns
    for j = 1:nt
        dij(i,j) = (norm(Xt(:,j)-Xs(:,i),2))^2; % Ŀ�������Դ���ľ��룬2��ʽ
        if i ~= j
%             sum_m(j) = sum_m(j) + exp(-dij(i,j));
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

%% �������
% ���� ���¶�����
% deerta_ic = zeros(ns,9);
% for i = 1:ns
%     c = Ys(i);
%     deerta_ic(i,c) = 1;
% end

% ptc = pij'*deerta_ic;
sum_c = 0 ;
for i = 1:nt
    for cc = 1:9
        for j = 1:ns
            c = Ys(j);
            if c == cc
                if i ~= j
                    sum_c = sum_c + pij(j,i);
                end
            end
        end
        ptc(i,cc) = sum_c;
        sum_c = 0;
    end
end


Wwij = double(zeros(ns,nt));
for i = 1:ns
    for j = 1:nt
        c = Ys(i);
        Wwij(i,j) = ptc(j,c);
    end
end
imagesc(Wwij);

%% ��Dwr(��)��Dwc(��) -- �ԽǾ���
Dwr_temp = sum(Wwij,2); % ��Wwijÿһ�еĺ�
Dwr = diag(Dwr_temp);
% Dwr_temp = sum(pij,2);
% for i = 1:ns
%     Dwr(i,i) = Dwr_temp(i);
% end
Dwc_temp = sum(Wwij); % ��Wwijÿһ�еĺ�
% Dwc_temp = sum(pij); % ��Wwijÿһ�еĺ�
Dwc = diag(Dwc_temp);
% Dwc_temp = sum(pij);
% for j = 1:nt
%     Dwc(j,j) = Dwc_temp(j);
% end
% �������B,E
B = (Xs*Dwr*Xs') + (Xt*Dwc*Xt');
E = 2*Xs*Wwij*Xt';
% E = 2*Xs*pij*Xt';

%% ��������ֵ�ֽ�
[V,D] = eigs(E,B,6);
% D_dc = sort(sum(D,1), 'descend');
% for i = 1:length(D)
%     D(i,i) = D_dc(i);
% end
A = V;
% �� ͶӰ����A ӳ���� Դ�����ݺ�Ŀ��������
Xsa = A'*Xs;
Xta = A'*Xt;
end

