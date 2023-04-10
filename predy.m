
function [result,rss]=predy(Tree,Y)
rss=0;
predictedy=[];
for i=1:numel(Tree.p)
    % terminal node
    if ~isempty(Tree.indices{i})
        val=Y(Tree.indices{i});
        predictedy=[predictedy;[i mean(val)]];
        rss=rss+sum((val-mean(val)).^2);
    end
end
result=predictedy;
