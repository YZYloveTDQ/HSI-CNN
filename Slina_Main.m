% ������Ϣ  ���ǻ�����SVM��HSIͼ�� Indian_pines�ķ������
% �����ݵĵ��룬�����������ྫ�ȣ�Kappaϵ�����Լ���Ӧ
% չʾԭʼͼ�ͷ�����ͼ
% ���ߣ�����  �Ͼ�ʦ����ѧ�����Ժ-13��   ����  : zzkgo@qq.com   qq:691960830
clc;
clear;

load('Indian_pines_corrected');
%Indian_Pines����
load('Indian_pines_gt');
%Indian_Pines��ǩ��Ϣ
label=double(indian_pines_gt);
image=permute(indian_pines_corrected,[3,1,2]);
[p m n] = size(image);


%���й���16�����-��Ӧÿ��������ݴ�С
%1.Alfalfa  46
%2.Corn-no till 1428
%3.Corn-min till 830
%4.Corn 237
%5.Hay-windowed 483
%6.Grass/trees 730
%7.Grass/pasture-mowed 28
%8.Grass/pasture  478
%9.Otas 20
%10.Soybeans-no till 972
%11.Soybeans-min till 2455
%12.Soybeans-clean till 593
%13.Wheat 205
%14.Woods 1265
%15.Bldg-Grass-Tree-Drives 386
%16. Stone-steel towers 93
classnum=16;

%ѡȡ���е� 10%��Ϊѵ������
par=0.55;

train_index=[];
train_set=[];
train_label=[];

test_index=[];
test_set=[];
test_label=[];

for i=1:1:classnum
    index=find(label==i);
    len=length(index);
    
    t_index=randsample(index,round(par*len));
    train_index=[train_index;t_index];
    train_label=[train_label;label(t_index)];
    train_set=[train_set;image(:,t_index)'];
    
    tt_index=setdiff(index,t_index);
    test_index=[test_index;tt_index];
    test_label=[test_label;label(tt_index)];
    test_set=[test_set;image(:,tt_index)'];
    
end



% 
for i=1:length(train_label)
    train_set(i,:)=train_set(i,:)/norm(train_set(i,:));    
end


for i=1:length(test_label)
test_set(i,:)=test_set(i,:)/norm(test_set(i,:));

end
%PCA��ά
[coef,score,latent,t2]=princomp(train_set);
x0 = bsxfun(@minus,train_set,mean(train_set,1));
train_set=x0*coef(:,1:80);
x0 = bsxfun(@minus,test_set,mean(test_set,1));
test_set=x0*coef(:,1:80);
% all_data=[train_set;test_set];
% for i=1:200
%    % all_data(:,i)=(all_data(:,i)-min(all_data(:,i)))/(max(all_data(:,i))-min(all_data(:,i)));
%     all_data(:,i)=all_data(:,i)/norm(all_data(:,i));
% end
% train_set=all_data(1:1027,:);
% test_set=all_data(1028:10249,:);


%    OPT_SVM�Ĳ���  
%���е�b�Ǳ�ʾ�Ƿ�probability_estimates: whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)

opt_svm = '-s 0 -t 2 -c 1024 -g 2^-7 -b 1';
model=svmtrain(train_label,train_set,opt_svm);
[predict_label a, cof]=svmpredict(test_label,test_set,model,'-b 1');
%չʾ˳�򣺼���������   ���㾫�����徫��   ����ƽ������   ����kappaϵ��
%����ͼ��:   ԭʼͼ   ѵ������ͼ   ���Լ���ͼ    ������ͼ 
%�����д

%�����������õ�
conf_m=zeros(classnum);
for i=1:1:classnum
    i_index=find(predict_label==i);
    i_test_label=test_label(i_index);
    for j=1:1:classnum
        id=find(i_test_label==j);
        conf_m(i,j)=length(id);
    end
end
%�������徫��
Overall_accuracy=sum(diag(conf_m))/sum(sum(conf_m));
%����ƽ������
Overall_accuracy_PerClass=diag(conf_m)'./sum(conf_m);
%����Kappaϵ��
kappa=kappa(conf_m);

%����ͼ��    ԭʼͼ   ѵ������ͼ   ���Լ���ͼ    ������ͼ 
Original_image=zeros(m,n);
Train_image=zeros(m,n);
Test_image=zeros(m,n);
Predic_image=zeros(m,n);

Original_image=label;
Train_image([train_index])=[train_label];
Test_image([test_index])=[test_label];

Predic_image([train_index;test_index])=[train_label;predict_label];
f=figure(1);set(f, 'Position',  [0 114 1400 600]); 
subplot(121);
imagesc(Original_image);
subplot(122);
imagesc(Predic_image);
map = zeros(15,3);
map=[   255   255   255
        0  107  253
        0  186  253
      111  248  255
        0  150   50
        0  220    0
      180  255  180
      0      0    0
      196  166    0
      255  255    0
      255  200    0
      255    0    0
      255  100  100
      255  180  180
      200  100  155
      150    0  180 
      255    0  255];
map=map/255.0;
colormap(map);
f2=figure(2);
set(f2,'Position',[0  144 1400 600])
subplot(131);
imagesc(Predic_image);
subplot(132);
imagesc(Train_image);
subplot(133);
imagesc(Test_image);