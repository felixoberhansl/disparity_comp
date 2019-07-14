function [correspondences_robust] = F_ransac(correspondences, varargin)
    % This function implements the RANSAC-Algorithm to determine robust
    % correspondences

    % set default values
    epsilon = 0.5;
    prob = 0.5;
    tolerance = 0.01;
      
    % homogenize x1, x2
    x1_pixel = [correspondences(1:2,:); ones(1, size(correspondences,2))];
    x2_pixel = [correspondences(3:4,:); ones(1, size(correspondences,2))];
    
    %% RANSAC Algorithm Pre-Processing
    k = 8;                                          % number of needed correspondences
    s = log(1-prob)/log(1-(1-epsilon)^k);           % iterations
    largest_set_size = 0;
    largest_set_dist = Inf;
    largest_set_F = zeros(3,3);
    
    %% RANSAC Algorithm
    for i = 1:s
        
        % 1. estimate F
        idx_rand = randperm(size(correspondences,2), k);
        F = eightpointalgorithm(correspondences(:,idx_rand));
        % 2. Samspson distance for the whole dataset
        sd = sampson_dist(F, x1_pixel, x2_pixel);
        % 3. find all points with sd<tolerance and check if this set is
        % "better" (in size/quality) than the set before
        idx_inlier = find(sd<tolerance);
        current_set_dist = sum(sd(idx_inlier));
        current_set_size = size(idx_inlier,2);
        if current_set_size > largest_set_size || (current_set_size == largest_set_size && current_set_dist < largest_set_dist)
            largest_set_size = current_set_size;
            largest_set_dist = current_set_dist;
            largest_set_F = F;
            largest_set = idx_inlier;
        end
        
    end
    
    % return
    correspondences_robust = correspondences(:,largest_set);
    
end