 clear all;
clc;
path = 'F:\����\������Ҫ\block_level\';
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
raw_table = generate_qf(target_qf); %Ŀ��������

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
img_ycbcr = rgb2ycbcr(source_img); %RGBתYUV�ռ�
Y(:,:)=img_ycbcr(:,:,1);  %Y����
CB(:,:)=img_ycbcr(:,:,2);
CR(:,:)=img_ycbcr(:,:,3);
Z=Y; %���ȷ���
Y=double(Y)-128; %���ȼ���128

raw_dct = blkproc(Y,[8 8],'dct2');

%---------------8*8 block processing
for i=1:8:col-7
    for j = 1:8:row-7
        id_c = floor(i/stride)+1;
        id_r = floor(j/stride)+1;
        id = sub2ind([rows,cols],id_r,id_c);
        %qf_table(floor(j/8)+1,floor(i/8)+1) = pred_list(id);
        qf = pred_list(id); %Ԥ���JNDֵ
        QF_table = generate_qf(qf); %Ԥ���JNDֵ���ɵ�������
        jnd_table(j:j+7,i:i+7) = QF_table; %JND������
        target_table_full(j:j+7,i:i+7) = raw_table;%Ŀ��QF����
       
    end
end

Y_temp = round(raw_dct./double(jnd_table)); %JND���������������ϵ��
input_Y_dct_jnd = Y_temp.*double(jnd_table); %������
input_Y_jnd  = blkproc(input_Y_dct_jnd,[8 8],'idct2');%��任
input_Y_jnd  = uint8(input_Y_jnd+128);%����ֵ+128
input_Y_temp = round(raw_dct./double(target_table_full));%Ŀ��QF���������������ϵ��
input_Y_temp1 = input_Y_temp;
input_Y_dct_tar = input_Y_temp1.*double(target_table_full);
input_Y_dct = raw_dct;

for i= 1:row
    for j= 1:col
     if(blk_classification(i,j)==1)
          input_Y_dct(i,j)=input_Y_dct(i,j);
     else
       if(jnd_table(i,j)>target_table_full(i,j)) %JNDֵС��Ŀ��QFֵ
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

