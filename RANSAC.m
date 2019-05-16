clear all;
I = imread('road.png');

%find gradientX and gradientY
[gradientX,gradientY]= sobel1(I);

%using hessian determinate for line fitting
d=detNonmax(gradientX,gradientY);
RANSAC(d,I);
Hough(d,I,40);


%using gradient for line fitting
a=nonmax(gradientX,gradientY);
RANSAC(a,I);
Hough(a,I,80);


%gaussian and sobel
function [gradientX,gradientY]=sobel1(I)
sigma = 1;       
N = 7;            
N_row = 2*N+1; 
H = [];                                        
for i=1:N_row  
    for j=1:N_row  
        fenzi=double((i-N-1)^2+(j-N-1)^2);  
        H(i,j)=exp(-fenzi/(2*sigma*sigma))/(2*pi*sigma*sigma);  
    end  
end  
H=H/sum(H(:));   
Gaussian= conv2(I, H,'same');

d=Gaussian;
sobelX = [1 0 -1 ; 2 0 -2; 1 0 -1];
sobelY = [1 2 1 ; 0 0 0 ; -1 -2 -1] ;
gradientX = conv2(d, sobelX,'same');
gradientY = conv2(d, sobelY,'same');
end


%non_max(3X3) for hessian determinate
function d=detNonmax(gradientX,gradientY)
sobelX = [1 0 -1 ; 2 0 -2; 1 0 -1];
sobelY = [1 2 1 ; 0 0 0 ; -1 -2 -1] ;
Ixx = conv2(gradientX, sobelX,'same');
Iyy = conv2(gradientY,sobelY,'same');
Ixy = conv2(gradientX, sobelY,'same');
det = Ixx.*Iyy-(Ixy).^2;

direction = atan2(gradientY,gradientX);
direction = (180*direction/pi)+180;

d=det;
[dm,dn]=size(d);
for i=2:dm-1
    for j=2:dn-1
        if d(i,j)~=0
             if(-22.5<direction(i,j) && direction(i,j)<=22.5)%vertical
                if(d(i,j+1)>d(i,j)) || (d(i,j-1)>d(i,j))||(d(i+1,j)>d(i,j))||(d(i-1,j)>d(i,j))||(d(i+1,j+1)>d(i,j))||(d(i-1,j-1)>d(i,j))||(d(i-1,j+1)>d(i,j))||(d(i+1,j-1)>d(i,j))
                    d(i,j) = 0;
                end
            
             elseif (22.5<direction(i,j) && direction(i,j)<=67.5) %diagonal
                if(d(i,j+1)>d(i,j)) || (d(i,j-1)>d(i,j))||(d(i+1,j)>d(i,j))||(d(i-1,j)>d(i,j))||(d(i+1,j+1)>d(i,j))||(d(i-1,j-1)>d(i,j))||(d(i-1,j+1)>d(i,j))||(d(i+1,j-1)>d(i,j))
                    d(i,j) = 0;
                end
        
             elseif (abs(direction(i,j))>67.5) %horizontal
                 if(d(i,j+1)>d(i,j)) || (d(i,j-1)>d(i,j))||(d(i+1,j)>d(i,j))||(d(i-1,j)>d(i,j))||(d(i+1,j+1)>d(i,j))||(d(i-1,j-1)>d(i,j))||(d(i-1,j+1)>d(i,j))||(d(i+1,j-1)>d(i,j))
                    d(i,j)=0;
                 end   
                
             elseif (-67.5<direction(i,j) && direction(i,j)<=-22.5) %diagonal
                    if(d(i,j+1)>d(i,j)) || (d(i,j-1)>d(i,j))||(d(i+1,j)>d(i,j))||(d(i-1,j)>d(i,j))||(d(i+1,j+1)>d(i,j))||(d(i-1,j-1)>d(i,j))||(d(i-1,j+1)>d(i,j))||(d(i+1,j-1)>d(i,j))
                    d(i,j)=0;
                    end
             end
        end
    end
end
%threshold
d=d>1000;
end

