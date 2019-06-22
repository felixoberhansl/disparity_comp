function [correspondences_robust] = F_ransac(correspondences, varargin)
    % This function implements the RANSAC-Algorithm to determine robust
    % correspondences
    
    %% Input parser

    % set default values
    default_epsilon = 0.5;
    default_prob = 0.5;
    default_tolerance = 0.01;
    
    % parse
    p = inputParser;
    addRequired(p, 'correspondences');
    addOptional(p, 'epsilon', default_epsilon, @(x) isnumeric(x) && (x > 0) && (x < 1));
    addOptional(p, 'prob', default_prob, @(x) isnumeric(x) && (x > 0) && (x < 1));
    addOptional(p, 'tolerance', default_tolerance, @(x) isnumeric(x));
    
    parse(p,correspondences,varargin{:});
    epsilon = p.Results.epsilon;
    prob = p.Results.prob;
    tolerance = p.Results.tolerance;
      
    % x1, x2 homogenisieren
    x1_pixel = [correspondences(1:2,:); ones(1, size(correspondences,2))];
    x2_pixel = [correspondences(3:4,:); ones(1, size(correspondences,2))];
    
    %% RANSAC Algorithmus Vorbereitung
    k = 8;                                          % number of needed correspondences
    s = log(1-prob)/log(1-(1-epsilon)^k);           % iterations
    largest_set_size = 0;
    largest_set_dist = Inf;
    largest_set_F = zeros(3,3);
    
    %% RANSAC Algorithmus
    for i = 1:s
        
        % 1. estimate F
        idx_rand = randperm(size(correspondences,2), k);
        F = achtpunktalgorithmus(correspondences(:,idx_rand));
        % 2. Samspson distance for the whole dataset
        sd = sampson_dist(F, x1_pixel, x2_pixel);
        % 3. 4. 5. 6.
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