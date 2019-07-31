function PSNR=PSNRcal(I,IRE)
h=512;w=512;
B=8;% 编码一个像素用 8 个二进制位
MAX=2^B-1;% 图像有多少灰度级
MES=sum(sum((I-IRE).^2))/(h*w);% 均方差
PSNR=20*log10(MAX/sqrt(MES));% 峰值信噪比
end



%%%%%%%%%%%%%%%%%%%%%%%


