
function result=Rss_child(Y,bin_val)

leftnode_Y=Y(bin_val==0);
rightnode_Y=Y(bin_val==1);

rss1=sum((leftnode_Y-mean(leftnode_Y)).^2);
rss2=sum((rightnode_Y-mean(rightnode_Y)).^2);

result=rss1+rss2;

end