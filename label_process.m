clear all;
clc;
path = 'F:\º®¼Ù\º®¼ÙÐèÒª\block_level\';
jnd  = load([path,'12.txt']);
la   = load([path,'la.txt']);

a = zeros(96,1);
for i = 1:1:96
    a(:,1) = jnd(:,1);
end

b = zeros(96,9);
 for i = 1:1:9
    b(:,i)=jnd(:,i+1);
 end

e = zeros(96,9);
for j = 1:1:96
    c = b(j,:);
    d = sort(c);
    e(j,:) = d;
end

f = zeros(96,9);
for i= 1:96
    for j= 1:9
        for k = 1:43
            if(e(i,j)==la(k,1))
                f(i,j)=la(k,2);
                break;
            end
        end
    end
end
 
g = zeros(96,1);
for i = 1:1:96
    for j = 9:-1:1
        if(f(i,j)<=30)
            g(i,1)= f(i,j);
            break;
        end
    end
end

 qf_pic = max(g);

for i =1:1:96
    if((qf_pic-g(i,1))>=qf_pic*(double(qf_pic)/100))
         g(i,1)= round(qf_pic -qf_pic*(double(qf_pic)/100));
    end
end

% xie txt
fid = fopen('12_30.txt','w');
for i = 1:1:96
   fprintf(fid,'%d\r\n',g(i,1));
end
fclose(fid);


