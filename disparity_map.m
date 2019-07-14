function [D, R, T] = disparity_map(scene_path)
% This function receives the path to a scene folder and calculates the
% disparity map of the included stereo image pair. Also, the Euclidean
% motion is returned as Rotation R and Translation T.

%% add subfolders
addpath('data');
addpath('disparity');
addpath('geometry_calculation');
addpath(scene_path);


%% import data
img1 = imread(fullfile(scene_path, 'im0.png'));
img2 = imread(fullfile(scene_path, 'im1.png'));
eval(fileread(fullfile(scene_path, 'calib.txt'))+";");                      % execute code in the calib.txt file to get the calibration parameters

%% check data
if size(img1) ~= size(img2)                                             % What else to check?
    error('The size of the images does not match!')
end

%% calculate disparity 
window_size = 11;
max_disp_factor = 0.05;
max_image_size = 750;
[disp_left,disp_right]=calculateDisparityMap(img1,img2,max_image_size,max_disp_factor,window_size,2,1,10);
D = disp_left;

% calculate translation and rotation

[T,R,~] = calc_T_R(img1, img2, cam0);

% T = [baseline/1000; 0; 0];
% R = [1 0 0; 0 1 0; 0 0 1];

end

