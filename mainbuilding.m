mb1 = imresize(imread('main-build1.jpg'), 0.5);
mb2 = imresize(imread('main-build2.jpg'), 0.5);
mb3 = imresize(imread('main-build3.jpg'), 0.5);
mb4 = imresize(imread('main-build4.jpg'), 0.5);

[mb23, mask23] = merge(mb3, mb2);
[mb123, mask123] = merge(mb23, mb1, mask23);
[mb1234, mask1234] = merge(mb123, mb4, mask123);

imshow(mb1234);
