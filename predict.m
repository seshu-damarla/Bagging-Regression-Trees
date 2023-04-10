
function [result]=predict(dataval)

global parent_feat_split nodes predictedy

samples=[1:1:length(nodes)];
idx_R=samples(nodes==3);
nodesL=nodes(1:idx_R-1); % nodes in left branch
nodesR=nodes(idx_R:end); % nodes in right branch

indices={dataval};

% root node
val_obs=double(indices{nodes(1)});
feat=parent_feat_split(1,2);
split=parent_feat_split(1,3);
    
if val_obs(feat)<split
   indices=[indices;val_obs;0];
   Nodes=nodesL;
   leftbranch='yes';
else
   indices=[indices;0;val_obs];
   Nodes=nodesR;
   leftbranch='no';
end
indices{nodes(1)}=0;
        
if strcmp(leftbranch,'yes')
    for i=2:length(Nodes)
        if indices{Nodes(i)}~=0
            idx=(Nodes(i)==predictedy(:,1));
                if sum(idx)==1
                    result=predictedy(idx,2); % given node is a leaf node
%                     nodes(i)
                    return
                else
                    val_obs=double(indices{Nodes(i)});
                    feat=parent_feat_split((Nodes(i)==parent_feat_split(:,1)),2);
                    split=parent_feat_split((Nodes(i)==parent_feat_split(:,1)),3);
                    if val_obs(feat)<split
                        indices=[indices;{val_obs};0];
                    else
                        indices=[indices;0;val_obs];
                    end
                end
        else
            idx=(Nodes(i)==predictedy(:,1));
                if sum(idx)==1
                    indices=indices;
                else
                    indices=[indices;0;0];
                end
        end
    end
else
    for i=1:length(Nodes)
        if indices{Nodes(i)}~=0
            idx=(Nodes(i)==predictedy(:,1));
                if sum(idx)==1
                    result=predictedy(idx,2); % given node is a leaf node
%                     nodes(i)
                    return
                else
                    val_obs=double(indices{Nodes(i)});
                    feat=parent_feat_split((Nodes(i)==parent_feat_split(:,1)),2);
                    split=parent_feat_split((Nodes(i)==parent_feat_split(:,1)),3);
                    if val_obs(feat)<split
                        indices=[indices;{val_obs};0];
                    else
                        indices=[indices;0;val_obs];
                    end
                end
        else
            idx=(Nodes(i)==predictedy(:,1));
                if sum(idx)==1
                    indices=indices;
                else
                    indices=[indices;0;0];
                end
        end
    end
end

                    
                
