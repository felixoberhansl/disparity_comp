%load('rectificated.mat', 'JL');
%load('rectificated.mat', 'JR');
clear
addpath(genpath('../'));

JL=imread('../data/motorcycle/im0.png');
JR=imread('../data/motorcycle/im1.png');
window_size=0.01;
max_disp_factor=0.3;


[disp_left,disp_right,~,~]=calculateDisparityMap(JL,JR,700,max_disp_factor,window_size,2,1,10);
%plot
figure
imshow(uint8(disp_left))
colormap('jet')
figure
imshow(uint8(disp_right))
colormap('jet')
% figure
% imagesc(disp_left);
% figure
% imagesc(disp_right);
%save disparity_seq1.mat
%*3 -294