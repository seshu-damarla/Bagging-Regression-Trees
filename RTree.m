
function [Tree]=RTree(X,Y,names_predictors)

global Leafnodes parent_feat_split nodes minLeafsize VIM
% X is set of predictors or features
% Y is observed response 
% names_predictors is set of names of all predictors

% Tree is the regression tree grown using the procedure explained below

% First, we start with the root node which has no parent.
% The root node is given index of 1. The roor node contains all the
% training observations.

indices={1:size(X,1)}; % indices of training observations in root node
p=0;                   % index of the parent node for root node
labels={};             % decision or question to split root node
[indices,p,labels]=split_node(X,Y,indices,p,labels,names_predictors,1); % recursive binar splitting 

Tree.indices=indices;
Tree.p=p;
Tree.labels=labels;


function [indices,p,labels,Leafnodes]=split_node(X,Y,indices,p,labels,names_predicotrs,node)

global Leafnodes parent_feat_split nodes minLeafsize VIM

% % declaring terminal (leaf) node 
% if numel(Y(indices{node}))==1
%     return
% end
nodes=[nodes;node];
% Check if terminal node criterion is satisfied 

if numel((indices{node}))<=minLeafsize
    Leafnodes=[Leafnodes;node];
    return;
end
% node
% unique(X(indices{node},:))
% check if inputs have the same features
if size(unique(X(indices{node},:)),1)==1
    return
end

% split the current node on some feature
best_RSS=-inf;
best_feature=0;
best_split=0;

curr_X=X(indices{node},:);
curr_Y=Y(indices{node});

for i=1:size(curr_X,2)
    
    feature=curr_X(:,i); % picking a feature
    
    vals=unique(feature);
    
%     if aaa==1 && node==12
%         node
%         indices{node}
%         numel(vals)
%     end
    
    if numel(vals)<2
       continue
    end

%     if numel(vals)==1
%         splits=vals;
%     else
        splits=(vals(1:end-1)+vals(2:end))/2;  % midpoint of measurments of the selected feature
%     end
    
    % binary values for each split value

    bin_mat=double(repmat(feature,[1 numel(splits)])<repmat(splits',[numel(feature) 1]));

    % residual sum of current parent node
    RSS=RSS_parent(curr_Y);

    rss=zeros(1,size(bin_mat,2));
    for j=1:size(bin_mat,2)
        rss(j)=Rss_child(curr_Y,bin_mat(:,j));
    end
    [maxval,idx]=max(RSS-rss);

    if maxval>best_RSS  % greatest reduction in residual sum of squares
        best_RSS=maxval;
        best_feature=i;
        best_split=splits(idx);
    end
end

parent_feat_split=[parent_feat_split;[node best_feature best_split]];

% split the current node into two nodes using best feaure and best split

if best_feature==0
    return
end
VIM(best_feature)=VIM(best_feature)+best_RSS;
feat=curr_X(:,best_feature); % best feaure at the current node
feat=feat<best_split;
samples=indices{node};
indices=[indices;samples(feat==1);samples(feat==0)];
indices{node}=[];
p=[p;node;node];

labels=[labels;sprintf('%s < %2.2f',names_predicotrs{best_feature},best_split);...
    sprintf('%s >=%2.2f',names_predicotrs{best_feature},best_split)];

% repeat on newly created nodes
n = numel(p)-2;
% n
[indices,p,labels]=split_node(X,Y,indices,p,labels,names_predicotrs,n+1);

% 0
[indices,p,labels]=split_node(X,Y,indices,p,labels,names_predicotrs,n+2);
% n+2
% 0







