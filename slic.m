clear all;
im = imread('wt_slic.png');
im = double(im);

%split the image to 150 windows with 50X50 size
D = 50*ones(1,10);
E = 50*ones(1,15);
C = mat2cell(im,D,E,3);

%create array contains x/2 y/2 R G B
r= im(:,:,1);
g= im(:,:,2);
b= im(:,:,3);
[g1,g2] = find(g(:,:) == g(:,:));
array1= [r(:),g(:),b(:)];
array = [g1(:)/2,g2(:)/2,r(:),g(:),b(:)];

%length of array
len = length(array);
%150 windows
k=150;

%create a array to store the distance and center for each pixel k+1 will be
%the center and k+2 be the distances
dal = zeros(size(array,1),k+2);


%Set the center of each 50X50 windows and find the magitude for each pixels
for i = 1:10
    for j= 1:15
        s=cell2mat(C(i,j));
        cen{i,j}= [randperm(45,1)+3,randperm(45,1)+3];
        [rg,rd]=imgradient(s(:,:,1));
        [gg,gd]=imgradient(s(:,:,2));
        [bg,bd]=imgradient(s(:,:,3));
         grandir = rg;
         grandig = gg;
         grandib = bg;
         grandArray{i,j} = [rg(:),gg(:),bg(:)];
         finalmag{i,j} = sqrt(sqrt(rg) + sqrt(gg) + sqrt(bg));
    end
end

%literate
iter = 3;
%compare the magtitude and update the center
for time =1:iter
for m=1:10
    for n=1:15
        center = cen{m,n};
        magMatrix = finalmag{m,n};
        x=center(1,1);
        y=center(1,2);
        
        %compare the magtitud in 3X3 window
        preCenter(x,y) = magMatrix(x,y);
        preCenter(x+1,y) = magMatrix(x+1,y);
        preCenter(x-1,y) = magMatrix(x-1,y);
        preCenter(x,y+1) = magMatrix(x,y+1);
        preCenter(x,y-1) = magMatrix(x,y-1);
        preCenter(x-1,y+1) = magMatrix(x-1,y+1);
        preCenter(x+1,y-1) = magMatrix(x+1,y-1);
        preCenter(x+1,y+1) = magMatrix(x+1,y+1);
        preCenter(x-1,y-1) = magMatrix(x-1,y-1);
        
        min1=min(preCenter(preCenter>0));
        
        [k1,k2] = find(preCenter(:,:)==min1);
        
        q= [k1,k2];
        cen{m,n} = [q(1,1),q(1,2)];
    end
end
end


o=1;
for m1=1:10
    for n1=1:15
        s=cen{m1,n1};
        %convert the coordinate to 500X750 window
        s(1,1) = s(1,1) + ((m1-1)*50);
        s(1,2) = s(1,2) + ((n1-1)*50);
        cen{m1,n1} = s;
        sx=s(1,1);
        sy=s(1,2);
        red = r(sx,sy);
        green = g(sx,sy);
        blue = b(sx,sy);
        %store the coordinate  and rgb values in rgbcenter
        rgbcenter(o,1)=sx/2;
        rgbcenter(o,2)=sy/2;
        rgbcenter(o,3)=red;
        rgbcenter(o,4)=green;
        rgbcenter(o,5)=blue;
        rgbcenter2(o,1)=red;
        rgbcenter2(o,2)=green;
        rgbcenter2(o,3)=blue;
        o = o+1;
        
    end
end

%check mark for convergence(k-means)
check =true;

%if  convergence then stop the loop

for p = 1:iter
for i = 1:len
        for j = 1:k
            dal(i,j) = norm(array(i,:)- rgbcenter(j,:));
        end
        [distance,center11] = min(dal(i,1:k));
        dal(i,k+1) = center11;
        dal(i,k+2) = distance;
end

for i = 1:k
        A = (dal(:,k+1)==i);
        checkx(i,:) = mean(array(A,:));
end

%check the center convergence
if checkx==rgbcenter
for i = 1:k
        A = (dal(:,k+1)==i);
        rgbcenter(i,:)= mean(array(A,:));
       
end
else
    check =false;
end
end



%create another array only store the rgb value for reshape the matrix
len1 = length(rgbcenter);
for i =1:len1
     rgbcenter1(i,1)= rgbcenter(i,3);
     rgbcenter1(i,2)= rgbcenter(i,4);
     rgbcenter1(i,3)= rgbcenter(i,5);
end

%reshape the image
a= zeros(size(array1));
for i = 1:k
    idx = find(dal(:, k+1)==i);
    a(idx,:) = repmat(rgbcenter1(i,:), size(idx,1),1);
end
T=reshape(a,size(im,1),size(im,2),3);

%make the pixel which touch both colors to be black
tr = T(:,:,1);
tg = T(:,:,2);
tb = T(:,:,3);
[trs1,trs2] = size(tr);

for m1=1:trs1-1
    for n1=1:trs2-1
        if tr(m1,n1) ~= tr(m1,n1+1) || tr(m1,n1) ~= tr(m1+1,n1)
            T(m1,n1,1)=0;
            T(m1,n1,2)=0;
            T(m1,n1,3)=0;
        end
    end
end

%show the image
figure();
T=uint8(T);
im= uint8(im);
subplot(121); imshow(im); title('original')
subplot(122); imshow(T); title('SLIC')



        






