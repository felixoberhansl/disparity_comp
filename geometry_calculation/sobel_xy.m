function [Fx, Fy] = sobel_xy(input_image)
    % This function implements the Sobel-Filter, which gets a gray-scaled
    % image as an input and returns the image gradient in x- and y-direction
    Sobel_h=[1,0,-1;
             2,0,-2;
             1,0,-1];
    Sobel_v=[1,2,1;
             0,0,0;
             -1,-2,-1];

    Fx = conv2(input_image, Sobel_h, 'same');
    Fy = conv2(input_image, Sobel_v, 'same');
end