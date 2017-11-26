f4=imread('1.jpg');     %��ȡͼ�� 
 imshow(f4);
a=rgb2gray(f4);          %����ɫͼ��ת���ɻҶ�ͼ��
a_size = size(a);
b = ones(a_size);

for i =1:a_size(1)%ȥ���߿�
    for j = 1:a_size(2)
        if a(i,j)>=0 && a(i,j)<=50
            
            b(i,j)=0;
        end
    end
end

 B =[1 1 1 1;1 1 1 1;1 1 1 1;1 1 1 1];  %�����Ե��ȣ�����һ����Ҫע��ĵط�
  b = imerode(b,B);
for i =1:a_size(1)
    for j = 1:a_size(2)
        if  b(i,j)==0
            a(i,j)=255;
        end
    end
end

bw=edge(a,'prewitt');%��Ե���   ��Ե���������ֻ�����һЩ������С�㣬��������û���γɱպϵ�����
[L,num] = bwlabel(bw);%ȡ����ͨ��    

%�����Ѿ���ÿ�������ú��ˣ�ʹ��bwlabel�Ļ���ѹ����Ĳ��ɱպ����ߵĵ�Ҳ���ȥ
%һЩ����������������ǱȽ��ٵģ����Կ���ͨ�����ÿһ����������ص��С�������ǲ���Ҫɾ�������ؿ�
for i= 1:num    %ȥ��
        [r,c]=find(L==i);
        size_L = size([r,c]);
        if size_L(1,1)<30
            L(r,c)=0;
        end
end
L = logical(L);%��һ�������㴦��

se = strel('disk',4);   %ƽ��ͼ�Σ�����Բ��
L = imclose(L,se);    %�մ��������ͣ���ʴ
[L,num1] = bwlabel(L);%ƽ�������ͨ��
L = rot90(L,3);
L = fliplr(L);%ת��
pixel = cell([num1,1]);%�����վ���
centre = zeros(num1,2);%����
size_L = size(L);%��������
for i=1:num1
    [r,c]=find(L==i);%Ѱ����ͨ��
%     points=edgetrack(L);
%     figure,imshow(L(points));
    pixel{i} = [r,c]; 
    
    hold on
    mean_pixel = mean(pixel{i});%��������
    centre(i,:) = mean_pixel;   %��¼����      
    plot(mean_pixel(1,1),mean_pixel(1,2),'r*');%��������
    size_r = size(r);
    distance = zeros(size_r);
    for j = 1:1:size_r(1)
            distance(j) = sqrt((r(j)-mean_pixel(1))^2 + (c(j)-mean_pixel(2))^2); %�������ͼ�α�Ե�������ĵĳ���
    end
    p=polyfit((1:size_r(1))',distance,7);
    x = (1:size_r(1))';
    y = p(1)*x.^7 + p(2)*x.^6 + p(3)*x.^5 + p(4)*x.^4 + p(5)*x.^3 + p(6)*x.^2 + p(7)*x.^1 + p(8);  %������Ϻ���
            
    min_distance = min(distance);
    max_distance = max(distance);
    min_y        =  min(y);
    max_y        =  max(y);
    num_peaks    =  size(findpeaks(-y));

%     ��Сֵ
%���ݼ�Сֵ�ж���״
    if (max_distance - min_distance)<= 15 && (max_y - min_y) <= 15%����Ե�����ľ������ʱ��ΪԲ
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('Բ��  %d',i))
    elseif num_peaks(1) == 2%��2�����壬Ϊ������
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('������  %d',i))    
    else%��������Ϊ����
        %Ҳ����д��num_peaks(1)==3ʱ��Ϊ����
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('����  %d',i))
    end    
end
