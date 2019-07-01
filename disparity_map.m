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
    img1gray = double(rgb2gray(img1));
    img2gray = double(rgb2gray(img2));
    
    % compute harris-features
    features1 = harris_detektor(img1gray);
    features2 = harris_detektor(img2gray);
   
    % estimate correspondences
    correspondences = punkt_korrespondenzen(img1gray, img2gray, features1, features2)
    
    plot_correspondences(correspondences, uint8(img1gray), uint8(img2gray))
    
    % find robust correspondences
    robustCorrespondences = F_ransac(correspondences);
    
    % compute E
    E = achtpunktalgorithmus(robustCorrespondences, cam0);                   % Kameramatrix 1 oder 2 ? bzw. sind die immer gleich??

    %% Euclidean movement
    % compute possible values for T and R
    [T1,R1,T2,R2,U,V] = TR_aus_E(E);
    
    % estimate correct T and R
    [T, R, lambda, M1, M2] = rekonstruktion(T1, T2, R1, R2, correspondences, cam0);
    
    % transform T into [m]
    % -> use cx1 - cx0 to get the distance between the cameras along the
    % x-axis???????
    
    % ---------------------------------------------------------------------
    % ---------------------------------------------------------------------
    
    %% Disparity Map
    % rectifying images 
    % (in order to have two images projected on a virtual
    % plane, so that there is only movement along the x-axis)
    
    % is this step neccessary, or do we only get such images?
    %----------------------------------------------------------------------
    
    
    % first try on basic block matching approach
    % -> basically takes a block of pixels and tries to find the best
    % matching block in the other image (only along the same row, because 
    % of the rectified images), distance between these matching blocks is
    % then the disparity
    
    disparityMap = zeros(height,width);
    
    
    % params for CENSUS matching
    census_size = 10;    
    
    
    % for test purposes choose significant pixel in image one

    pixel1 = [200; 200];
    
    % show pixel for test purposes
    
    figure 
    imshow(uint8(img1gray))
    hold on
    
    plot(pixel1(1), pixel1(2),'+','Color','green')   
    
    % calculate CENSUS for clipping in image 1
    
    census_frame = img1gray(pixel1(1)-census_size/2 : pixel1(1)+census_size/2, pixel1(2)-census_size/2 : pixel1(2)+census_size/2)
    
    for i = 1:size(census_frame,1)
        for j = 1:size(census_frame, 2)
            if(img1gray(pixel1(1), pixel1(2)) > census_frame(i,j))
                census_frame(i,j) = 1;
            else
                census_frame(i,j) = 0;
            end          
        end       
    end
    
    census_frame
    
    
    % calculate epipolarline in match image for pixel in base image
    % l2 ~ E * x1
    
    x1_hom = [pixel1(1);pixel1(2);1]
    
    F = inv(cam0.') * E * inv(cam0)
    
    l2 = F * x1_hom
    
    epipolarline2 = [l2(1), l2(1)*100; l2(2), l2(2)*100]
    
    % draw epipolarline for test purposes
    figure 
    imshow(uint8(img2gray))
    hold on
    
    plot(epipolarline2, 'g')  
    
    % try with CV toolbox
    
    l2_cv = epipolarLine(F,pixel1.')
    
    
    
    
    % extract a certain band around the epipolarline
    
    
    % compare CENSUS of clipping 1 to every possible clipping in
    % extracted band
    
    
    %
    
        
        
    
    
    
    
    %figure(1)
    %imshow(disparityMap, []);
    %axis image;
    %colormap('jet')
    %colorbar
            
            
            
%     %% testing the matlab function for disparity map calculation
%     % compute disparity map 
%     disparityRange = [0 48];
%     disparityMap = disparityBM(img1gray,img2gray,'DisparityRange',disparityRange,'UniquenessThreshold',20);
%     
%     % plot
%     figure
%     imshow(disparityMap,disparityRange)
%     title('Disparity Map')
%     colormap jet
%     colorbar
end