clear all;
test1 = imread('sky_test1.jpg');
test2 = imread('sky_test2.jpg');
test3 = imread('sky_test3.jpg');
test4 = imread('sky_test4.jpg');
S1 = colorsky(test1);
%S2 = colorsky(test2);
%S3 = colorsky(test3);
%S4 = colorsky(test4);
figure,imshow(S1);
%figure,imshow(S2);
%figure,imshow(S3);
%figure,imshow(S4);

function T = colorsky(test)
im = imread('sky_train.jpg');
immask = imread('sky_train1.jpg');
array =reshape( im , size(im,1)*size(im,2) , 3 );
array2 =reshape( immask , size(immask,1)*size(immask,2) , 3 );
%initialize the matrix to NaN (avoid k-means to cluster 0 in a group)
sky = NaN(size(array));
nonsky = NaN(size(array));
check = zeros(size(array));

%separate sky and non-sky
len=length(array);
for i=1:len
    if array2(i,1)==255 && array2(i,2)==255 && array2(i,3)==255
        check(i) =1;
    end
end

for i =1:len
    if check(i,1)==1
        sky(i,:)=array(i,:);
    else
        nonsky(i,:)=array(i,:);
    end
end

%k value of k-means
k=10;

%k-means for sky
ksky1 = kmeans( sky ,k,'EmptyAction', 'singleton');
%k-means for non-sky
ksky2 = kmeans( nonsky ,k,'EmptyAction', 'singleton');
leng = length(sky);

%find the centroid of each cluster
for i=1:k
    A = (ksky1(:)==i);
    skyword(i,:)=mean(sky(A,:));
end
for i=1:k
    B = (ksky2(:)==i);
    nonskyword(i,:)=mean(nonsky(B,:));
end

%test image process
testarray =reshape( test , size(test,1)*size(test,2) , 3 );
testarray= double(testarray);
testleng=length(testarray);

%compute Euclidean distance
for i =1:testleng
    for j =1:k
        dalsky(i,j)=norm(skyword(j,:) - testarray(i,:));
        dalnonsky(i,j)=norm(nonskyword(j,:)-testarray(i,:));
    end
end

%find minimal distance of each class of each pixel
minskyd = min(dalsky,[],2);
minnskyd= min(dalnonsky,[],2);

%set the sky to different color
for i =1:length(minskyd)
    if minskyd(i)<minnskyd(i)
        testarray(i,1)=55;
        testarray(i,2)=55;
        testarray(i,3)=55;
    end
end

%show the image
T= reshape(testarray,size(im,1),size(im,2),3);
T=uint8(T);
end
