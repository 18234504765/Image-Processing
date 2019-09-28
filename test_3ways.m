picture=imread('I:\A.jpg');
A1=picture(:,:,1);
A2=picture(:,:,2);
A3=picture(:,:,3);
A1=HF(A1);
A2=HF(A2);
A3=HF(A3);
% w = fspecial('average', 3);
% A1=imfilter(A1,w,'replicate');
% A2=imfilter(A2,w,'replicate');
% A3=imfilter(A3,w,'replicate');
picture_new=zeros(size(A1,1),size(A1,2),3);
picture_new(:,:,1)=A1;
picture_new(:,:,2)=A2;
picture_new(:,:,3)=A3;
subplot(2,1,1)
imshow(uint8(picture_new))
subplot(2,1,2)
imshow(picture)
function hist=count_hist(picture) %����ֱ��ͼ���������Ϊ�Ҷ�ֵ�����ؾ���Ϊֱ��ͼ
    Sum=zeros(2,256);%��һ�б�ʾ���ǳ��ֵĴ������ڶ��б�ʾ����0~255����256���Ҷ�ֵ
    for i=1:256
        Sum(2,i)=i-1;
    end   %�ڶ��еĳ�ʼ������
    for i=1:size(picture,1)
        for j=1:size(picture,2)
            Sum(1,picture(i,j)+1)=Sum(1,picture(i,j)+1)+1;%���ڻҶ�ͼ��ֵ��0~255��������Ϊ1~256������������ʱ����Ҫ���X(i��j)+1
        end
    end  %�Ե�һ�н��и�ֵ
    hist=Sum;
end

function [new_picture,new_hist]=hist_equal(picture,hist)%ֱ��ͼ���⻯
    Y=hist(1,:)/(size(picture,1)*size(picture,2));%���õ���ֱ��ͼ��ÿ���Ҷ�ֵ����Ӧ�ĸ���
    for i=2:length(hist(1,:))
        Y(i)=Y(i-1)+Y(i);      %�ⲿ���Ǳ�ɸ����ܶȺ��������ǽ��и��ʵ��ۼ�
    end   
    Y=Y*255;%���ԻҶ�ֵ255
    Y=round(Y);%ȡ��
    new_picture=ones(size(picture,1),size(picture,2));%�����µ�ͼ��
    for i=1:size(picture,1)
        for j=1:size(picture,2)
            new_picture(i,j)=Y(picture(i,j)+1);   %ͬ�������ڻҶ�ͼ��ֵ��0~255��������Ϊ1~256������������ʱ����Ҫ���picture(i��j)+1
        end
    end
    new_picture=uint8(new_picture);%��������ĵ���������double�У�imshow��ʱ����Ҫunit8�͵ı���
    new_hist=count_hist(new_picture);%���⻯���ֱ��ͼ
end

function FFT_picture=FFT(picture)  %�任�������Ļ�
    G1=zeros(size(picture,1),size(picture,1));   %ǰ�任����
    G2=zeros(size(picture,2),size(picture,2));   %��任����
    picture1=double(picture);   %��ͼ��uint8��ʽת����double�ͣ����ڽ��и������
    for i=1:size(picture,1)
        for j=1:size(picture,2)
            picture1(i,j)=picture1(i,j)*exp(complex(0,1)*2*pi*(i+j)/2);%��ԭͼ��������Ļ�Ԥ����
        end
    end
    for i=1:size(picture,1)   %ǰ�任����ĸ�ֵ
        for j=1:size(picture,1)
            G1(i,j)=exp(-complex(0,1)*2*pi*(i-1)*(j-1)/size(picture,1));
        end
    end
    for i=1:size(picture,2)   %��任����ĸ�ֵ
        for j=1:size(picture,2)
            G2(i,j)=exp(-complex(0,1)*pi*2*(i-1)*(j-1)/size(picture,2));
        end
    end
    FFT_picture=G1*picture1*G2;   %��ά����Ҷ�任���ҽ��������Ļ������ص��Ǹ����;���Ҫ���������ʾ...
                                  %��Ҫ�ڳ���������   imshow(log(abs(FFT_picture)+1),[])
end

function IFFT_picture=IFFT(f_picture)  %��任���������Ļ�
    G1=zeros(size(f_picture,1),size(f_picture,1));%ǰ�任����
    G2=zeros(size(f_picture,2),size(f_picture,2));%��任����
    for i=1:size(f_picture,1)   %ǰ�任���󸳳�ֵ
        for j=1:size(f_picture,1)
            G1(i,j)=exp(complex(0,1)*2*pi*(i-1)*(j-1)/size(f_picture,1))/size(f_picture,1);
        end
    end
    for i=1:size(f_picture,2)  %��任���󸳳�ֵ
        for j=1:size(f_picture,2)
            G2(i,j)=exp(complex(0,1)*pi*2*(i-1)*(j-1)/size(f_picture,2))/size(f_picture,2);
        end
    end
    IFFT_picture=G1*f_picture*G2;   %������任
    for i=1:size(f_picture,1)  %�����Ļ����������ʱ��ĵ��ľ����Ǹ�������
        for j=1:size(f_picture,2)
            IFFT_picture(i,j)=IFFT_picture(i,j)/exp(complex(0,1)*2*pi*(i+j)/2);
        end
    end
%     IFFT_picture=uint8(IFFT_picture);  %�任��uint8��ʽ������֮�������任��ͼ��
end

function HF_picture=HF(picture)
    picture=double(picture);%����ԭͼ�����double�������������и�������
    LN_picture=log(picture+1);%ȡ����
    LNF_picture=FFT(LN_picture);%���и���Ҷ���任
    m=size(picture,1);
    n=size(picture,2);
    H=zeros(m,n);
    D0=10;
    rh=2;
    rl=0.5;
    c=1;
    for i=1:m
        for j=1:n
            H(i,j)=(rh-rl)*(1-exp(-c*((i-m/2)^2+(j-n/2)^2))/D0^2)+rl;  %��˹�˲�����ʵ��
        end
    end
    HFLNF_picture=LNF_picture.*H;  %Ƶ���˲�
    IFFTHFLNF_picture=IFFT(HFLNF_picture);%����Ҷ��仯
    HF_picture=exp(IFFTHFLNF_picture)-1;%��ʱ��ȡָ�����������ȡ������ʱ��+1��ȡָ����ʱ����Ҫ���м�һ����
    HF_picture=uint8(HF_picture);%����ת��Ϊ��λ�޷�������uint8
end