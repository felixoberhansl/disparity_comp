function B = gaussfilt(input_image)
    B = zeros(size(input_image));
    gauss_f=1/16*[1,2,1;
             2,4,2;
             1,2,1];
    B1 = conv2(input_image(:,:,1), gauss_f, 'same');
    B2 = conv2(input_image(:,:,2), gauss_f, 'same');
    B3 = conv2(input_image(:,:,3), gauss_f, 'same');
    B(:,:,1) =  B1;
    B(:,:,2) =  B2;
    B(:,:,3) =  B3;
end