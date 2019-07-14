function [T1, R1, T2, R2, U, V]=TR_from_E(E)
    % This function calculates all possible values for T and R based on the
    % given essential matrix E.

    % SVD
    [U, S, V] = svd(E);

    % check if U is a rotational matrix
    if det(U) ~= 1                      % condition for rotation matrix: det() = 1
        U = U*diag([1 1 -1]);            %                               orthogonal cols (always the case)
    end
    
    if det(V) ~= 1                      
        V = V*diag([1 1 -1]);
    end
    
    % Rotation around z-Axis
    RZ1 = [0 -1 0;
           1  0 0
           0  0 1];
    RZ2 = [0 1 0;
          -1 0 0
           0 0 1];
    
    % R1 and T1
    R1 = U * RZ1.' * V.';
    T1hat = U * RZ1 * S * U.';
    T1 = [T1hat(6); T1hat(7); T1hat(2)];        
    % R2 and T2                                
    R2 = U * RZ2.' * V.';                      
    T2hat = U * RZ2 * S * U.';                  
    T2 = [T2hat(6); T2hat(7); T2hat(2)];
    
    
end