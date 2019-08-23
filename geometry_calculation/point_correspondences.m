function correspondences = point_correspondences(I1,I2,Mpt1,Mpt2)
    % This function compares the extracted features from a stereo-image with
    % NCC to get the correspondences.
   
    %% set default parameters
    window_length = 25;
    min_corr = 0.95;
    
    %% Pre-Processing features
    % image 1
    Mpt1( : , Mpt1(1,:) < (window_length+1)/2) = [];                % left
    Mpt1( : , Mpt1(1,:) > size(I1,2)-(window_length-1)/2) = [];     % right
    Mpt1( : , Mpt1(2,:) < (window_length+1)/2) = [];                % top
    Mpt1( : , Mpt1(2,:) > size(I1,1)-(window_length-1)/2) = [];     % bottom
    
    % image 2
    Mpt2( : , Mpt2(1,:) < (window_length+1)/2) = [];                % left
    Mpt2( : , Mpt2(1,:) > size(I2,2)-(window_length-1)/2) = [];     % right
    Mpt2( : , Mpt2(2,:) < (window_length+1)/2) = [];                % top
    Mpt2( : , Mpt2(2,:) > size(I2,1)-(window_length-1)/2) = [];     % bottom
    
    %% Norm
    dist = (window_length-1)/2;
    Mat_feat_1 = zeros(window_length^2, size(Mpt1,2));
    Mat_feat_2 = zeros(window_length^2, size(Mpt2,2));    

    for i = 1:size(Mpt1,2)
        temp_window1 = I1(Mpt1(2,i) - dist : Mpt1(2,i) + dist, Mpt1(1,i) - dist : Mpt1(1,i) + dist);
        temp_window1 = double(temp_window1(:));     % stack
        std_temp_window1 = std(temp_window1);       % standard deviation
        mean_temp_window1 = mean(temp_window1);     % mean
        Mat_feat_1(:,i) = (temp_window1-mean_temp_window1) ./ std_temp_window1;     % norm
    end
    
    for i = 1:size(Mpt2,2)
        temp_window2 = I2(Mpt2(2,i) - dist : Mpt2(2,i) + dist, Mpt2(1,i) - dist : Mpt2(1,i) + dist);
        temp_window2 = double(temp_window2(:));     % stack
        std_temp_window2 = std(temp_window2);       % standard deviation
        mean_temp_window2 = mean(temp_window2);     % mean
        Mat_feat_2(:,i) = (temp_window2-mean_temp_window2) ./ std_temp_window2;     % norm
    end
    
    %% Normalized Cross Correlation
    N = window_length^2;
    NCC_matrix = zeros(size(Mat_feat_1,2), size(Mat_feat_2,2));
 
    %% calculate NCC (x:=2.image; y:=1.image)
    for i = 1:size(Mat_feat_1,2)        % 1.image -> y-value -> rows
        
        for j = 1:size(Mat_feat_2,2)    % 2. image -> x-value -> col
            NCC_matrix(i,j) = 1/(N-1) * trace(Mat_feat_2(:,j).' * Mat_feat_1(:,i));
        end
    end
    
    % filtering for min_corr
    NCC_matrix(NCC_matrix < min_corr) = 0;
    
    NCC_matrix = NCC_matrix.';            
    
    % indizes
    [~, sorted_index_withZero] = sort(NCC_matrix(:), 'descend');      % NCC_matrix(:) -> stacking
    sorted_index = sorted_index_withZero(1:size(find(NCC_matrix)));   % 1 : number of non-zero elements
    
    %% correspondences
    correspondences = 0;
    k=0;
    size(sorted_index,1);
    for i=1:size(sorted_index,1)
        if NCC_matrix(sorted_index(i)) ~= 0
            k=k+1;
            [X,Y] = ind2sub(size(NCC_matrix), sorted_index(i));
            correspondences(1:2,k) = Mpt1(:,Y);
            correspondences(3:4,k) = Mpt2(:,X);
            NCC_matrix(:,Y) = 0;
         end
    end
        
end