
%% ��ǰ�㣨i��j����5*5���ڵ��������꡾����ij�㱾��
% last_row�ǵ�ǰ�����ͼ������һ�е���ֵ��������
% last_col�ǵ�ǰ�����ͼ������һ�е�ֵ��������
% ���a1��a2���Ǵ����ڵ����������
% size:��ʾwindow��size
% size�̶�

function [a1,a2,nL,index]=window(size,i,j,last_row,last_col)

r=(size-1)/2;%%���ڰ뾶

if i<r+1
    i_start=1;
    i=r+1;
else
    i_start=i-r;
end

if j<r+1
    j_start=1;
    j=r+1;
else
    j_start=j-r;
end

if i>last_row-r
       i_end=last_row;
       i_start=last_row-size+1;
else
     i_end=i+r;
end

if j>last_col-r
       j_end=last_col;
       j_start=last_col-size+1;
else
    j_end=j+r;
end


a1=i_start:i_end;
a2=j_start:j_end;
nL=length(a1)*length(a2);

index=[];
for i=1:length(a1)
    for j=1:length(a2)
        index=[index,(a2(j)-1)*last_row+a1(i)];
    end
end

%      A=[];a1=a1';a2=a2';
%      for j=1:length(a2) A=[A;a1,repmat(a2(j),length(a1),1)];end