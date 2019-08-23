function [T, R, E] = calc_T_R(img1, img2, cam0)

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

% % plot for verification
% plotCorrespondences(img1, img2, robustCorrespondences, 'own')

% hartley pre-processing
%hartley_correspondences = hartley_preprocess(robustCorrespondences, img1gray, img2gray);

% compute E
E = eightpointalgorithm(robustCorrespondences, cam0);
%Ehart = eightpointalgorithm(hartley_correspondences, cam0);

%% Euclidean movement
% compute possible values for T and R
[T1,R1,T2,R2,~,~] = TR_from_E(E);

% estimate correct T and R
[T, R, ~,~,~] = rekonstruction(T1, T2, R1, R2, correspondences, cam0);

end