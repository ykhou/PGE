%% PGE
clc;
clear;
%% ��������
datapath = 'Bot_data/';
str = {'5161', '6151', '5171', '7151', '6171', '7161'};
id = 5; % id���ڼ����ͼ��صڼ����ļ���datepath������5���ļ�
load([datapath str{id}]);
Xs=ROI6_scale;
Ys=Label6;
Xt=ROI7_scale;
Yt=Label7;
Xs_row=ROI6_row;     Xs_col=ROI6_col;
Xt_row=ROI7_row;     Xt_col=ROI7_col;
[ns,~] = size(Xs); [nt,~] = size(Xt);
%% ����ͼ������һ����ע�⣬5�����������target����ô��Ҫ����һ�¡�
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

%% �ռ��˲������ĵ���
% win_size=3;
% Xt=spatial_filtering_fixed_window(IMG_target_norm,win_size,Xt,Xt_row,Xt_col);

% %% OCCƽ��
% a=mean(Xs);b=mean(Xt);
% d=a-b;
% ROI6_scale_new=Xs-repmat(d,size(Xs,1),1);
% Xs=ROI6_scale_new;
%% PGE
for k = 1:5
    [Xsa,Xta] = PGE(Xs,Ys,Xt);

% ����������
% SVM�Ĵ��룺
% Xs��Ys��Դ�����training���ݺ�label,Xt,Yt��Ŀ�������ݻ���test���ݺ���label
% ��һ���������Ų������ͷ�����C��RBF�˺����Ĳ�����,�ڶ��о��ǰѲ�����ϳ�cmd,��Ϊ������ѵ��svm��һ�����ڲ����
% ��������ѵ��svm������,����model,��������ܶ������Ȥ�Ŀ��԰ٶȲ�,����ģʽʶ��ppt����Ҳ�г����ˡ�
% �������Ƕ�Ŀ�������ݷ���,Yt0�Ƿ�������hard label,��ÿһ��test���ݵ�,�����������ĸ���������Ϣ��,OA�Ƿ��ྫ��,Pt0��soft label����ÿ��test���ݵ�,���������ڸ�����ĸ�����Ϣ��

    [~,bestc,bestg] = SVMcgForClass_TL(Ys,Xsa');    %�����Ų��� 
    cmd=['-t 2',' -g ' num2str(bestg), ' -c ' num2str(bestc)]; 
    model = svmtrain( Ys , Xsa' , [ '-c ' num2str(bestc) ' -g ' num2str(bestg) ' -b 1 ' ]);
    [ Yt0, OA, Pt0] = svmpredict( Yt, Xta', model ,' -b 1 ' );

% [~,bestc,bestg] = SVMcgForClass_TL(Ys,Xs);    %�����Ų��� 
% cmd=['-t 2',' -g ' num2str(bestg), ' -c ' num2str(bestc)]; 
% model = svmtrain( Ys , Xs , [ '-c ' num2str(bestc) ' -g ' num2str(bestg) ' -b 1 ' ]);
% [ Yt0, OA, Pt0] = svmpredict( Yt, Xt, model ,' -b 1 ' );
    Xs = Xsa';
    Xt = Xsa';
    
end
