clear all;
im = imread('white-tower.png');
im = double(im);

%create the array contains the rgb value
r= im(:,:,1);
g= im(:,:,2);
b= im(:,:,3);
array = [r(:),g(:),b(:)];

%10 centers
k=10;
%literate
iter=3;

len = length(array);
%create array to store distance and center
dal = zeros(size(array,1),k+2);
%get 10 different centers
x= array(randperm(len,k),:);
%check convergence
check = true;
%if convergence stop the loop
while check
for l = 1: iter
    for i = 1:len
        for j = 1:k
            %find distence of each pixel
            dal(i,j) = norm(array(i,:)- x(j,:));
        end
        %find smallest distance and centers
        [distance,center] = min(dal(i,1:k));
        dal(i,k+1) = center;
        dal(i,k+2)= distance;
    end


for i = 1:k
        A = (dal(:,k+1)==i);
        x(i,:)=mean(array(A,:));
        checkx(i,:) = mean(array(A,:));
end
%check coverngence
if checkx ~= x
for i = 1:k
        A = (dal(:,k+1)==i);
        % new centers
        x(i,:)=mean(array(A,:));
        
end
else
    check = false;
end
end
end

%reshape the image
a= zeros(size(array));
for i = 1:k
    idx = find(dal(:, k+1)==i);
    a(idx,:) = repmat(x(i,:), size(idx,1),1);
end
T=reshape(a,size(im,1),size(im,2),3);

%show the image
figure();
T=uint8(T);
im= uint8(im);
subplot(121); imshow(im); title('original')
subplot(122); imshow(T); title('k=10')

