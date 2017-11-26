f4=imread('2.jpg');     %读取图像 
 imshow(f4);
a=rgb2gray(f4);          %将彩色图像转换成灰度图像
a_size = size(a);
b = ones(a_size);

for i =1:a_size(1)%去掉边框
    for j = 1:a_size(2)
        if a(i,j)>=0 && a(i,j)<=50
            
            b(i,j)=0;
        end
    end
end

 B =[1 1 1 1;1 1 1 1;1 1 1 1;1 1 1 1];  %扩大边缘宽度，这是一个需要注意的地方
  b = imerode(b,B);
for i =1:a_size(1)
    for j = 1:a_size(2)
        if  b(i,j)==0
            a(i,j)=255;
        end
    end
end

bw=edge(a,'prewitt');%边缘检测   边缘检测结束后发现还是有一些鼓励的小点，不多它们没有形成闭合的曲线
[L,num] = bwlabel(bw);%取得联通块    

%这里已经给每个区域标好号了，使用bwlabel的话会把鼓励的不成闭合曲线的点也算进去
%一些独立点的像素数量是比较少的，所以可以通过检测每一块区域的像素点大小来决定是不是要删除此像素块
for i= 1:num    %去噪
        [r,c]=find(L==i);
        size_L = size([r,c]);
        if size_L(1,1)<30
            L(r,c)=0;
        end
end
L = logical(L);%单一化，方便处理

se = strel('disk',4);   %平滑图形，补足圆形
L = imclose(L,se);    %闭处理，先膨胀，后腐蚀
[L,num1] = bwlabel(L);%平滑后的联通块
L = rot90(L,3);
L = fliplr(L);%转置
pixel = cell([num1,1]);%产生空矩阵
centre = zeros(num1,2);%质心
size_L = size(L);%行列向量
for i=1:num1
    [r,c]=find(L==i);%寻找联通块
     points=edgetrack(L,i);
     r=points(:,1);
     c=points(:,2);
    pixel{i} = [r,c]; 
%     for k=1:size(r)/10
%         figure(1),hold on, plot(r(k*10),c(k*10),'b*');text(r(k*10),c(k*10),sprintf('%d',k));
%     end
    hold on
    mean_pixel = mean(pixel{i});%质心坐标
    centre(i,:) = mean_pixel;   %记录质心      
   figure(1),hold on, plot(mean_pixel(1,1),mean_pixel(1,2),'b*');%画出质心
    size_r = size(r);
    distance = zeros(size_r);
    for j = 1:1:size_r(1)
            distance(j) = sqrt((r(j)-mean_pixel(1))^2 + (c(j)-mean_pixel(2))^2); %算出各个图形边缘距离质心的长度
    end

    p=polyfit((1:size_r(1))',distance,12);
    
    x = (1:size_r(1))';
    y = p(1)*x.^12 + p(2)*x.^11 + p(3)*x.^10 + p(4)*x.^9 + p(5)*x.^8 + p(6)*x.^7 + p(7)*x.^6+p(8)*x.^5 + p(9)*x.^4+ p(10)*x.^3 + p(11)*x.^2 + p(12)*x.^1 + p(13);  %产生拟合函数
            
    min_distance = min(distance);
    max_distance = max(distance);
    min_y        =  min(y);
    max_y        =  max(y);
    num_peaks    =  size(findpeaks(-y));
%     figure,plot(1:size_r(1),distance);
%     figure,plot(x,-y);
%     findpeaks(-y);
%     求极小值
%根据极小值判断形状
    if (max_distance - min_distance)<= 15 && (max_y - min_y) <= 15%当边缘与质心距离相等时，为圆
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('圆形  %d',i))
    elseif num_peaks(1) == 3%有3个波峰，为三角形
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('三角形  %d',i))    
    elseif num_peaks(1)==4%三个波峰为矩形
        %也可以写成num_peaks(1)==3时，为矩形
        text(mean_pixel(1,1),mean_pixel(1,2),sprintf('矩形  %d',i))
    end    
end
function points=edgetrack(edgeIm,num)
[i, j] = find(edgeIm==num);
[row,col]=size(edgeIm);
%轮廓点数
numPoints = size(i, 1);
curNum = 0;

%初始搜索点坐标
currentR = i(1, 1);
currentC = j(1, 1);

%初始化轮廓点坐标
% points = zeros(numPoints, 2);

%开始搜索
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