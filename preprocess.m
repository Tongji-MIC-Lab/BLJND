 clear all;
clc;
path = 'F:\寒假\寒假需要\block_level\';
path1 = [path,'source_imgs\'];
path2 = [path,'pred_labels\'];
path3 = [path,'blocks\'];
addpath(path);
addpath(path1);
addpath(path2);
addpath(path3);
target_qf = 47;
stride = 64; 
img = imread([path,'11.bmp']);
% imwrite(img,'5_23.jpg','quality',23);

%blk_classification_64{i} = blk_classification;

[blk_classification,num_pp, num_np, pp_loc, np_loc] = New_RMB(img);
% blk_classification_64{i} = blk_classification;
pred_list = load([path,'11_75.txt']);
raw_table = generate_qf(target_qf); %目标量化表

%---------------padding
[row,col,~]=size(img);
 rows = ceil(double(row/stride));
 cols = ceil(double(col/stride));
 source_img = zeros(rows*stride,cols*stride,3);
 source_img(1:row,1:col,1) = img(:,:,1);
 source_img(1:row,1:col,2) = img(:,:,2);
 source_img(1:row,1:col,3) = img(:,:,3);
 source_img = uint8(source_img);
 [row,col,~]=size(source_img);
 new_img = zeros(row,col,3);

%---------------departing Y
img_ycbcr = rgb2ycbcr(source_img); %RGB转YUV空间
Y(:,:)=img_ycbcr(:,:,1);  %Y分量
CB(:,:)=img_ycbcr(:,:,2);
CR(:,:)=img_ycbcr(:,:,3);
Z=Y; %亮度分量
Y=double(Y)-128; %亮度减少128

raw_dct = blkproc(Y,[8 8],'dct2');

%---------------8*8 block processing
for i=1:8:col-7
    for j = 1:8:row-7
        id_c = floor(i/stride)+1;
        id_r = floor(j/stride)+1;
        id = sub2ind([rows,cols],id_r,id_c);
        %qf_table(floor(j/8)+1,floor(i/8)+1) = pred_list(id);
        qf = pred_list(id); %预测的JND值
        QF_table = generate_qf(qf); %预测的JND值生成的量化表
        jnd_table(j:j+7,i:i+7) = QF_table; %JND量化表
        target_table_full(j:j+7,i:i+7) = raw_table;%目标QF量化
       
    end
end

Y_temp = round(raw_dct./double(jnd_table)); %JND量化表产生的量化系数
input_Y_dct_jnd = Y_temp.*double(jnd_table); %逆量化
input_Y_jnd  = blkproc(input_Y_dct_jnd,[8 8],'idct2');%逆变换
input_Y_jnd  = uint8(input_Y_jnd+128);%亮度值+128
input_Y_temp = round(raw_dct./double(target_table_full));%目标QF量化表产生的量化系数
input_Y_temp1 = input_Y_temp;
input_Y_dct_tar = input_Y_temp1.*double(target_table_full);
input_Y_dct = raw_dct;

for i= 1:row
    for j= 1:col
     if(blk_classification(i,j)==1)
          input_Y_dct(i,j)=input_Y_dct(i,j);
     else
       if(jnd_table(i,j)>target_table_full(i,j)) %JND值小于目标QF值
        if(Y_temp(i,j)==0)
            input_Y_dct(i,j)=0;
        else
            input_Y_dct(i,j)=input_Y_dct(i,j);
        end
       else 
            input_Y_dct(i,j)=input_Y_dct(i,j); 
       end
     end  
    end  
end
input_Y  = blkproc(input_Y_dct,[8 8],'idct2');
input_Y  = uint8(input_Y+128);

% imshow(Y);

%------------------add CB CR
YCbCr_in(:,:,1)=input_Y;
YCbCr_in(:,:,2)=CB;
YCbCr_in(:,:,3)=CR;

I=ycbcr2rgb(YCbCr_in);
%   imshow(I);
  imwrite(I,'11_75.jpg','quality',47);
%  imwrite(I,'1_30_1.bmp');

