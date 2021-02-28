syxt1 = imresize(imread('syxt1.jpg'), 0.5);
syxt2 = imresize(imread('syxt2.jpg'), 0.5);
syxt3 = imresize(imread('syxt3.jpg'), 0.5);
syxt4 = imresize(imread('syxt4.jpg'), 0.5);

[syxt23, mask23] = merge(syxt2, syxt3);
[syxt123, mask123] = merge(syxt23, syxt1, mask23);
[syxt1234, mask1234] = merge(syxt123, syxt4, mask123);

imshow(syxt1234);