


%坐标系： →x 坐标
% ↓ y 坐标
% 原点为(1,1)
%

clear;close all;clc;

I = im2double(rgb2gray(imread('houghorg.bmp')));
option=input(' Gaussian(1) or Salt(2):\n ');
if(option==1)
    I_noised=imnoise(I,'gaussian',1e-3);
else
    I_noised=imnoise(I,'salt & pepper',1e-3);
end


[height,width] = size(I_noised);
figure(1);
subplot(1,2,1),imshow(I);
title('Original');
subplot(1,2,2),imshow(I_noised);
title('Noised');

% Median Filtering
m=9;
I_smooth = medfilt2(I_noised,[m m]);% 9x9 中值滤波



% Edge Detection
% Roberts
IRoberts=edge(I_smooth,'Roberts');
figure(2);
subplot(1,3,1),imshow(IRoberts);
title('Roberts');
% Sobel
ISobel=edge(I_smooth,'Sobel');
subplot(1,3,2),imshow(ISobel);
title('Sobel');
% Laplacian
ILap=edge(I_smooth,'log');
subplot(1,3,3),imshow(ILap);
title('Laplacian');
suptitle('Edge Detection');


option=input(' Roberts(1) or Sobel(2) or Laplacian(3):\n ');
close all;
if(option==1)
    IEdge=IRoberts;
elseif(option==2)
    IEdge=ISobel;
else
    IEdge=ILap;
end
figure(3);
subplot(1,2,1),imshow(I_noised);
title('Original');
subplot(1,2,2),imshow(IEdge);
title('Edge Detection')
% 将边缘点坐标放在数组 X 和 Y 中，以便后续操作。
totalnum=sum(sum(IEdge));
X=zeros(1,totalnum);
Y=zeros(1,totalnum);
k=0;
for x=1:width
    for y=1:height
        if IEdge(y,x)% 是轨迹点  y（行） x（列）
            k=k+1;
            X(k)=x;
            Y(k)=y;
            if k==totalnum
                break;
            end
        end
    end
    if k==totalnum
        break;
    end
end

% Curve Detection by Hough
% assume that (x-a_0)^2+(y-b_0)^2=r^2
% parameter equation: (a-x_i)^2+(b-y_i)^2=r^2
% 坐标系： →x 坐标
% ↓ y 坐标
% 原点为(1,1)
fprintf(' \n 程序已发现 %d 个边缘轨迹点，对应 %d 个参数圆。 \n',totalnum,totalnum);
fprintf('\n 通过观察图像，我们可以缩小计算范围： \n');
fprintf(' 1、圆心位于(385,108)左右，圆心计算范围可缩小至附近 20x20 区域； \n');
fprintf(' 这样只需要统计 400 个点，计算量较小； \n');
apro_min=375;
bpro_min=98;
range=20;
APRO=(apro_min:apro_min+range-1)';
BPRO=(bpro_min:bpro_min+range-1)';
fprintf(' 2、半径长度在 88 左右，半径计算范围可缩小至 80:100。 \n');
r_min=80;
range2=20;
% fprintf('\n Program paused. Press enter to continue.\n');
% pause;
% 求解二元隐函数非常非常复杂。我们反过来，在 20x20 方阵内，逐点验证是否可能为参数圆的轨迹点。
% 误差 delta 可调，在正负 delta 内都算有效解。预实验建议值为 25。
% 预实验说明，当 delta 较小时，最大频次很小，统计误差很大。
delta=50;
r_step=0.5;
count=0;
A_Maxpro=[];
B_Maxpro=[];
RMAXNUM=[];
tic;
for r=r_min:r_step:r_min+range2 % 半径也取决于统计峰值
    count=count+1;
    Frequency=zeros(range,range);% 该 20x20 方阵点出现在参数圆轨迹中的次数
    for k=1:totalnum %逐个样本
        left=repmat(((APRO-X(k)).^2)',range,1)+repmat((BPRO-Y(k)).^2,1,range);
        right=r^2;
        Difference=round(left-right);
        ISSOLUTION=(Difference<delta & Difference>-delta);
        Frequency=Frequency+ISSOLUTION;
    end
    maxFrequency=max(Frequency(:));% 找出统计峰值
    [b_maxpro,a_maxpro]=find(Frequency==max(Frequency(:)));% 具有统计峰值，意味着该点最有可能是圆心(a_0,b_0)
    A_Maxpro=[A_Maxpro;a_maxpro];
    B_Maxpro=[B_Maxpro;b_maxpro];
    RMAXNUM=[RMAXNUM;maxFrequency];
    % 以上三者，记录的是在某一个 r 下的统计峰值和圆心坐标
end
final_max_Rposition=find(RMAXNUM==max(RMAXNUM));
R=r_min+(final_max_Rposition-1)*r_step;% 在所有 r 下的最大峰值对应的半径 r
final_a_pro=A_Maxpro(final_max_Rposition)+apro_min;
final_b_pro=B_Maxpro(final_max_Rposition)+bpro_min;
fprintf(' \n Hough 圆形边缘检测结果： Centre=(%d,%d)， Radius=%.1f。\n',final_a_pro,final_b_pro,R);
fprintf(' Hough 检测耗时： %.3f s。 \n', toc);


% Image Superposition
% Restruction
IRe=zeros(height,width);% 再次注意先行数后列数
delta2=1;
for m=1:height
    for n=1:width
        r_cal=sqrt((n-final_a_pro)^2+(m-final_b_pro)^2);
        if (r_cal<R+delta2 && r_cal>R-delta2)
            IRe(m,n)=1;
        end
    end
end
IRe=IRe+IEdge;
close all;
figure(4);
subplot(2,2,1),imshow(I);
title('Original');
subplot(2,2,2),imshow(I_noised);
title('Noised');
subplot(2,2,3),imshow(IEdge);
title('Edge Detected');
subplot(2,2,4),imshow(IRe);
title('Reconstructed');
