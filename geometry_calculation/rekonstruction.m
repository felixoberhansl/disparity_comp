function [T, R, lambda, M1, M2] = rekonstruction(T1, T2, R1, R2, correspondences, K)
    %% Preparation
    % all possible combinations for T and R
    T_cell = {T1, T2, T1, T2};
    R_cell = {R1, R1, R2, R2};
    
    % homogenize and calibrate x1, x2
    x1 = [correspondences(1:2,:); ones(1, size(correspondences,2))];
    x2 = [correspondences(3:4,:); ones(1, size(correspondences,2))];
    x1 = (K^-1)*x1;              
    x2 = (K^-1)*x2;  
    
    n = size(correspondences,2);
    d_cell = {zeros(n,2), zeros(n,2), zeros(n,2), zeros(n,2)};
    
    %% Rekonstruction
    N = size(correspondences,2);
    M1 = zeros(N,N+1);
    M2 = zeros(N,N+1);

    
    % 1. build M1 and M2
    for i = 1:4
        for j = 1:N
            M1(1+(j-1)*3 : 3+(j-1)*3, j) = hat(x2(:,j)) * R_cell{i} * x1(:,j);
            M1(1+(j-1)*3 : 3+(j-1)*3, N+1) = hat(x2(:,j)) * T_cell{i};       % last col in M
            
            M2(1+(j-1)*3 : 3+(j-1)*3, j) = hat(x1(:,j)) * R_cell{i}.' * x2(:,j);
            M2(1+(j-1)*3 : 3+(j-1)*3, N+1) = -hat(x1(:,j)) * R_cell{i}.' * T_cell{i};       % last col in M
        end
        
        % 2. compute d1 and d2
        [~, ~, V1] = svd(M1);
        [~, ~, V2] = svd(M2);
        
        d1 = V1(:, N+1);
        d2 = V2(:, N+1);
        % norm
        d1 = d1/(d1(N+1));
        d2 = d2/(d2(N+1));
        
        % 3.
        d_cell{i}(:,1) = d1(1:N);
        d_cell{i}(:,2) = d2(1:N);
    end

    
    % find lambdas with the most pos. values -> sign -> sum -> max 
    for i = 1:4
        depth(i) = sum(sum(sign(d_cell{i})));
    end
    [~, bestCombi] = max(depth);
    
    T = T_cell{bestCombi};
    R = R_cell{bestCombi};
    lambda = d_cell{bestCombi};
    
end