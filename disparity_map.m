function [D, R, T] = disparity_map(scene_path)
% This function receives the path to a scene folder and calculates the
% disparity map of the included stereo image pair. Also, the Euclidean
% motion is returned as Rotation R and Translation T.

% add subfolders
addpath(genpath('..\'));

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

%% Essential Matrix (only depending on the translation in x)
T = [baseline; 0; 0];
R = [1 0 0; 0 1 0; 0 0 1];
E = hat(T)*R;

%% Belief Propagation test
%outimg=beliefPropStereo(img1,img2,25,10,10)

%     %% Essentielle Matrix
%
%     % compute harris-features
%     features1 = harris_detector(img1gray);
%     features2 = harris_detector(img2gray);
%
%     % estimate correspondences
%     correspondences = point_correspondences(img1gray, img2gray, features1, features2);
%
%     % find robust correspondences
%     robustCorrespondences = F_ransac(correspondences);
%
%     % plot for verification
%     plotCorrespondences(img1, img2, robustCorrespondences, 'own')
%     %% -> only translation in x, for sword only few correspondences (3 or 4) or more but not matching ones!!!
%
%     % hartley pre-processing
%     hartley_correspondences = hartley_preprocess(robustCorrespondences, img1gray, img2gray);
%
%     % compute E
%     E = eightpointalgorithm(robustCorrespondences, cam0);                   % Kameramatrix 1 oder 2 ? bzw. sind die immer gleich??
%     Ehart = eightpointalgorithm(hartley_correspondences, cam0);
%
%     %% compute E with CV Toolbox for comparison
%     features1_cv = (detectHarrisFeatures(img1gray));
%     features1_cv= features1_cv.selectStrongest(size(features1,2))
%     features2_cv = detectHarrisFeatures(img2gray);
%     features2_cv= features2_cv.selectStrongest(size(features2,2))
%
%     %% didnt find a tool in the CV toolbox for finding correspondences ->
%     % estimate correspondences
%     correspondences_cv = point_correspondences(img1gray, img2gray, double(features1_cv.Location).', double(features2_cv.Location).');
%
%     % find robust correspondences
%     robustCorrespondences_cv = F_ransac(correspondences_cv);
%
%     % plot for verification
%     plotCorrespondences(img1, img2, robustCorrespondences_cv, 'CV')
%
%     params0 = cameraParameters('IntrinsicMatrix', cam0);
%     params1 = cameraParameters('IntrinsicMatrix', cam1);
%     E_cv0 = estimateEssentialMatrix(hartley_correspondences(1:2,:).', hartley_correspondences(3:4,:).', params0)
%     E_cv1 = estimateEssentialMatrix(hartley_correspondences(1:2,:).', hartley_correspondences(3:4,:).', params1)
%     E_cv01 = estimateEssentialMatrix(hartley_correspondences(1:2,:).', hartley_correspondences(3:4,:).', params0, params1)
%
%     E
%     Ehart
%     %% Euclidean movement
%     % compute possible values for T and R
%     [T1,R1,T2,R2,U,V] = TR_from_E(E);
%
%     % estimate correct T and R
%     [T, R, lambda, M1, M2] = rekonstruction(T1, T2, R1, R2, correspondences, cam0);
%
%     % transform T into [m]
%     % -> use cx1 - cx0 to get the distance between the cameras along the
%     % x-axis???????
%
%     % ---------------------------------------------------------------------
%     % ---------------------------------------------------------------------
%
%     %% Disparity Map
%     % rectifying images
%     % (in order to have two images projected on a virtual
%     % plane, so that there is only movement along the x-axis)
%
%     % is this step neccessary, or do we only get such images?
%     % -> not necessary, only translation in x!!!!!!
%
%     % perspective projection matrix, world origin at first camera
%     ppm0 = cam0 * eye(3,4);
%     ppm1 = cam1 *[eye(3), T];
%
%     [img1Rect, img2Rect] = rectifyImageE(img1, img2, ppm0, ppm1);
%
%     img1RectGray = rgb2gray(img1Rect);

%----------------------------------------------------------------------
%----------------------------------------------------------------------

%% first try on basic block matching approach w dynamic programming
% -> basically takes a block of pixels and tries to find the best
% matching block in the other image (only along the same row, because
% of the rectified images), distance between these matching blocks is
% then the disparity

disparityMap = zeros(height,width);

disparityRange = 50;%round(baseline);%30;%round(width/5);%ceil(doffs);                                    % defines the range where to search

blockSize = 11;                                                          % defines the size of the blocks
halfBlockSize = (blockSize-1)/2;

finf = 1e3;                                         % initialize so-called false infinity (some random high value)
disparityPenalty = 0.5;                             % penalty for mismatching neighbouring disparities (tolerance 3)
disparityCost = finf * ones(width, 2 * disparityRange + 1, 'single');      % initialize disparity cos matrix with high values
% one row for each pixel in de current row of the image, colums for the disparities of the next pixels
for row = 1: height
    % reinitialize disparityCost
    disparityCost(:) = finf;
    % progress visualization
    if (mod(row, 10) == 0)
        fprintf(' Image row %d / %d (%.0f%%)\n', row, height, (row / height) * 100);
    end
    
    minRow = max(1, row-halfBlockSize);
    maxRow = min(height, row+halfBlockSize);
    
    for col = 1: width
        minCol = max(1, col-halfBlockSize);
        maxCol = min(width, col+halfBlockSize);
        
        minDisp = 0;
        maxDisp = min(disparityRange, width-maxCol);
        
        rightBlock = img2gray(minRow:maxRow, minCol:maxCol);
       
        for i = minDisp : maxDisp
            leftBlock = img1gray(minRow:maxRow, minCol+i : maxCol+i);
            disparityCost(col, i+1) = sum(sum(abs(rightBlock-leftBlock)));
        end
        
        %             [~, idxSorted] = sort(blockDiffs);
        %
        %             matchingBlock = idxSorted(1);
        %
        %             disp = matchingBlock + minDisp - 1;
        %
        %             % subpixel interpolation
        %             if (matchingBlock == 1) || (matchingBlock == numBlocks)
        %                 disparityMap(row, col) = disp;
        %             else
        %
        %                 C1 = blockDiffs(matchingBlock - 1);
        %                 C2 = blockDiffs(matchingBlock);
        %                 C3 = blockDiffs(matchingBlock + 1);
        %
        %                 % Adjust the disparity by some fraction (minima of a parabola through three points).
        %                 % estimating the subpixel location of the true best match.
        %                 disparityMap(row, col) = disp - (0.5 * (C3 - C1) / (C1 - (2*C2) + C3));
        %            end
    end
    % dynamic programmin, backward propagation, search "cheapest" way
    % through the disparity cost matrix
    
    % matrix for storing the optimal disparities
    optIndices = zeros(size(disparityCost));
    
    cp = disparityCost(end,:);          % last row of disparityCost -> coresponds to mthe most right pixel in the image
    % going from the right to the left
    for j = width-1:-1:1
        cfinf = (width-j+1) * finf;          % false infinity for this level, increases, the more left you are in the image
        
        mat = [cfinf cfinf cp(1:end-4)+3*disparityPenalty;
            cfinf cp(1:end-3)+2*disparityPenalty;
            cp(1:end-2)+disparityPenalty;
            cp(2:end-1);
            cp(3:end)+disparityPenalty;
            cp(4:end)+2*disparityPenalty cfinf;
            cp(5:end)+3*disparityPenalty cfinf cfinf];
        [v, ix] = min(mat,[],1);
        
        % update cp
        cp = [cfinf disparityCost(j,2:end-1)+v cfinf];
        
        % Record optimal route
        optIndices(j, 2:end-1) = (2:size(disparityCost,2)-1) + (ix - 4);
    end
    
    % Recover the optimal route
    
    % get minimum cost for the most left pixel in the row
    [~,ix] = min(cp);
    disparityMap(row,1) = ix;
    
    % get values for the rest of the image -> forward propagation
    for k = 1:(width-1)
        % Set the next pixel's disparity.
        % Lookup the disparity for the next pixel by indexing into the
        % 'optimalIndeces' table using the current pixel's disparity.
        disparityMap(row,k+1) = optIndices(k, ...
            max(1, min(size(optIndices,2), round(disparityMap(row,k)) ) ) );
    end
    
end

disparityMap = disparityMap-disparityRange + 1;
clf
imshow(disparityMap, []);
axis image;
colormap('jet')
colorbar
%----------------------------------------------------------------------
%----------------------------------------------------------------------
%% Post-Processing
% Mean-Shift-Algorithm
bandwith = 0.1;                     
test1=rgb2gray(Ms(img1, bandwith));
test2=rgb2gray(Ms2(img1, bandwith));
segs = unique(test2);
thr = 2;
for i = 1:size(segs,1)
   m = mode(disparityMap(test2==segs(i)));
   indizes = find(test2==segs(i));
   for j = 1:size(indizes,1)
       k = indizes(j);
       if (disparityMap(k) < m-thr) || (disparityMap(k) > m+thr)
           disparityMap(k) = 0;
       else
           disparityMap(k) = m;
       end
   end
end

figure
imshow(disparityMap, []);
axis image;
colormap('jet')
colorbar
%----------------------------------------------------------------------
%----------------------------------------------------------------------

%     %% first try on basic block matching approach w/o dynamic programming
%     % -> basically takes a block of pixels and tries to find the best
%     % matching block in the other image (only along the same row, because
%     % of the rectified images), distance between these matching blocks is
%     % then the disparity
%
%     disparityMap = zeros(height,width);
%
%     disparityRange = 30;%ceil(doffs);                                    % defines the range where to search
%
%     blockSize = 9;                                                          % defines the size of the blocks
%     halfBlockSize = (blockSize-1)/2;
%
%     for row = 1: height
%         minRow = max(1, row-halfBlockSize);
%         maxRow = min(height, row+halfBlockSize);
%
%         for col = 1: width
%             minCol = max(1, col-halfBlockSize);
%             maxCol = min(width, col+halfBlockSize);
%
%             minDisp = 0;
%             maxDisp = min(disparityRange, width-maxCol);
%
%             rightBlock = img2gray(minRow:maxRow, minCol:maxCol);
%
%             numBlocks = maxDisp - minDisp + 1;
%
%             blockDiffs = zeros(numBlocks,1);
%
%             for i = minDisp : maxDisp
%                 leftBlock = img1gray(minRow:maxRow, minCol+i : maxCol+i);
%                 idxBlock = i - minDisp + 1;
%                 blockDiffs(idxBlock) = sum(sum(abs(rightBlock-leftBlock)));
%             end
%
%             [~, idxSorted] = sort(blockDiffs);
%
%             matchingBlock = idxSorted(1);
%
%             disp = matchingBlock + minDisp - 1;
%
%             % subpixel interpolation
%             if (matchingBlock == 1) || (matchingBlock == numBlocks)
%                 disparityMap(row, col) = disp;
%             else
%
%                 C1 = blockDiffs(matchingBlock - 1);
%                 C2 = blockDiffs(matchingBlock);
%                 C3 = blockDiffs(matchingBlock + 1);
%
%                 % Adjust the disparity by some fraction (minima of a parabola through three points).
%                 % estimating the subpixel location of the true best match.
%                 disparityMap(row, col) = disp - (0.5 * (C3 - C1) / (C1 - (2*C2) + C3));
%             end
%         end
%     end
%
%     clf
%     imshow(disparityMap, []);
%     axis image;
%     colormap('jet')
%     colorbar

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
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