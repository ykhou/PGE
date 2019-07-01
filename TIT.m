function [Acc,Cls,Z,A,weight] = TIT(Xs,Xt,Ys,Yt,T_data,T_label,options,Goptions)

if ~isfield(options,'k')
    options.k = 100;
end
if ~isfield(options,'lambda')
    options.lambda = 1.0;
end
if ~isfield(options,'T')
    options.T = 10;
end
if ~isfield(options,'ker')
    options.ker = 'linear';
end
if ~isfield(options,'gamma')
    options.gamma = 1.0;
end
if ~isfield(options,'beta')
    options.beta = 1.0;
end
if ~isfield(options,'data')
    options.data = 'default';
end
k = options.k;
lambda = options.lambda;
T = options.T;
ker = options.ker;
gamma = options.gamma;
data = options.data;
beta=options.beta;

% Set predefined variables
[ds,ns] = size(Xs);
[dt,nt] = size(Xt);
[~,nst]=size(T_data);

 
%% 构建矩阵X=[Xs 0;Xt 0]
if(ds==dt)
    X = [Xs,Xt];
    X = X*diag(sparse(1./sqrt(sum(X.^2))));
else
    X = [Xs,zeros(ds,nt);zeros(dt,ns),Xt];
    X = X*diag(sparse(1./sqrt(sum(X.^2))));
end
n = ns+nt;

%% 构建线性核函数
% Construct kernel matrix
K = kernel(ker,X,[],gamma);

%% 构建表达式（15）中限制条件中的正定矩阵H
% Construct centering matrix
H = eye(n)-1/(n)*ones(n,n);

%% 构建表达式（15），即MMD中的M矩阵维数为（ns+nt）*（ns+nt）
% Construct MMD matrix   
e = [1/ns*ones(ns,1);-1/nt*ones(nt,1)];
M = e*e';
M = M/norm(M,'fro');

