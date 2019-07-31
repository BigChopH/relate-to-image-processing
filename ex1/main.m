clc
clear

LENA8=rgb2gray(imread('LENA512.bmp'));
th=0.95;
figure(1);
imshow(LENA8);
LENA=im2double(LENA8);

LENA_fft=fftshift(fft2(LENA));
LENA_dct=dct2(LENA);

H=hadamard(512);
LENA_hdm=H*LENA*H./512;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ÆµÆ×%%%%%%%%%%%%%%%%%%%%%%
F1=log(abs(LENA_fft)+1);
figure(2);
imshow(F1,[]);
title('FFTÆµÆ×');

figure(3);
F2=log(abs(LENA_dct)+1);
imshow(im2uint8(LENA_dct),[]);
title('DCTÆµÆ×');

figure(4);
F3=log(abs(LENA_hdm)+1);
imshow(im2uint8(LENA_hdm),[]);
title('HDMÆµÆ×');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%¼ÓÔë¸´Ô­%%%%%%%%%%%%%%%%%%%%
m=F1(:);
Threshold=findthreshold(m,th);
LENA_fft2=LENA_fft;
for i=1:512
    for j=1:512
        if F1(i,j)<Threshold
            LENA_fft2(i,j)=0;
        end
    end
end
LENA_fft_re=ifft2(ifftshift(LENA_fft2));
figure(5);
imshow(im2uint8(LENA_fft_re));
title('FFT¸´Ô­');


m=F2(:);
Threshold=findthreshold(m,th);
LENA_dct2=LENA_dct;
for i=1:512
    for j=1:512
        if F2(i,j)<Threshold
            LENA_dct2(i,j)=0;
        end
    end
end
LENA_dct_re=idct2(LENA_dct2);
figure(6);
imshow(im2uint8(LENA_fft_re));
title('DCT¸´Ô­');

m=F3(:);
Threshold=findthreshold(m,th);
LENA_hdm2=LENA_hdm;
for i=1:512
    for j=1:512
        if F3(i,j)<Threshold
            LENA_hdm2(i,j)=0;
        end
    end
end
figure(7);
LENA_hdm_re=H'*LENA_hdm2*H'./512;
imshow(im2uint8(LENA_hdm_re));
title('HDM»¹Ô­');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ÇóPSNR%%%%%%%%%%%%%%%%%%%%%%%%%
PSNR_fft=PSNRcal(LENA,LENA_fft_re);
PSNR_dct=PSNRcal(LENA,LENA_dct_re);
PSNR_hdm=PSNRcal(LENA,LENA_hdm_re);

%%


tPSNR=40;
for pt=0.940:0.005:0.995
m=F1(:);
Threshold=findthreshold(m,pt);
FRE=LENA_fft.*(F1>Threshold);
IRE = ifft2(ifftshift(FRE));
PSNR=PSNRcal(LENA,IRE);
if PSNR<tPSNR
pt=pt-0.005;
pt_fft=(1-pt)*100;

break;
end
end
%%
for pt=0.940:0.005:0.995
m=F2(:);
Threshold=findthreshold(m,pt);
DRE=LENA_dct.*(F2>Threshold);
IRE = idct2(DRE);
PSNR=PSNRcal(LENA,IRE);
if PSNR<tPSNR
pt=pt-0.005;
pt_dct=(1-pt)*100;

break;
end
end
%%
for pt=0.940:0.005:0.995
m=F3(:);
Threshold=findthreshold(m,pt);
HRE=LENA_hdm.*(F3>Threshold);
IRE = H'*LENA_hdm*H'./512;
PSNR=PSNRcal(LENA,IRE);
if PSNR<tPSNR
pt=pt-0.005;
pt_hdm=(1-pt)*100;

break;
end
end


