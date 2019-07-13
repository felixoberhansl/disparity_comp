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
colorbar
% figure
% imshow(uint8(disp_right))
% colormap('jet')
% colorbar


%% Post-Processing
% disparityMap = disp_left;
% Mean-Shift-Algorithm
% bandwith = 0.1;                     
% test1=rgb2gray(Ms(JL, bandwith));
% [seg2, ~] = Ms2(JL, bandwith);
% seg2gray = rgb2gray(seg2);
% segs = unique(seg2gray);
% thr = 2;
% for i = 1:size(segs,1)
%    m = mode(disparityMap(seg2gray==segs(i)));
%    indizes = find(seg2gray==segs(i));
%    for j = 1:size(indizes,1)
%        k = indizes(j);
%        if (disparityMap(k) < m-thr) || (disparityMap(k) > m+thr)
%            disparityMap(k) = 0;
%        else
%            disparityMap(k) = m;
%        end
%    end
% end


% figure
% imagesc(disp_left);
% figure
% imagesc(disp_right);
%save disparity_seq1.mat
%*3 -294