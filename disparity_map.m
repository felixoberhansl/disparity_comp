function [D, R, T] = disparity_map(scene_path)
    % This function receives the path to a scene folder and calculates the
    % disparity map of the included stereo image pair. Also, the Euclidean
    % motion is returned as Rotation R and Translation T.

    % import data
    img1 = imread(fullfile(scene_path, 'im0.png'));
    img2 = imread(fullfile(scene_path, 'im1.png'));
    eval(fileread(fullfile(scene_path, 'calib.txt')));                      % execute code in the calib.txt file to get the calibration parameters  

    % check data
    if size(img1) ~= size(img2)                                             % What else to check?
        error('The size of the images does not match!')
    end
    
    %% Essentielle Matrix
    % preprocessing images
    img1gray = rgb2gray(img1);
    img2gray = rgb2gray(img2);
    
    % compute harris-features
    features1 = harris_detektor(img1gray);
    features2 = harris_detektor(img2gray);
   
    % estimate correspondences
    correspondences = punkt_korrespondenzen(img1gray, img2gray, features1, features2);
    
    % find robust correspondences
    robustCorrespondences = F_ransac(correspondences);
    
    % compute E
    E = achtpunktalgorithmus(robustCorrespondences, cam0);                   % Kameramatrix 1 oder 2 ? bzw. sind die immer gleich??

    %% Euclidean movement
    % compute possible values for T and R
    [T1,R1,T2,R2,U,V] = TR_aus_E(E);
    
    % estimate correct T and R
    [T, R, lambda, M1, M2] = rekonstruktion(T1, T2, R1, R2, correspondences, cam0);
end