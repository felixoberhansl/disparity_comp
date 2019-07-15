function B = gaussfilt(input_image)
B = zeros(size(input_image));
gauss_f=1/16*[1,2,1;
    2,4,2;
    1,2,1];
for i = 1: size(input_image,3)
    B(:,:,i) = conv2(input_image(:,:,i), gauss_f, 'same');
end

end