%load('rectificated.mat', 'JL');
%load('rectificated.mat', 'JR');
clear
JL=imread('L1_recti_cropped.png');
JR=imread('R1_recti_cropped.png');
window_size=0.01;
max_disp_factor=0.3;


[disp_left,disp_right,~,~]=calculateDisparityMap(JL,JR,700,max_disp_factor,window_size,2,1,10);

figure
imagesc(disp_left);
figure
imagesc(disp_right);
%save disparity_seq1.mat
%*3 -294