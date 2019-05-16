clear all;
%training images
im{1,1} = imread('coast_train1.jpg');
im{2,1} = imread('coast_train2.jpg');
im{3,1} = imread('coast_train3.jpg');
im{4,1} = imread('coast_train4.jpg');
im{5,1} = imread('forest_train1.jpg');
im{6,1} = imread('forest_train2.jpg');
im{7,1} = imread('forest_train3.jpg');
im{8,1} = imread('forest_train4.jpg');
im{9,1} = imread('insidecity_train1.jpg');
im{10,1} = imread('insidecity_train2.jpg');
im{11,1} = imread('insidecity_train3.jpg');
im{12,1} = imread('insidecity_train4.jpg');

%test images with names
test{1,1} = imread('coast_test1.jpg');
testname{1} = 'coast_test1.jpg';
test{2,1} = imread('coast_test2.jpg');
testname{2} = 'coast_test2.jpg';
test{3,1} = imread('coast_test3.jpg');
testname{3} = 'coast_test3.jpg';
test{4,1} = imread('coast_test4.jpg');
testname{4} = 'coast_test4.jpg';
test{5,1} = imread('forest_test1.jpg');
testname{5} = 'forest_test1.jpg';
test{6,1} = imread('forest_test2.jpg');
testname{6} = 'forest_test2.jpg';
test{7,1} = imread('forest_test3.jpg');
testname{7} = 'forest_test3.jpg';
test{8,1} = imread('forest_test4.jpg');
testname{8} = 'forest_test4.jpg';
test{9,1} = imread('insidecity_test1.jpg');
testname{9} = 'insidecity_test1.jpg';
test{10,1} = imread('insidecity_test2.jpg');
testname{10} = 'insidecity_test2.jpg';
test{11,1} = imread('insidecity_test3.jpg');
testname{11} = 'insidecity_test3.jpg';
test{12,1} = imread('insidecity_test4.jpg');
testname{12} = 'insidecity_test4.jpg';

%test classes
for i=1:12
    if i <5
        testclass{i} = 'coast';
    end
    if i >4 && i<9
        testclass{i} = 'forest';
    end
    if i >8
        testclass{i} = 'insidecity';
    end
end
    
        
testSize = length(test);
trainsize = length(im);

%compute the hisgram of each train image
for i =1:trainsize
    imhisg{i} = imhis(im{i,1});
end
%compute the hisgram of each test image
for i =1:testSize
    testhisg{i} = imhis(test{i,1});
end
%compute the Euclidean distance between the test image and all train images
for i = 1:trainsize
    for j = 1:testSize
    dis(i,j) = norm(imhisg{j} - testhisg{i});
    end
end

%find the min distance of each test image
[mina,index] = min(dis,[],2);
leng = length(index);

%classifer each test images to different class
for i =1:leng
    if index(i)<5
        x=['Test image ',testname{i},' of class ', testclass{i},' has been assigned to coast class.' ];
        disp(x);
    end
     if 4<index(i) && index(i)<9
         x=['Test image ',testname{i},' of class ', testclass{i},' has been assigned to forest class.' ];
        disp(x);
     end
        if index(i)>8
           x=['Test image ',testname{i},' of class ', testclass{i},' has been assigned to insidecity class.' ];
           disp(x);
        end
end

%creat a hisgram of the image
function imhisg = imhis(im)
red = im(:, :, 1);
green = im(:, :, 2);
blue = im(:, :, 3);
imaghisr = hisg(red);
imaghisb = hisg(blue);
imaghisg = hisg(green);

imhisg = [imaghisr,imaghisb,imaghisg];

function his = hisg(data)
[m,n] = size(data);
%8 bins
count1 = 0;
count2 = 0;
count3 = 0;
count4 = 0;
count5 = 0;
count6 = 0;
count7 = 0;
count8 = 0;

%8 bins(0-30, 30-50, 50-90, 90-130, 130-150, 150-190, 190-210, 210-255)
for i = 1:256
    for j =1:256
        if data(i,j)<=30
            count1 = count1 +1;
        end
        if data(i,j)<=50 && 30<data(i,j)
            count2 = count2+1;
        end
        if data(i,j)<=90 && 50<data(i,j)
            count3 = count3+1;
        end
        if data(i,j)<=130 && 90<data(i,j)
            count4 = count4+1;
        end
        if data(i,j)<=150 && 130<data(i,j)
            count5 = count5+1;
        end
        if data(i,j)<=190 && 150<data(i,j)
            count6 = count6+1;
        end
        if data(i,j)<=210 && 190<data(i,j)
            count7 = count7+1;
        end
        if data(i,j)<=256 && 210<data(i,j)
            count8 = count8+1;
        end
    end
end

%creat hisgram
pixel = m*n;
h1 = count1/pixel;
h2 = count2/pixel;
h3 = count3/pixel;
h4 = count4/pixel;
h5 = count5/pixel;
h6 = count6/pixel;
h7 = count7/pixel;
h8 = count8/pixel;
his =[h1,h2,h3,h4,h5,h6,h7,h8];
end
end