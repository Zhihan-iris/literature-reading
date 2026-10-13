dataset=csvread('Pre_Matching_Relation.csv',1,0);
N=sum(dataset(:,2)); % Related Firms to Match Controls
max_matching=1;
result=zeros(N*max_matching,4);
x=0;
for i=1:1:N
    dis=data_distance(dataset(i,:),dataset);
    n=min(max_matching,size(dis,1));
    dis_m=dis(1:n,:);
    result(x+1:(x+n),:)=[repmat(dataset(i,1),n,1),dataset(dis_m(:,1),1),dis_m(:,2:3)];
    x=x+n;
end
result=result(1:x,:);
dlmwrite('Matching_Result_Relation.csv',result,'precision','%10d');

function dis=data_distance(veca,matb)
normX=sqrt(veca(4:end).^2*(veca(4:end)~=-1).');
flags=ones(size(matb,1),1);
flags=flags & (matb(:,2)~=veca(2)); % Different Treat Status
flags=flags & (matb(:,3)==veca(3)); % Same 4-digit Industry
flags=flags & (sum(bsxfun(@ne,matb(:,4:end)==-1,veca(4:end)==-1),2)==0); % Same Year Appearance

result=sqrt(...
            sum(...
                bsxfun(@minus,matb(flags,4:end),veca(4:end)).^2,2)...
            ); % Euclidean Distance

dis=sortrows([find(flags),result,result/normX],2);

end