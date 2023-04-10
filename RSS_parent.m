
function [result]=RSS_parent(Y)

result=sum((Y-mean(Y)).^2);

end