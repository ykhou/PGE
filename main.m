%% PGE
clc;
clear;
%% 读入数据
datapath = 'Bot_data/';
str = {'5161', '6151', '5171', '7151', '6171', '7161'};
id = 5; % id等于几，就加载第几个文件。datepath里面有5个文件
load([datapath str{id}]);
Xs=ROI6_scale;
Ys=Label6;
Xt=ROI7_scale;
Yt=Label7;
Xs_row=ROI6_row;     Xs_col=ROI6_col;
Xt_row=ROI7_row;     Xt_col=ROI7_col;
[ns,~] = size(Xs); [nt,~] = size(Xt);
%% 整个图像做归一化，注意，5月数据如果是target，那么需要处理一下。
% if id==2 || id==4
%     img_t=reshape(IMG_target,size(IMG_target,1)*size(IMG_target,2),size(IMG_target,3));
%     img_t(:,1:46)=img_t(:,1:46)*0.4;
%     img_t(:,47:145)=img_t(:,47:145)*0.8;
% else
%    img_t=reshape(IMG_target,size(IMG_target,1)*size(IMG_target,2),size(IMG_target,3));
% end
% 
% [img_t_norm,ps] = mapminmax('apply',img_t',ps); % 
% img_t_norm=img_t_norm';
% for i=1:size(IMG_target,3)
%     IMG_target_norm(:,:,i)=reshape(img_t_norm(:,i),size(IMG_target,1),size(IMG_target,2));
% end

%% 空间滤波函数的调用
% win_size=3;
% Xt=spatial_filtering_fixed_window(IMG_target_norm,win_size,Xt,Xt_row,Xt_col);

% %% OCC平移
% a=mean(Xs);b=mean(Xt);
% d=a-b;
% ROI6_scale_new=Xs-repmat(d,size(Xs,1),1);
% Xs=ROI6_scale_new;
%% PGE
for k = 1:5
    [Xsa,Xta] = PGE(Xs,Ys,Xt);

% 分类器分类
% SVM的代码：
% Xs，Ys是源域或者training数据和label,Xt,Yt是目标域数据或者test数据和其label
% 第一行是求最优参数（惩罚因子C和RBF核函数的参数）,第二行就是把参数组合成cmd,作为第三行训练svm的一个属于参数项。
% 第三行是训练svm分类器,返回model,里面包括很多项，有兴趣的可以百度查,我在模式识别ppt里面也列出来了。
% 第四行是对目标域数据分类,Yt0是分类结果（hard label,对每一个test数据点,给出其属于哪个类的类别信息）,OA是分类精度,Pt0是soft label（对每个test数据点,给出其属于各个类的概率信息）

    [~,bestc,bestg] = SVMcgForClass_TL(Ys,Xsa');    %求最优参数 
    cmd=['-t 2',' -g ' num2str(bestg), ' -c ' num2str(bestc)]; 
    model = svmtrain( Ys , Xsa' , [ '-c ' num2str(bestc) ' -g ' num2str(bestg) ' -b 1 ' ]);
    [ Yt0, OA, Pt0] = svmpredict( Yt, Xta', model ,' -b 1 ' );

% [~,bestc,bestg] = SVMcgForClass_TL(Ys,Xs);    %求最优参数 
% cmd=['-t 2',' -g ' num2str(bestg), ' -c ' num2str(bestc)]; 
% model = svmtrain( Ys , Xs , [ '-c ' num2str(bestc) ' -g ' num2str(bestg) ' -b 1 ' ]);
% [ Yt0, OA, Pt0] = svmpredict( Yt, Xt, model ,' -b 1 ' );
    Xs = Xsa';
    Xt = Xsa';
    
end
