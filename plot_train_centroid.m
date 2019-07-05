
function plot_train_centroid(train_data_new, train_label, test_data_new, test_label, C, d1,d2)
% 相比较plot_all_target_class_to_all_source_class，把类心也画上。
% 画对齐前后，target所有类别和source所有类别的对齐情况。
% train_data_original是原始source数据，train_data_new是spa-oca-ccca对齐后的
% train_label是source标签。
% test_data是spa后的target数据，test_label是target的标签。
% C:数据类别个数   
% d1,d2:作图波段
% dataname: 数据名称，如bot56、id1等
% figpath:图像存储路径


% datapath='I:\work\CUG\Student\研究生\祝蕾\SA\MaLi\MaLi code\paper_plot\mat\scatter_plot_data\';

% dataname='BOT';C=9;%% 颜色用cmap
% id=1;
% load([datapath,'5161_id1_Spa_OCA_CCCA_win3_c200_g05']);
% id=2;load([datapath,'6151_id2_Spa_OCA_CCCA_win3_with_data']);
% id=3;load([datapath,'5171_id3_Spa_OCA_CCCA_win3_with_data']);
% id=4;load([datapath,'7151_id4_Spa_OCA_CCCA_win3_c200_g02_with_data']);
% id=5;load([datapath,'6171_id5_Spa_OCA_CCCA_win3_with_data']);
% id=6;load([datapath,'7161_id6_Spa_OCA_CCCA_win3_with_data']);

%% DFC 用cmap2
% dfc如果用同种颜色画ST，那么都用cmap2,如果用不同颜色，就要加入cmap—t来画Xt数据。
% dataname='DFC';C=4;
% % % id=1;load([datapath,'DFC_1_Spa_OCA_CCCA_win3_with_data']);
% id=2;load([datapath,'DFC_2_Spa_OCA_CCCA_win3_with_data']);
% train_label(find(train_label==10))=3;train_label(find(train_label==11))=4;
% test_label(find(test_label==10))=3;test_label(find(test_label==11))=4;

%% Wv2 用cmap2
% dataname='WV2';
% C=4;
% % id=1;load([datapath,'time1VStime2__1_Spa_OCA_CCCA_win3_with_data']);
% id=2;load([datapath,'time2VStime1__1_Spa_OCA_CCCA_win3_with_data_expt1']);


%% dfc，wv2
%        cmap_t=[
%            255  100  155   %深红色13
%            50 150 100 %绿色  较亮19
%            0   100    255    %蓝色10   ;%  255 215 0 ;%金黄色160 32 240   %紫色5
%            221 100 100]/255;%枚红色2
      cmap2=[
            255  0  255   %深红色13
            0 255 0 %绿色  较亮19
            0     100    255    %蓝色10   ;%  255 215 0 ;%金黄色160 32 240   %紫色5
            250 50 0]/255;%枚红色2
      cmap_t=cmap2;
% 


% figpath='I:\work\CUG\Student\研究生\祝蕾\SA\MaLi\MaLi code\paper_plot\scatter_plot\all_target_to_all_source\';


%% 画图工具
%         cmap=[
%             255  0  255   %深红色13
%             0 255 0%绿色  较亮19
%             160 32 240   %紫色5
%             221 160 221%枚红色2
%             34 139 34    %森林绿3
%             25 25 112%深蓝色9
%             255  97  0    %橙色11
%             255  0    0       % 红色7
%             61  89   171  %钴色    17
%             128 42 42   %棕色1
%             189 252 201%薄荷绿4 
%             255 192 203%粉红14                       
%             156 102 31%砖红8            
%             0     0    255    %蓝色10           
%            255 215 0%金黄色12           
%             218 112 214%淡紫色6
%             0 255 255   %青色15
%             250 128 114%橙红色16
%             30 144 255%dodger blue18
%         94 203 55       % Scrub
%         255 0 255       % Willow
%         217 115 0       % CP Hammock
%         179 30 0        % CP Oak
%         0 52 0          % Slash Pine
%         72 0 0          % Oak/Broadleaf
%         255 255 255     % Hardwood swamp
%         145 132 135     % Graminoid marsh
%         255 255 172     % Spartina marsh
%         255 197 80      % Cartail Marsh
%         60 201 255      % Salt Marsh
%         11 63 124       % Mud flats
%         0  0  255       % Water
%         ]/255; 
    
      cmap=[
            255   0 255  %深红色13
              0 255   0 %绿色  较亮19
              0   0 255 %蓝色10   ;%  255 215 0 ;%金黄色160 32 240   %紫色5
            221 160 221 %枚红色2
             34 139  34 %森林绿3
            255   0   0;%25 25 112 %深蓝色9
            255  97  0    %橙色11
            128 42 42   %棕色1
            61  89   171  %钴色    17
            160 32 240  %紫色5
            255  0    0       % 红色7
            0 255 255   %青色15 % 0     0    255    %蓝色10   
            189 252 201%薄荷绿4 
            255 192 203%粉红14                       
            156 102 31%砖红8            
            255 215 0%金黄色12           
            218 112 214%淡紫色6
            0 255 255   %青色15
            250 128 114%橙红色16
            30 144 255%dodger blue18
            94 203 55       % Scrub
            255 0 255       % Willow
            217 115 0       % CP Hammock
            179 30 0        % CP Oak
            0 52 0          % Slash Pine
            72 0 0          % Oak/Broadleaf
            255 255 255     % Hardwood swamp
            145 132 135     % Graminoid marsh
            255 255 172     % Spartina marsh
            255 197 80      % Cartail Marsh
            60 201 255      % Salt Marsh
            11 63 124       % Mud flats
            0  0  255       % Water
            ]/255; 