%% 构建图：目标域中和K近邻点之间的权重关系
%Construct Graph
if strcmp(Goptions.model,'sig')
    %Goptions.gnd=[Ys;Yt0];
    %Yt0=[T_Label;Cls];Cls0为伪标签，Yt0共30+127个。
    %构建W矩阵，W矩阵是将Xs，Xt放在一起，作为一个新的整体X。然后根据源域标签，目标域伪标签。
    %基于函数cos来表示W表示：新数据集X中每一个xi和它们的k近邻个元素之间的关系。
    W= constructW(X',Goptions);
    W1 = -W;
    %矩阵D为W矩阵每行求后的列矩阵
    D = diag(full(sum(W,2)));
    %% 构建表达式（9）的L矩阵：L=D-W
    for i=1:size(W1,1)
        W1(i,i) = W1(i,i) + D(i,i);
    end
else
    [Ww,Wb]=ConG(Goptions.gnd_train,Goptions,X','srge');
    W1=Ww-options.gamma*Wb;
end

%% 初始化矩阵G=I
G = speye(n);
%S = speye([m n]) 构成一个主对角线上为 1 的 m×n 稀疏矩阵
%S = speye(n) 简写 speye(n,n)

%% 构建表达式（14）中的单位矩阵I，大小为:（nt+ns）*（nt+ns）
%该单位矩阵用4小块矩阵来看待，右上角（ns*nt），左下角（nt*ns）已经为0矩阵。
R=options.delta*eye(n);
%根据表达式（14），原表达式只含有Xt项，而X包括了Xs，故展开中含有Xs项的系数必须为0，即单位矩阵右上角的值设为0矩阵。
R(1:ns,1:ns)=0;

%初始化参数
Acc = [];
weight=zeros(ns+nst,1);
for t = 1:T
    %% 求解表达式（17），左边为：K*(M+beta*W1-R)*K'+lambda*G，右边为：K*H*K'
    [A,~] = eigs(K*(M+beta*W1-R)*K'+lambda*G,K*H*K',k,'SM');
    %d = eigs(A,k,sigma) 基于 sigma 的值返回 k 个特征值。例如，eigs(A,k,'smallestabs') 返回 k 个模最小的特征值。
    %d = eigs(A,B,___) 解算广义特征值问题 A*V = B*V*D。
    %[V,D] = eigs(___) 返回对角矩阵 D 和矩阵 V，前者包含主对角线上的特征值，后者的各列中包含对应的特征向量。    
    %'smallestabs'即最小模，与 sigma = 0 相同。在matlab2017之前表示为：'sm'
    
   %% 更新表达式（18）中的Gii矩阵的求解
    %ds，dt分别表示源域目标域数据的维数
    if(ds==dt)
        G(1:ns,1:ns) = diag(sparse(1./(sqrt(sum(A(1:ns,:).^2,2)+eps))));
        %S = sparse(A) 通过挤出任何零元素将满矩阵转换为稀疏格式，节省空间用吧。
        %eps是浮点相对误差限,是指计算机用于区分两个数的差的最小常数
    else
        %对矩阵A每一行进行求和，之后对每一行进行开平方根，再求每一行的倒数。
        G = diag(sparse(1./(sqrt(sum(A.^2,2)+eps))));  
    end
    Z = A'*K;
   
    %model = svmtrain(Ys,Z(:,1:ns)','-t 0 -q');
    loss=trace(A'*K*(M+beta*W1-R)*K'*A)+sum(sqrt(sum(A(1:ns,:).^2,2)));

%   [bestacc,bestc,bestg] = SVMcgForClass_TL([Ys;T_label],Z(:,1:ns+nst)');
    cmd=['-t 0 -q','-wi' Goptions.weight]; 
    model = svmtrain([Ys;T_label],Z(:,1:ns+nst)',cmd);
    [Cls, svm_acc,~]  = svmpredict(Yt,Z(:,ns+nst+1:n)', model, '-q');

%     model = svmtrain(Goptions.weight,[Ys;T_label],Z(:,1:ns+nst)','-t 0 -q');
%     [Cls, svm_acc,~] = svmpredict(Yt,Z(:,ns+nst+1:n)', model, '-q');
    fprintf('SVM: acc = %f. , loss= %f\n', svm_acc(1),loss);
    
    %Goptions.NeighborMode = 'Supervised';
    Goptions.gnd = [Ys;T_label;Cls];
  
    %% 更新拉普拉斯（Laplacian）矩阵L=D-W
    if strcmp(Goptions.model,'sig')
        %由于目标域伪标签已经更新，那么X=[Xs;Xt]的k近邻关系也发生变化，这里需要更新矩阵W 
        W= constructW(X',Goptions);
        %由于W矩阵发生变化，那么W1(L)=D-W也要发生变化
        D = diag(full(sum(W,2)));
        W1 = -W;
        for i=1:size(W1,1)
            W1(i,i) = W1(i,i) + D(i,i);
        end
    else
        [Ww,Wb]=ConG(Goptions.gnd_train,Goptions,X','srge');
        W1=Ww-options.gamma*Wb;
    end
    
    for c=1:length(unique(Cls))
        idt= Cls==c;
        %ids= Ys==c;
        Zs=Z(:,1:ns)';
        %因为Xt = [T;Ttest];所以从ns+nst+1开始到n.
        Zt=Z(:,ns+nst+1:n)';
        %Ssamps=Zs(ids,:);
        % 把目标域中全为类别c的点挑出来，即Tsamps
        Tsamps=Zt(idt,:);
       %% 计算目标域中c类的点分别到源域Zs的距离，根据knnsearch，选出Zs中的10近邻点。
        [idx, ~] = knnsearch(Zs,Tsamps,'dist','cosine','k',10);
        % knnsearch参数：‘dist’表示计算距离的公式，这里为cosine.参数"k"表示选择的近邻点个数：这里为10个.
        % idx表示的是源域中近邻点的序号
        
        idx=idx(:);
        for i=1:length(idx)
           % 这个权重是源域的权重，源域共200+30个点。这些点，一开始权重都是0，只要成为目标域某点的近邻，权重就加1.
           weight(idx(i,:),:)=weight(idx(i,:),:)+1;
        end
    end
     
end


end
