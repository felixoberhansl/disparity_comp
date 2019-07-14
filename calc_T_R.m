% add subfolders
addpath(genpath('../'));
scene_path = 'data/motorcycle/';
% import data
img1 = imread(fullfile(scene_path, 'im0.png'));
img2 = imread(fullfile(scene_path, 'im1.png'));
eval(fileread(fullfile(scene_path, 'calib.txt')));                      % execute code in the calib.txt file to get the calibration parameters

% check data
if size(img1) ~= size(img2)                                             % What else to check?
    error('The size of the images does not match!')
end

% preprocessing images
img1gray = double(rgb2gray(img1));
img2gray = double(rgb2gray(img2));

%% Essentielle Matrix
    
    % compute harris-features
    features1 = harris_detector(img1gray);
    features2 = harris_detector(img2gray);

    % estimate correspondences
    correspondences = point_correspondences(img1gray, img2gray, features1, features2);

    % find robust correspondences
    robustCorrespondences = F_ransac(correspondences);

    % plot for verification
    plotCorrespondences(img1, img2, robustCorrespondences, 'own')
    %% -> only translation in x, for sword only few correspondences (3 or 4) or more but not matching ones!!!

    % hartley pre-processing
    hartley_correspondences = hartley_preprocess(robustCorrespondences, img1gray, img2gray);

    % compute E
    E = eightpointalgorithm(robustCorrespondences, cam0);                   % Kameramatrix 1 oder 2 ? bzw. sind die immer gleich??
    Ehart = eightpointalgorithm(hartley_correspondences, cam0);

    %% compute E with CV Toolbox for comparison
    features1_cv = (detectHarrisFeatures(img1gray));
    features1_cv= features1_cv.selectStrongest(size(features1,2))
    features2_cv = detectHarrisFeatures(img2gray);
    features2_cv= features2_cv.selectStrongest(size(features2,2))

    %% didnt find a tool in the CV toolbox for finding correspondences ->
    % estimate correspondences
    correspondences_cv = point_correspondences(img1gray, img2gray, double(features1_cv.Location).', double(features2_cv.Location).');

    % find robust correspondences
    robustCorrespondences_cv = F_ransac(correspondences_cv);

    % plot for verification
    plotCorrespondences(img1, img2, robustCorrespondences_cv, 'CV')

    params0 = cameraParameters('IntrinsicMatrix', cam0);
    params1 = cameraParameters('IntrinsicMatrix', cam1);
    E_cv0 = estimateEssentialMatrix(hartley_correspondences(1:2,:).', hartley_correspondences(3:4,:).', params0)
    E_cv1 = estimateEssentialMatrix(hartley_correspondences(1:2,:).', hartley_correspondences(3:4,:).', params1)
    E_cv01 = estimateEssentialMatrix(hartley_correspondences(1:2,:).', hartley_correspondences(3:4,:).', params0, params1)

    E
    Ehart
    %% Euclidean movement
    % compute possible values for T and R
    [T1,R1,T2,R2,U,V] = TR_from_E(E);

    % estimate correct T and R
    [T, R, lambda, M1, M2] = rekonstruction(T1, T2, R1, R2, correspondences, cam0);

    % transform T into [m]
    % -> use cx1 - cx0 to get the distance between the cameras along the
    % x-axis???????
