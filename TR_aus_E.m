function [T1, R1, T2, R2, U, V]=TR_aus_E(E)
    % Diese Funktion berechnet die moeglichen Werte fuer T und R
    % aus der Essentiellen Matrix
    
    % SVD
    [U, S, V] = svd(E);

    % Rotationssymmetrie sicherstellen
    if det(U) ~= 1                      % Bedingung für rotationssymmetrisch: det() = 1
        U = U*diag([1 1 -1]);            %                                     orthogonale Spalten (sowieso)
    end
    
    if det(V) ~= 1                      
        V = V*diag([1 1 -1]);
    end
    
    % Rotationen um z-Achse
    RZ1 = [0 -1 0;
           1  0 0
           0  0 1];
    RZ2 = [0 1 0;
          -1 0 0
           0 0 1];
    
    % R1 und T1
    R1 = U * RZ1.' * V.';
    T1hat = U * RZ1 * S * U.';
    T1 = [T1hat(6); T1hat(7); T1hat(2)];        % Matrixindizierung: !!!!!
    % R2 und T2                                 % [1, 4, 7
    R2 = U * RZ2.' * V.';                       %  2, 5, 8
    T2hat = U * RZ2 * S * U.';                  %  3, 6, 9]
    T2 = [T2hat(6); T2hat(7); T2hat(2)];
    
    
end