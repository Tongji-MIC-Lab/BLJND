function [blk_classification, num_pp, num_np, pp_loc, np_loc] = New_RMB(img1)
% i = 31;
% img1 = imread(['E:\zxy\MATProjects\GetBlockJND\[BMP]\ImageJND_SRC',num2str(i,'%02d'),'.bmp']);
if size(img1,3)==3            % convert into grayscale
    img1=rgb2gray(img1);
end
% img1=im2double(img1);
% img = zeros(832,576);
% img(1:768,1:512) = img1;
[row,col]= size(img1);
img1=im2double(img1);
img = zeros(row+8,col+8);
img(1:row,1:col) = img1;
 img1 = img;
N=size(img1,1);
M=size(img1,2);
% Tx=TM_Kernel_Mukundan(8,7);  % x kernel
% Ty=TM_Kernel_Mukundan(8,7)'; % y kernel
a=fix(N/8);                  
b=fix(M/8);
h=a*b;
num_pp=0;
num_np=0;
pp_loc = [];
np_loc = [];
c=0.00000001;
for i=1:a-1;
    for j=1:b-1;
%         BK1=img1((i-1)*8+1:i*8+0,(j-1)*8+5:j*8+4);       %vertical block
%         BK2=img1((i-1)*8+5:i*8+4,(j-1)*8+1:j*8+0);       %horizontal block 
        BK3=img1((i-1)*8+1:i*8+0,(j-1)*8+1:j*8+0);
        E=sum(sum(BK3))/64;
        SSM=0;
        for u=1:8
            for v=1:8
                SSM=SSM+(BK3(u,v)-E)^2;      %SSM
            end
        end
%         if SSM<(5000/(255*255))   
        if SSM<(0.01)% smooth or textured
            num_pp=num_pp+1;
            pp_loc(num_pp,1) = i;
            pp_loc(num_pp,2) = j;%
            blk_classification(i*8-7:8*i,j*8-7:8*j) = 1;
        else
            num_np=num_np+1;
            np_loc(num_np,1) = i;
            np_loc(num_np,2) = j;
            blk_classification(i*8-7:8*i,j*8-7:8*j) = 0;
        end
    end
end
% imshow(blk_classification);
return
   
