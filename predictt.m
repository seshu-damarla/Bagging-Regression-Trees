
function [result]=predictt(dataval,tree)

predictedy=tree.predy;
nodes=tree.nodes;
parent_feat_split=tree.parent_feat_split;

if numel(tree.leafnodes)==1
    result=predictedy(2);
else
    indices={dataval};
    for i=1:length(nodes)
    
        if i==1
            val_obs=double(indices{nodes(i)});
            feat=parent_feat_split(1,2);
            split=parent_feat_split(1,3);
    
            if val_obs(feat)<split
                indices=[indices;val_obs;0];
            else
                indices=[indices;0;val_obs];
            end
            indices{nodes(i)}=0;

        elseif i>1 && i<=length(nodes)
            if indices{nodes(i)}~=0
                idx=(nodes(i)==predictedy(:,1));
                    if sum(idx)==1
                        result=predictedy(idx,2); % given node is a leaf node
%                       nodes(i)
                        return
                    else
                        val_obs=double(indices{nodes(i)});
                        feat=parent_feat_split((nodes(i)==parent_feat_split(:,1)),2);
                        split=parent_feat_split((nodes(i)==parent_feat_split(:,1)),3);
                        if val_obs(feat)<split
                            indices=[indices;{val_obs};0];
                        else
                            indices=[indices;0;val_obs];
                        end
                    end
            else
            idx=(nodes(i)==predictedy(:,1));
                if sum(idx)==1
                    indices=indices;
                else
                    indices=[indices;0;0];
                end
            end
%             
        end
    end
end

                    
                