%nonmax for gradient
function d=nonmax(gradientX,gradientY)
gradient = sqrt(gradientX.^2 + gradientY.^2);
direction = atan2(gradientY,gradientX);
direction = (180*direction/pi)+180;
d=gradient;
[dm,dn]=size(gradient);
for i=2:dm-1
    for j=2:dn-1
        if d(i,j)~=0
             if(-22.5<direction(i,j) && direction(i,j)<=22.5)%vertical
                if(d(i,j+1)>d(i,j)) || (d(i,j-1)>d(i,j))
                    d(i,j) = 0;
                end
            
             elseif (22.5<direction(i,j) && direction(i,j)<=67.5) %diagonal
                if(d(i-1,j+1)>d(i,j)) || (d(i+1,j-1)>d(i,j))
                    d(i,j) = 0;
                end
        
             elseif (abs(direction(i,j))>67.5) %horizontal
                 if (d(i-1,j)>d(i,j)) ||(d(i+1,j)>d(i,j))
                    d(i,j)=0;
                 end   
                
             elseif (-67.5<direction(i,j) && direction(i,j)<=-22.5) %diagonal
                    if (d(i-1,j-1)>d(i,j)) ||(d(i+1,j+1)>d(i,j))
                    d(i,j)=0;
                    end
            end
        end
    end
end
%threshold
d=d>120;
end


%Hought transformation ('th' is threshold value)
function Hough(d,I,th)

[row,col] = size(d);

pg = round((row*row+col*col)^0.5); %size of hough space

%creat hough space
H=zeros(2*pg,180);  
for m=2:row-1
    for n=2:col-1
        if d(m,n)>0
            for theta =1:180
                r=theta/180*pi;
                rho=round(m*cos(r)+n*sin(r));
                rho=rho+pg+1;
                H(rho,theta)=H(rho,theta)+1;
            end
        end
    end
end

%transform back to image space
[rho,theta]=find(H>th);   %find the points greater than the threshold value

figure,imshow(I), hold on
for i=1:5
    y=1:row;
    r=theta(i)/180*pi;
    x=(rho(i)-pg-y*cos(r))/sin(r);
    plot(x,y,'r');
end
title('Hough');
end


%RANSAC line fitting
function RANSAC(d,I)
[x,y]=size(d);
points=[];
count=1; %count number of points

%creat the points space 
for n=2:x-1
    for m=2:y-1
        if d(n,m)==1
            points(count,1)=m;
            points(count,2)=n;
            count=count+1;
        end
    end
end


bestLine=[];  %best model with two points
bestCount=0;  %count the inliers of the best model
lpointList=[];   %inliers of best model
threshold=3;
figure,imshow(I), hold on
runtime = 5; %find different lines in 6 times runing RANSAC

times=10; %run 10 times to find best line
for u=0:runtime
%randomly choose two points
for i=1:times
    index1=randi(count,1);
    index2=randi(count,1);
    point1=points(index1,:);
    point2=points(index2,:);
   
    line=[point1;point2];
    countIndex=0;
    poinList=[];
    
    %creat a vector of two points
    if point1 ~= point2
        vector1 = point2-point1;
        vector1=vector1./norm(vector1);
        vector1=[vector1(2), -vector1(1)];
        
        %compute the distance between the point and the vector
        for j =1 :size(points)
            vector2=points(j,:)-point1;
            distance = abs(dot(vector2,vector1));
            if(distance<threshold)
                countIndex=countIndex+1;
                poinList(countIndex,:)=points(j,:);
            end
        end
    end
    
    %find the line has most inliers
    if(countIndex>bestCount)
        bestCount=countIndex;
        bestLine=line;
        lpointList=poinList;
    end
end

%plot the inliers of the best model
for i=1:size(lpointList)
  plot(lpointList(i,1),lpointList(i,2),'x' );
end

%plot the line of the best model
  x1=0:548;
  py1=bestLine(1,2);
  px1=bestLine(1,1);
  py2=bestLine(2,2);
  px2=bestLine(2,1);
  a=(py1-py2)/(px1-px2);
  b=py1-a*px1;
  y1=a*x1+b;
  plot(x1,y1,'r');
end
  title('RANSAC');

  end