
%dvenugopalarao%

function S=oobsamples(bootsample,N)

% N-actual number of samples in the original training set

x=bootsample;

S=[];
for i=1:1:N
    if sum(x==i)==0
        S=[S;[i]];
    end
end

end