marks={'o', '^', 's','+', 'd', 'p','h','*','<','>','h','h'};
% marks={'o', '^', 's','d', 'd', 'p','h','*','<','>','h','h'};
Exp.markersize=12;
Exp.linewidth=2.5;%bot
% Exp.linewidth=2.5% dfc wv2

%BOT
% d1=50;d2=100;%DFC
% d1=1;d2=6;%wv2

cmap2 = cmap(1:9,:);%浅色
cmap1 = cmap(10:18,:);%深色


%% 对齐后
C = 9;
for class = 1:C
    figure(class+1);
    [ind_2,~]= find(test_label == class);
    data2 = test_data_new(ind_2,:);
%     T_center = mean(data2);
%     plot(data2(:,d1),data2(:,d2),[ marks{1}], 'color',cmap(C+3,:),'LineWidth',1);hold on;
%     plot(data2(:,d1),data2(:,d2),[ marks{1}],'color',cmap(C+3,:), 'markerfacecolor', cmap(C+3,:));hold on;
    p2(class)=plot(data2(:,d1),data2(:,d2),[ marks{8}],'color',cmap2(class,:));hold on;
%     axis([0, 0.2, 0, 0.2]);
%     plot(T_center(:,d1),T_center(:,d2),'k*','MarkerSize',Exp.markersize,'LineWidth',2.5);

    [ind_1,~] = find(train_label == class);
    data = train_data_new(ind_1,:);
%     S_center = mean(data);
%     plot(data(:,d1),data(:,d2),[ marks{4}], 'color',cmap(class,:),'LineWidth',1);hold on;
%     plot(data(:,d1),data(:,d2),[ marks{5}],'color',cmap(class,:), 'markerfacecolor', cmap(class,:), 'MarkerSize',5);hold on;
    p1(class)=plot(data(:,d1),data(:,d2),[ marks{1}],'color',cmap1(class,:));hold on;
%      axis([0, 0.2, 0, 0.2]);
%    plot(S_center(:,d1),S_center(:,d2),'ko','MarkerSize',Exp.markersize+3,'LineWidth',2.5);
%       plot(S_center(:,d1),S_center(:,d2),'k.','MarkerSize',Exp.markersize);
%  name=['第',num2str(class),'类']
%  title(name);
%% 再画中心
    [ind_1,~] = find(train_label == class);
    data = train_data_new(ind_1,:);
    S_center = mean(data);
   plot(S_center(:,d1),S_center(:,d2),'ko','MarkerSize',Exp.markersize+3,'LineWidth',Exp.linewidth);
    plot(S_center(:,d1),S_center(:,d2),'k.','MarkerSize',Exp.markersize);
%      axis([0, 0.2, 0, 0.2]);
    [ind_2,~]= find(test_label == class);
    data2 = test_data_new(ind_2,:);
     T_center = mean(data2);
    plot(T_center(:,d1),T_center(:,d2),'k*','MarkerSize',Exp.markersize,'LineWidth',Exp.linewidth);
%          axis([0, 0.2, 0, 0.2]);
end
% 加标签，没啥用
% Leg={'Xs\_C1','Xs\_C2','Xs\_C3','Xs\_C4','Xs\_C5','Xs\_C6','Xs\_C7','Xs\_C8','Xs\_C9'};
% % axis([0 0.8 0 0.8]) %% only for wv2012-2011 expt1
% h=legend(p1,Leg,'Location','SouthEast');
% set(gca, 'fontsize', 18);


%% 再画中心
% for class = 1:C
%     [ind_1,~] = find(train_label == class);
%     data = train_data_new(ind_1,:);
%     S_center = mean(data);
%    plot(S_center(:,d1),S_center(:,d2),'ko','MarkerSize',Exp.markersize+3,'LineWidth',Exp.linewidth);
%     plot(S_center(:,d1),S_center(:,d2),'k.','MarkerSize',Exp.markersize);
% %      axis([0, 0.2, 0, 0.2]);
% end
% for class = 1:C
%     [ind_2,~]= find(test_label == class);
%     data2 = test_data_new(ind_2,:);
%      T_center = mean(data2);
%     plot(T_center(:,d1),T_center(:,d2),'k*','MarkerSize',Exp.markersize,'LineWidth',Exp.linewidth);
% %          axis([0, 0.2, 0, 0.2]);
% end

% ylb=ylabel(['band ',int2str(d2)]);
% xlb=xlabel(['band ',int2str(d1)]);
% set(ylb, 'fontsize', 18,'FontWeight','bold');
% set(xlb, 'fontsize', 18,'FontWeight','bold');
% % axis([0.05 0.6 0.05 0.8]) %% only for wv2012-2011 expt1
% grid on;
% Leg={'Xt\_C1','Xt\_C2','Xt\_C3','Xt\_C4','Xt\_C5','Xt\_C6','Xt\_C7','Xt\_C8','Xt\_C9'};
% % Leg=[Leg,['Xt\_C',int2str(target_class)]];
% ah=axes('position',get(gca,'position'),'visible','off');
% h=legend(ah,p2,Leg,'Location','SouthEast');
% set(gca, 'fontsize', 18);

% string='fjldafa;fadfadg'
% text(0.5,0,string,'FontSize',18,'FontWeight','Bold')
% 
% name=[dataname,'_id',int2str(id),'_new_train_Expt6','_band_',int2str(d1),'_',int2str(d2)]
% name0=strcat(name,'.tiff');%当前
% eval(['saveas(gcf,',char(39),figpath,name0,char(39),')']);

% name=[dataname,'_new_source_target','_band_',int2str(d1),'_',int2str(d2)]
% name0=strcat(name,'.bmp');%当前
%eval(['saveas(gcf,',char(39),figpath,name0,char(39),')']);

end