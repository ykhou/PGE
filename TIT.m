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

 
%% ��������X=[Xs 0;Xt 0]
if(ds==dt)
    X = [Xs,Xt];
    X = X*diag(sparse(1./sqrt(sum(X.^2))));
else
    X = [Xs,zeros(ds,nt);zeros(dt,ns),Xt];
    X = X*diag(sparse(1./sqrt(sum(X.^2))));
end
n = ns+nt;

%% �������Ժ˺���
% Construct kernel matrix
K = kernel(ker,X,[],gamma);

%% �������ʽ��15�������������е���������H
% Construct centering matrix
H = eye(n)-1/(n)*ones(n,n);

%% �������ʽ��15������MMD�е�M����ά��Ϊ��ns+nt��*��ns+nt��
% Construct MMD matrix   
e = [1/ns*ones(ns,1);-1/nt*ones(nt,1)];
M = e*e';
M = M/norm(M,'fro');

%% ����ͼ��Ŀ�����к�K���ڵ�֮���Ȩ�ع�ϵ
%Construct Graph
if strcmp(Goptions.model,'sig')
    %Goptions.gnd=[Ys;Yt0];
    %Yt0=[T_Label;Cls];Cls0Ϊα��ǩ��Yt0��30+127����
    %����W����W�����ǽ�Xs��Xt����һ����Ϊһ���µ�����X��Ȼ�����Դ���ǩ��Ŀ����α��ǩ��
    %���ں���cos����ʾW��ʾ�������ݼ�X��ÿһ��xi�����ǵ�k���ڸ�Ԫ��֮��Ĺ�ϵ��
    W= constructW(X',Goptions);
    W1 = -W;
    %����DΪW����ÿ�������о���
    D = diag(full(sum(W,2)));
    %% �������ʽ��9����L����L=D-W
    for i=1:size(W1,1)
        W1(i,i) = W1(i,i) + D(i,i);
    end
else
    [Ww,Wb]=ConG(Goptions.gnd_train,Goptions,X','srge');
    W1=Ww-options.gamma*Wb;
end

%% ��ʼ������G=I
G = speye(n);
%S = speye([m n]) ����һ�����Խ�����Ϊ 1 �� m��n ϡ�����
%S = speye(n) ��д speye(n,n)

%% �������ʽ��14���еĵ�λ����I����СΪ:��nt+ns��*��nt+ns��
%�õ�λ������4С����������������Ͻǣ�ns*nt�������½ǣ�nt*ns���Ѿ�Ϊ0����
R=options.delta*eye(n);
%���ݱ��ʽ��14����ԭ���ʽֻ����Xt���X������Xs����չ���к���Xs���ϵ������Ϊ0������λ�������Ͻǵ�ֵ��Ϊ0����
R(1:ns,1:ns)=0;

%��ʼ������
Acc = [];
weight=zeros(ns+nst,1);
for t = 1:T
    %% �����ʽ��17�������Ϊ��K*(M+beta*W1-R)*K'+lambda*G���ұ�Ϊ��K*H*K'
    [A,~] = eigs(K*(M+beta*W1-R)*K'+lambda*G,K*H*K',k,'SM');
    %d = eigs(A,k,sigma) ���� sigma ��ֵ���� k ������ֵ�����磬eigs(A,k,'smallestabs') ���� k ��ģ��С������ֵ��
    %d = eigs(A,B,___) �����������ֵ���� A*V = B*V*D��
    %[V,D] = eigs(___) ���ضԽǾ��� D �;��� V��ǰ�߰������Խ����ϵ�����ֵ�����ߵĸ����а�����Ӧ������������    
    %'smallestabs'����Сģ���� sigma = 0 ��ͬ����matlab2017֮ǰ��ʾΪ��'sm'
    
   %% ���±��ʽ��18���е�Gii��������
    %ds��dt�ֱ��ʾԴ��Ŀ�������ݵ�ά��
    if(ds==dt)
        G(1:ns,1:ns) = diag(sparse(1./(sqrt(sum(A(1:ns,:).^2,2)+eps))));
        %S = sparse(A) ͨ�������κ���Ԫ�ؽ�������ת��Ϊϡ���ʽ����ʡ�ռ��ðɡ�
        %eps�Ǹ�����������,��ָ��������������������Ĳ����С����
    else
        %�Ծ���Aÿһ�н�����ͣ�֮���ÿһ�н��п�ƽ����������ÿһ�еĵ�����
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
  
    %% ����������˹��Laplacian������L=D-W
    if strcmp(Goptions.model,'sig')
        %����Ŀ����α��ǩ�Ѿ����£���ôX=[Xs;Xt]��k���ڹ�ϵҲ�����仯��������Ҫ���¾���W 
        W= constructW(X',Goptions);
        %����W�������仯����ôW1(L)=D-WҲҪ�����仯
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
        %��ΪXt = [T;Ttest];���Դ�ns+nst+1��ʼ��n.
        Zt=Z(:,ns+nst+1:n)';
        %Ssamps=Zs(ids,:);
        % ��Ŀ������ȫΪ���c�ĵ�����������Tsamps
        Tsamps=Zt(idt,:);
       %% ����Ŀ������c��ĵ�ֱ�Դ��Zs�ľ��룬����knnsearch��ѡ��Zs�е�10���ڵ㡣
        [idx, ~] = knnsearch(Zs,Tsamps,'dist','cosine','k',10);
        % knnsearch��������dist����ʾ�������Ĺ�ʽ������Ϊcosine.����"k"��ʾѡ��Ľ��ڵ����������Ϊ10��.
        % idx��ʾ����Դ���н��ڵ�����
        
        idx=idx(:);
        for i=1:length(idx)
           % ���Ȩ����Դ���Ȩ�أ�Դ��200+30���㡣��Щ�㣬һ��ʼȨ�ض���0��ֻҪ��ΪĿ����ĳ��Ľ��ڣ�Ȩ�ؾͼ�1.
           weight(idx(i,:),:)=weight(idx(i,:),:)+1;
        end
    end
     
end


end
