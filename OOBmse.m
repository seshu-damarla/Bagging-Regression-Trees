
clc
clear 
close all

rng default

global Leafnodes parent_feat_split nodes predictedy minLeafsize VIM

[data,~,raw]=xlsread('N2-Data.xlsx',1);
        
x=[data(:,1:4) data(:,5)];
y=data(:,7);

Ns=floor(0.8*length(data));
[xtrain,xtest,ytrain,ytest]=train_test_data(x,y,'HS',Ns,0);

[xtrain,mux,sigmax] = zscore(xtrain);
[ytrain,muy,sigmay] = zscore(ytrain);
yytrain=ytrain*sigmay+muy;

names_predictors = {'x1','x2', 'x3','x4','x5'}; 

Y = ytrain;
X = xtrain;

% OOB MSE to find optimum number of trees
% creating 100 bootstrapped training datasets from the original training dataset 
disp('bootstrap')
Numtrees=[5:2:200];
MSE=zeros(length(Numtrees),1);

h=animatedline;    % for dynamic plot
xlabel('Number of weak learners')
ylabel('OOB mean squared error')

for i=1:1:length(Numtrees)
    
bs=Numtrees(i);
[~,bootsamples]=bootstrp(bs,[],X);
bootstrap_trees=cell(bs,1);

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

% predictions over test set by using bootstrap aggregated predictive models
pred_resp_test=zeros(size(xtrain,1),1);
for t=1:size(xtrain,1)
    dataval=xtrain(t,:);
    predresp=zeros(bs,1);
    for i=1:bs
        [predresp(i)]=predictt(dataval,bootstrap_trees{i});
    end
    pred_resp_test(t)=mean(predresp);
end

pred_resp_test=pred_resp_test*sigmay+muy;

MSE(i)=mean((pred_resp_test-yytrain).^2);
clear bootstrap_trees tree
clear pred_resp_test

addpoints(h,i,MSE(i));
drawnow

end

mse=[];
for i=1:length(MSE)
    if MSE(i)>0
        mse=[mse;MSE(i)];
    end
end
[~,idx]=min(mse);
