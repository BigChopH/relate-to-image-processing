clear;close all;clc;


I = rgb2gray(im2double(imread('2.jpg')));% [0,1]
[M,N] = size(I);

% Median Filtering and OSTU
% different size of neighbourhood
A=[2,3,4,5];
for k=1:4
    m=A(k);
    Ismooth = medfilt2(I,[m m]);% 中值滤波
    Threshold = graythresh(Ismooth);% OSTU 的阈值
    Igray = imbinarize(Ismooth,Threshold);% OSTU 完成
    figure();
    subplot(1,3,1),imshow(I);
    title('原始图像');
    subplot(1,3,2),imshow(Ismooth);
    title(['中值滤波滑块面积: ', num2str(m),'*',num2str(m)]);
    subplot(1,3,3),imshow(Igray);
    title('大津算法分割图像');
end


bestm=input('\n Please input the chosen side length:\n ');

Ismooth = medfilt2(I,[bestm bestm]);% 中值滤波
Threshold = graythresh(Ismooth);
Igray = imbinarize(Ismooth,Threshold);



% Opening Operation
% circle with r=1,3,5
for r=[1,3,5]
    SE=strel('disk',r);
    Ierode=imerode(Igray,SE);
    Idilate=imdilate(Ierode,SE);
    figure();
    subplot(1,2,1),imshow(Igray);
    title('\fontsize{20}开运算前');
    subplot(1,2,2),imshow(Idilate);
    title(['\fontsize{20}开运算后 圆半径为： ',num2str(r)]);
end


bestr=input('\n please input the chosen radius:\n ');

SE=strel('disk',bestr);
Ierode=imerode(Igray,SE);
Idilate=imdilate(Ierode,SE);
figure();
subplot(1,3,1),imshow(I);
title('原始图像');
subplot(1,3,2),imshow(Igray);
title('中值滤波和大津分割后图像');
subplot(1,3,3),imshow(Idilate);
title(['开运算后图像 圆半径为： ',num2str(bestr)]);


% Closing Operation
SE=strel('disk',bestr);
Idilate2=imdilate(Idilate,SE);
Ierode2=imerode(Idilate2,SE);
close;
figure();
subplot(2,2,1),imshow(I);
title('原始图像');
subplot(2,2,2),imshow(Igray);
title('中值滤波和大津分割后图像');
subplot(2,2,3),imshow(Idilate);
title('开运算后图像');
subplot(2,2,4),imshow(Ierode2);
title('闭运算后图像');


