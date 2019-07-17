function [D, R, T, p] = challenge(scene_path)

%% Computer Vision Challenge 2019
% Group number:
group_number = 33;

% Group members:
members = {'Henrique Cabral Meneses de Almeida e Sousa','Manuel Lengl','Felix Oberhansl','Christoph Preisinger','Marcus Scmidt'};

% Email-Address (from Moodle!):
mail = {'ge49ceg@mytum.de','m.lengl@tum.de','felix.oberhansl@tum.de','ge25fin@mytum.de','ge25yod@mytum.de'};

%% Start timer here
timer = tic;


%% Disparity Map
% Calculate disparity map and Euclidean motion
[D, R, T] = disparity_map(scene_path);


%% Validation
% Specify path to ground truth disparity map
gt_path = scene_path;
%
% Load the ground truth
G = readpfm(gt_path+"/disp0.pfm");

% Estimate the quality of the calculated disparity map
p = verify_dmap(uint8(D),uint8(G));

%% Stop timer here
elapsed_time = toc(timer)

%% Print Results
% R, T, p, elapsed_time

%% Display Disparity
% plot
figure
imshow(uint8(D),[])
title('Disparity Map')
colormap jet
colorbar
save challenge.mat
end
