clear
addpath(genpath('../'));

JL=imread('../data/terrace/im0.png');
JR=imread('../data/terrace/im1.png');
window_size=11;
max_disp_factor=0.05;
max_image_size = 750;

[disp_left,disp_right,~,~]=calculateDisparityMap(JL,JR,max_image_size,max_disp_factor,window_size,2,1,10);
%plot
figure
imshow(uint8(disp_left),[])
colormap('jet')
colorbar
% figure
% imshow(uint8(disp_right))
% colormap('jet')
% colorbar
