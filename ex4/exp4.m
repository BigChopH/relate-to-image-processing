


%����ϵ�� ��x ����
% �� y ����
% ԭ��Ϊ(1,1)
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
I_smooth = medfilt2(I_noised,[m m]);% 9x9 ��ֵ�˲�



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
% ����Ե������������� X �� Y �У��Ա����������
totalnum=sum(sum(IEdge));
X=zeros(1,totalnum);
Y=zeros(1,totalnum);
k=0;
for x=1:width
    for y=1:height
        if IEdge(y,x)% �ǹ켣��  y���У� x���У�
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
% ����ϵ�� ��x ����
% �� y ����
% ԭ��Ϊ(1,1)
fprintf(' \n �����ѷ��� %d ����Ե�켣�㣬��Ӧ %d ������Բ�� \n',totalnum,totalnum);
fprintf('\n ͨ���۲�ͼ�����ǿ�����С���㷶Χ�� \n');
fprintf(' 1��Բ��λ��(385,108)���ң�Բ�ļ��㷶Χ����С������ 20x20 ���� \n');
fprintf(' ����ֻ��Ҫͳ�� 400 ���㣬��������С�� \n');
apro_min=375;
bpro_min=98;
range=20;
APRO=(apro_min:apro_min+range-1)';
BPRO=(bpro_min:bpro_min+range-1)';
fprintf(' 2���뾶������ 88 ���ң��뾶���㷶Χ����С�� 80:100�� \n');
r_min=80;
range2=20;
% fprintf('\n Program paused. Press enter to continue.\n');
% pause;
% ����Ԫ�������ǳ��ǳ����ӡ����Ƿ��������� 20x20 �����ڣ������֤�Ƿ����Ϊ����Բ�Ĺ켣�㡣
% ��� delta �ɵ��������� delta �ڶ�����Ч�⡣Ԥʵ�齨��ֵΪ 25��
% Ԥʵ��˵������ delta ��Сʱ�����Ƶ�κ�С��ͳ�����ܴ�
delta=50;
r_step=0.5;
count=0;
A_Maxpro=[];
B_Maxpro=[];
RMAXNUM=[];
tic;
for r=r_min:r_step:r_min+range2 % �뾶Ҳȡ����ͳ�Ʒ�ֵ
    count=count+1;
    Frequency=zeros(range,range);% �� 20x20 ���������ڲ���Բ�켣�еĴ���
    for k=1:totalnum %�������
        left=repmat(((APRO-X(k)).^2)',range,1)+repmat((BPRO-Y(k)).^2,1,range);
        right=r^2;
        Difference=round(left-right);
        ISSOLUTION=(Difference<delta & Difference>-delta);
        Frequency=Frequency+ISSOLUTION;
    end
    maxFrequency=max(Frequency(:));% �ҳ�ͳ�Ʒ�ֵ
    [b_maxpro,a_maxpro]=find(Frequency==max(Frequency(:)));% ����ͳ�Ʒ�ֵ����ζ�Ÿõ����п�����Բ��(a_0,b_0)
    A_Maxpro=[A_Maxpro;a_maxpro];
    B_Maxpro=[B_Maxpro;b_maxpro];
    RMAXNUM=[RMAXNUM;maxFrequency];
    % �������ߣ���¼������ĳһ�� r �µ�ͳ�Ʒ�ֵ��Բ������
end
final_max_Rposition=find(RMAXNUM==max(RMAXNUM));
R=r_min+(final_max_Rposition-1)*r_step;% ������ r �µ�����ֵ��Ӧ�İ뾶 r
final_a_pro=A_Maxpro(final_max_Rposition)+apro_min;
final_b_pro=B_Maxpro(final_max_Rposition)+bpro_min;
fprintf(' \n Hough Բ�α�Ե������� Centre=(%d,%d)�� Radius=%.1f��\n',final_a_pro,final_b_pro,R);
fprintf(' Hough ����ʱ�� %.3f s�� \n', toc);


% Image Superposition
% Restruction
IRe=zeros(height,width);% �ٴ�ע��������������
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
