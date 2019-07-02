function [D, R, T] = disparity_map(scene_path)
    % This function receives the path to a scene folder and calculates the
    % disparity map of the included stereo image pair. Also, the Euclidean
    % motion is returned as Rotation R and Translation T.

    % add subfolders
    addpath(genpath('d:\git\cv_challenge_33\')); 
    
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
    correspondences = punkt_korrespondenzen(img1gray, img2gray, features1, features2);
    
    % find robust correspondences
    robustCorrespondences = F_ransac(correspondences);
    
    % compute E
    E = achtpunktalgorithmus(robustCorrespondences, cam0);                   % Kameramatrix 1 oder 2 ? bzw. sind die immer gleich??

    % compute E with CV Toolbox for comparison
    params0 = cameraParameters('IntrinsicMatrix', cam0);
    params1 = cameraParameters('IntrinsicMatrix', cam1);
    E_cv0 = estimateEssentialMatrix(robustCorrespondences(1:2,:).', robustCorrespondences(3:4,:).', params0)
    E_cv1 = estimateEssentialMatrix(robustCorrespondences(1:2,:).', robustCorrespondences(3:4,:).', params1)
    E_cv01 = estimateEssentialMatrix(robustCorrespondences(1:2,:).', robustCorrespondences(3:4,:).', params0, params1)

    E
        
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
    
    % perspective projection matrix, world origin at first camera 
    ppm0 = cam0 * eye(3,4);
    ppm1 = cam1 *[eye(3), T];
    
    [img1Rect, img2Rect] = rectifyImageE(img1, img2, ppm0, ppm1);
    
    img1RectGray = rgb2gray(img1Rect);
    
    %----------------------------------------------------------------------
    
    
    % first try on basic block matching approach
    % -> basically takes a block of pixels and tries to find the best
    % matching block in the other image (only along the same row, because 
    % of the rectified images), distance between these matching blocks is
    % then the disparity
    
    disparityMap = zeros(height,width);
    
    disparityRange = ceil(doffs);                                    % defines the range where to search
    
    blockSize = 11;                                                          % defines the size of the blocks
    halfBlockSize = (blockSize-1)/2;
    
    for m = 1: height
        minRow = max(1, m-halfBlockSize);
        maxRow = min(height, m+halfBlockSize);
        
        for n = 1: width
            minCol = max(1, n-halfBlockSize);
            maxCol = min(width, n+halfBlockSize);
            
            minDisp = 0;
            maxDisp = min(disparityRange, width-maxCol);
            
            rightBlock = img2gray(minRow:maxRow, minCol:maxCol);
            
            numBlocks = maxDisp - minDisp + 1;
            
            blockDiffs = zeros(numBlocks,1);
            
            for i = minDisp : maxDisp
                leftBlock = img1gray(minRow:maxRow, minCol+i : maxCol+i);
                idxBlock = i - minDisp + 1;
                blockDiffs(idxBlock) = sum(sum(abs(rightBlock-leftBlock)));
            end
            
            [~, idxSorted] = sort(blockDiffs);
            
            matchingBlock = idxSorted(1);
            
            disp = matchingBlock + minDisp - 1;
            
            % subpixel interpolation
            if (matchingBlock == 1) || (matchingBlock == numBlocks)
                disparityMap(m, n) = disp;
            else
                
                C1 = blockDiffs(matchingBlock - 1);
                C2 = blockDiffs(matchingBlock);
                C3 = blockDiffs(matchingBlock + 1);
                
                % Adjust the disparity by some fraction.
                % estimating the subpixel location of the true best match.
                disparityMap(m, n) = disp - (0.5 * (C3 - C1) / (C1 - (2*C2) + C3));
            end
        end
    end
    
    
    figure(1)
    imshow(disparityMap, []);
    axis image;
    colormap('jet')
    colorbar
            
            
            
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