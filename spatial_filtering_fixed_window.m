
%% spatial filtering

% input: 
% segmentation resutls SEG
% window size
% the coordinates of X
% X:n*d
% Img:3 dimenstional data

% output:
% spatial filtering data

function Spa_X=spatial_filtering_fixed_window(Img,win_size,X,Row,Col)

NbDim=size(X,2);
NbRow=size(Img,1);
NbCol=size(Img,2);
for ii=1:size(X,1)
    row_cur=Row(ii);col_cur=Col(ii);
    
    %%获得当前点所在固定window内搜有点的坐标
    [a1,a2,nL]=window(win_size,row_cur,col_cur,NbRow,NbCol);
    A=[];a1=a1';a2=a2';
    for j=1:length(a2) A=[A;a1,repmat(a2(j),length(a1),1)];end
    spatial_data=[];
    for j=1:nL  spatial_data=[spatial_data;reshape(Img(A(j,1),A(j,2),:),1,NbDim)];end
    Spa_X(ii,:)=mean(spatial_data);
    Spa_X(ii,:)=mean([reshape(Img(row_cur,col_cur,:),1,NbDim); Spa_X(ii,:)]);
end
