function PSNR=PSNRcal(I,IRE)
h=512;w=512;
B=8;% ����һ�������� 8 ��������λ
MAX=2^B-1;% ͼ���ж��ٻҶȼ�
MES=sum(sum((I-IRE).^2))/(h*w);% ������
PSNR=20*log10(MAX/sqrt(MES));% ��ֵ�����
end



%%%%%%%%%%%%%%%%%%%%%%%


