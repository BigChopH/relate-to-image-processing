clear;close all;clc;

I = im2double(imread('Lena-512-grey.bmp'));% [0,1]
[M,~] = size(I);% square
% Display the original image.
figure(1);
subplot(1,3,1), imshow(I);
title('原始图像');


% Simulate a Motion Blur： H(u,v)
T=1;a=0.02;b=0.02;
v=[-M/2:M/2-1];u=v';
A=repmat(a.*u,1,M)+repmat(b.*v,M,1);
H=T/pi./A.*sin(pi.*A).*exp(-1i*pi.*A);
H(A==0)=T;% replace NAN


% Get the blurred Image
F=fftshift(fft2(I));
FBlurred=F.*H;
% Display the blurred image
IBlurred =real(ifft2(ifftshift(FBlurred)));
subplot(1,3,2), imshow(uint8(255.*mat2gray(IBlurred)));
title('运动模糊图像');


% Deblur perfectly without Noise
FDeblurred=FBlurred./H;
IDeblurred=real(ifft2(ifftshift(FDeblurred)));
subplot(1,3,3), imshow(uint8(255.*mat2gray(IDeblurred)));
title('无噪情况下直接逆滤波');


% Simulate Noise Model
noise_mean = 0;
noise_var = 1e-3;
noise=imnoise(zeros(M),'gaussian', noise_mean,noise_var);
FNoise=fftshift(fft2(noise));
% Get the Blurred_Noised Image
FBlurred_Noised=FNoise+FBlurred;
% Display the blurred_noised image
IBlurred_Noised=real(ifft2(ifftshift(FBlurred_Noised)));
figure(2);
subplot(1,3,1), imshow(uint8(255.*mat2gray(IBlurred_Noised)));
title('加噪运动模糊图像');


% Deblur when Ignoring Noise
FDeblurred2=FBlurred_Noised./H;
FH1=abs(FDeblurred2);
IDeblurred2=real(ifft2(ifftshift(FDeblurred2)));
subplot(1,3,2), imshow(uint8(255.*mat2gray(IDeblurred2)));
title ('有噪情况下直接逆滤波');


% Find out the best Radius
maxPSNR=0;
bestRadius=0;
tic;
for Radius=33:1e-2:34 
    FDeblurred2=zeros(M);
    for a=1:M
        for b=1:M
            if sqrt((a-M/2).^2+(b-M/2).^2)<Radius
                FDeblurred2(a,b)=FBlurred_Noised(a,b)./H(a,b);
            end
        end
    end

    IDeblurred2=real(ifft2(ifftshift(FDeblurred2)));
    PSNR=PSNRcal(IDeblurred2,I);
    if PSNR>maxPSNR
        maxPSNR=PSNR;
        bestRadius=Radius;
    end
end

% Displace the best Restoration
FDeblurred2=zeros(M);
for a=1:M
    for b=1:M
        if sqrt((a-M/2).^2+(b-M/2).^2)<bestRadius
            FDeblurred2(a,b)= FBlurred_Noised(a,b)./H(a,b);
        end
    end
end
FH2=abs(FDeblurred2);
IDeblurred2=real(ifft2(ifftshift(FDeblurred2)));
subplot(1,3,3), imshow(uint8(255.*mat2gray(IDeblurred2)));
title(['最佳半径为 ', num2str(bestRadius),'的圆内逆滤波']);

figure(3);
subplot(1,2,1),imshow(im2double(uint8(FH1)));
title ('有噪情况下直接逆滤波得到的图像频谱');
subplot(1,2,2),imshow(im2double(uint8(FH2)));
title ('圆内逆滤波得到的图像频谱');

% Deblur Image Using Wiener Filter



% Display the blurred_noised image again
figure(4);
subplot(1,3,1);
imshow(uint8(255.*mat2gray(IBlurred_Noised)));
title('加噪运动模糊图像');
% Deblur with theoretic NSR
buf=(abs(H)).^2; % Notice '.' !!!!!!!!
NSR=FNoise./F;
FDeblurred3=FBlurred_Noised./H.*buf./(buf+NSR);
IDeblurred3=real(ifft2(ifftshift(FDeblurred3)));
subplot(1,3,2), imshow(uint8(255.*mat2gray(IDeblurred3)));
title('K=NSR 的理论维纳滤波');
% Find out the best K
% tic;
% maxPSNR=0;
% beskK=0;
% for K=0:1e-2:1
% FDeblurred2=zeros(M);
% FDeblurred3=FBlurred_Noised./H.*buf./(buf+bestK);
% IDeblurred3=real(ifft2(ifftshift(FDeblurred3)));
%
% % Calculate PSNR and compare with the best
% PSNR=PSNRcal(IDeblurred3,I);
% if PSNR>maxPSNR
% maxPSNR=PSNR;
% bestK=K;
% end
% end
%
% fprintf(' 最佳 K 值: %.2f\n', bestK);
% fprintf(' 最大 PSNR: %d dB\n', round(maxPSNR));
% fprintf(' 寻找最佳 K 值耗时: %.1f s\n', toc);
% Deblur with best K
bestK=0.05;
FDeblurred3=FBlurred_Noised./H.*buf./(buf+bestK);
IDeblurred3=real(ifft2(ifftshift(FDeblurred3)));
% Display the best restored Image
subplot(1,3,3), imshow(uint8(255.*mat2gray(IDeblurred3)));
title(['}实际最佳 K= ', num2str(bestK),'的维纳滤波']);

