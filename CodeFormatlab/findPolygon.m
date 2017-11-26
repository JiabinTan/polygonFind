f4=imread('2.jpg');     %��ȡͼ�� 
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
     points=edgetrack(L,i);
     r=points(:,1);
     c=points(:,2);
    pixel{i} = [r,c]; 
%     for k=1:size(r)/10
%         figure(1),hold on, plot(r(k*10),c(k*10),'b*');text(r(k*10),c(k*10),sprintf('%d',k));
%     end
    hold on
    mean_pixel = mean(pixel{i});%��������
    centre(i,:) = mean_pixel;   %��¼����      
   figure(1),hold on, plot(mean_pixel(1,1),mean_pixel(1,2),'b*');%��������
    size_r = size(r);
    distance = zeros(size_r);
    for j = 1:1:size_r(1)
            distance(j) = sqrt((r(j)-mean_pixel(1))^2 + (c(j)-mean_pixel(2))^2); %�������ͼ�α�Ե�������ĵĳ���
    end

    p=polyfit((1:size_r(1))',distance,12);
    
    x = (1:size_r(1))';
    y = p(1)*x.^12 + p(2)*x.^11 + p(3)*x.^10 + p(4)*x.^9 + p(5)*x.^8 + p(6)*x.^7 + p(7)*x.^6+p(8)*x.^5 + p(9)*x.^4+ p(10)*x.^3 + p(11)*x.^2 + p(12)*x.^1 + p(13);  %������Ϻ���
            
    min_distance = min(distance);
    max_distance = max(distance);
    min_y        =  min(y);
    max_y        =  max(y);
    num_peaks    =  size(findpeaks(-y));
%     figure,plot(1:size_r(1),distance);
%     figure,plot(x,-y);
%     findpeaks(-y);
%     ��Сֵ
%���ݼ�Сֵ�ж���״
    if (max_distance - min_distance)<= 15 && (max_y - min_y) <= 15%����Ե�����ľ������ʱ��ΪԲ
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('Բ��  %d',i))
    elseif num_peaks(1) == 3%��3�����壬Ϊ������
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('������  %d',i))    
    elseif num_peaks(1)==4%��������Ϊ����
        %Ҳ����д��num_peaks(1)==3ʱ��Ϊ����
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('����  %d',i))
    end    
end
function points=edgetrack(edgeIm,num)
[i, j] = find(edgeIm==num);
[row,col]=size(edgeIm);
%��������
numPoints = size(i, 1);
curNum = 0;

%��ʼ����������
currentR = i(1, 1);
currentC = j(1, 1);

%��ʼ������������
% points = zeros(numPoints, 2);

%��ʼ����
curNum = curNum + 1;
points(curNum,:) = [currentR, currentC];
edgeIm(currentR, currentC) = 0;
while curNum ~= numPoints

 if(curNum==335)
            a=1;
            end
        if currentC-1>0&&edgeIm(currentR, currentC-1)== num
             curNum = curNum + 1;
             currentC = currentC - 1;
             points(curNum,:) = [currentR, currentC];
             edgeIm(currentR, currentC) = 0;

             elseif currentC-1>0&&currentR-1>0&&edgeIm(currentR-1, currentC-1)== num
                curNum = curNum + 1;
                 currentR = currentR - 1;
                 currentC = currentC - 1;
                 points(curNum,:) = [currentR, currentC];
                 edgeIm(currentR, currentC) = 0;

             elseif currentR-1>0&&edgeIm(currentR-1, currentC)== num
                 curNum = curNum + 1;
                currentR = currentR - 1;
                 points(curNum,:) = [currentR, currentC];
                edgeIm(currentR, currentC) = 0;

             elseif currentR-1>0&&currentC+1<=col&&edgeIm(currentR-1, currentC+1)== num
                 curNum = curNum + 1;
                 currentR = currentR - 1;
                 currentC = currentC + 1;
                 points(curNum,:) = [currentR, currentC];
                edgeIm(currentR, currentC) = 0;
            elseif currentC+1<=col&&edgeIm(currentR, currentC+1)== num
                curNum = curNum + 1;
                currentC = currentC + 1;
                 points(curNum,:) = [currentR, currentC];
                 edgeIm(currentR, currentC) = 0;

            elseif currentC+1<=col&&currentR+1<=row&&edgeIm(currentR+1, currentC+1)== num
                curNum = curNum + 1;
                currentR = currentR + 1;
                currentC = currentC + 1;
                 points(curNum,:) = [currentR, currentC];
                 edgeIm(currentR, currentC) = 0;

             elseif currentR+1<=row&&edgeIm(currentR+1, currentC)== num
                 curNum = curNum + 1;
                 currentR = currentR + 1;
                 points(curNum,:) = [currentR, currentC];
                 edgeIm(currentR, currentC) = 0;

             elseif currentR+1<=row&&currentC-1>0&&edgeIm(currentR+1, currentC-1)== num
                 curNum = curNum + 1;
                currentR = currentR + 1;
                currentC = currentC - 1;
                points(curNum,:) = [currentR, currentC];
                 edgeIm(currentR, currentC) = 0;
        elseif numPoints-curNum>14
           
            Lt=currentR-15;
            Lb=currentR+15;
            Cl=currentC-15;
            Cr=currentC+15;
            if currentR<15
                Lt=0;
            elseif row-currentR<15
                Lb=row;
                
            end
            if currentC<15
                Cl=0;
                
            elseif col-currentC<15
                Cr=col;
                
            end
            A=edgeIm([Lt:Lb],[Cl:Cr]);
            [Ar,Ac]=find(A==num);
            k=size(Ar);
            if k(1,1)==0||k(1,2)==0
                break;
            end
            A=(Ar-16).^2+(Ac-16).^2;
            [data,Arow]=min(A);
            currentR=currentR+Ar(Arow)-16;
            currentC=currentC+Ac(Arow)-16;
            curNum=curNum+1;
            points(curNum,:) = [currentR, currentC];
            edgeIm(currentR, currentC) = 0;
        else break;
        end
end
end