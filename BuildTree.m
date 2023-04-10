
clc
clear 
close all

rng default

global Leafnodes parent_feat_split nodes predictedy minLeafsize VIM

[data,txt,raw]=xlsread('N2-Data.xlsx',1);
        
x=[data(:,1:4) data(:,5)];
y=data(:,7);

Ns=floor(0.8*length(data));
[xtrain,xtest,ytrain,ytest]=train_test_data(x,y,'HS',Ns,0);

[xtrain,mux,sigmax] = zscore(xtrain);
[ytrain,muy,sigmay] = zscore(ytrain);

xnew=(xtest-mux)./sigmax;

names_predictors = {'FN','FF', 'TN','TF','UA'}; %,'\rhoN','\rhof'

Y = ytrain;
X = xtrain;

test_setx=xnew;
test_sety=ytest;

% % Leafsizes=[20:-1:2];
% % % determining optimum size of leaf nodes
% % [opt_leafsize]=opt_minLeafsize(X,Y,val_setx,val_sety,names_predictors,Leafsizes);

% growing full size tree
% Leafnodes=[];
% parent_feat_split=[];
% nodes=[];
% minLeafsize=6;
% [Tree]=RTree(X,Y,names_predictors);
% Tree.nodes=nodes;
% Tree.leafnodes=Leafnodes;
% Tree.parent_feat_split=parent_feat_split;
% Tree.predy=predy(Tree,Y);
% 
% % predictions over test set by using single tree
% pred_resp_test1=zeros(size(test_setx,1),1);
% for t=1:size(test_setx,1)
%     dataval=test_setx(t,:);
%     pred_resp_test1(t)=predict(dataval,Tree);
% end
% R_test=corr(test_sety,pred_resp_test1,'Type','Spearman');
% 
% clear Leafnodes parent_feat_split nodes minLeafsize

%%% plotting full size tree
% % figure(1)
% % treeplot(Tree.p')
% %  
% % [xs,ys,h,s]=treelayout(Tree.p');
% % 
% % for i=1:length(Tree.p)
% %    text(xs(i),ys(i),num2str((i)),'VerticalAlignment','bottom','HorizontalAlignment','right')
% % end
% % 
% % for i=2:numel(Tree.p)
% %     
% %     child_x=xs(i);
% %     child_y=ys(i);
% %     
% %     parent_x=xs(Tree.p(i));
% %     parent_y=ys(Tree.p(i));
% %     
% %     mid_x=(child_x+parent_x)/2;
% %     mid_y=(child_y+parent_y)/2;
% %     
% %     text(mid_x,mid_y,Tree.labels{i-1})
% %     
% %     % terminal node
% %     if ~isempty(Tree.indices{i})
% %         val=Y(Tree.indices{i});
% %         text(child_x,child_y,sprintf('y=%2.2f\nn=%d', mean(val), Tree.p(i)))
% %     end
% % end


% creating 100 bootstrapped training datasets from the original training dataset 
disp('bootstrap')
bs=39;
[~,bootsamples]=bootstrp(bs,[],X);
bootstrap_trees=cell(bs,1);

% out-of-bag observations
S=cell(bs,1);
SS=[];
for i=1:bs
    S{i}=oobsamples(bootsamples(:,i),length(X));
    SS=[SS;S{i}];
end
OOB=unique(SS);

for j=1:bs
    
    VIM=zeros(1,size(X,2));
    Leafnodes=[];
    parent_feat_split=[];
    nodes=[];
    minLeafsize=1;
    [tree]=RTree(X(bootsamples(:,j),:),Y(bootsamples(:,j)),names_predictors);
    tree.nodes=nodes;
    tree.leafnodes=Leafnodes;
    tree.parent_feat_split=parent_feat_split;
    tree.predy=predy(tree,Y(bootsamples(:,j)));
    tree.vim=(VIM/(length(nodes)-length(Leafnodes)));
    
    bootstrap_trees{j}=tree;
    clear tree
  
end
vim_sum=0;
for i=1:bs
    tree=bootstrap_trees{i};
    vim_sum=vim_sum+tree.vim;
end
vim_avg=vim_sum./bs;

figure(3)
bar(vim_avg)
% xticklabels(names_predictors)
ylabel('Preditor Importance')
% title('VIM')
h = gca;
txt = texlabel('lambda12^(3/2)/pi - pi*delta^(2/3)');   
% h.XTickLabel ={'X1','X_{2}','X_{3}','X_{4}','X_{5}','X_{6}','X_{7}','X_{8}','Interpreter', 'tex'};%names_predictors;
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';

% predictions over test set by using bootstrap aggregated predictive models
pred_resp_test=zeros(size(test_setx,1),1);
for t=1:size(test_setx,1)
    dataval=test_setx(t,:);
    predresp=zeros(bs,1);
    for i=1:bs
        [predresp(i)]=predictt(dataval,bootstrap_trees{i});
    end
    pred_resp_test(t)=mean(predresp);
end

pred_resp_test=pred_resp_test*sigmay+muy;
% ytest=ytrain*sigmay+muy;

ytest=test_sety;
ypred=pred_resp_test;

R2=(corr(ytest,ypred)^2);
fprintf('R^2= %4.4f \n',R2)

% sse=sum((ypred-ytest).^2);
% sst=sum((ytest-mean(ytest)).^2);
% R2=1-(sse/sst);
% disp(R2)

AARD=100*mean(abs((ypred-ytest)./ytest));
fprintf('AARD= %4.4f \n',AARD)

RMSE=sqrt(mean((ypred-ytest).^2));
fprintf('RMSE= %4.4f \n',RMSE)

figure
plot(ytest)
hold on
plot(ypred)
legend('data','prediction')

% average percent relative error
E=((ytest-ypred)./ytest)*100;
Er=mean(E);
fprintf('Er= %4.4f \n',Er)

Ea=mean(abs(E));
fprintf('Ea= %4.4f \n',Ea)

R_test_bs=corr(test_sety,pred_resp_test,'Type','Spearman');

disp('single tree')
% growing full size tree
Leafnodes=[];
parent_feat_split=[];
nodes=[];
minLeafsize=1;
[Tree]=RTree(X,Y,names_predictors);
Tree.nodes=nodes;
Tree.leafnodes=Leafnodes;
Tree.parent_feat_split=parent_feat_split;
Tree.predy=predy(Tree,Y);
% 
% % predictions over test set by using single tree
pred_resp_test1=zeros(size(test_setx,1),1);
for t=1:size(test_setx,1)
    dataval=test_setx(t,:);
    pred_resp_test1(t)=predictt(dataval,Tree);
end
pred_resp_test1=pred_resp_test1*sigmay+muy;
R_test_single=corr(test_sety,pred_resp_test1,'Type','Spearman');

samples=[1:1:length(test_sety)];

figure(1)
plot(samples,test_sety,samples,pred_resp_test,'-o',samples,pred_resp_test1,'-*')
legend('Observed Response','Predicted Response-Bagging','Predicted Response-Single Tree')

figure(2)
plot(test_sety,test_sety,test_sety,pred_resp_test,'o',test_sety,pred_resp_test1,'*')
legend('Observed Response','Predicted Response-Bagging','Predicted Response-Single Tree')

% pearson correlation coeff. between each predictor and response variable
pearsonR=zeros(1,size(X,2));
for i=1:1:size(X,2)
    pearsonR(i)=corr(X(:,i),Y);
end
