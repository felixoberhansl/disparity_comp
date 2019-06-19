function [T, R, lambda, M1, M2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K)
    %% Vorbereitung aus Aufgabe 4.2
    % T_cell    Cell-Array mit T1 und T2 
    % R_cell    Cell-Array mit R1 und R2
    % d_cell    Cell-Array für die Tiefeninformationen
    % x1        homogene kalibrierte Koordinaten
    % x2        homogene kalibrierte Koordinaten
    %% Preparation
    % alle Kombinationsmöglichkeiten für T un R abbilden
    T_cell = {T1, T2, T1, T2};
    R_cell = {R1, R1, R2, R2};
    
    % x1, x2 homogenisieren und kalibrieren
    x1 = [Korrespondenzen(1:2,:); ones(1, size(Korrespondenzen,2))];
    x2 = [Korrespondenzen(3:4,:); ones(1, size(Korrespondenzen,2))];
    x1 = (K^-1)*x1;              
    x2 = (K^-1)*x2;  
    
    n = size(Korrespondenzen,2);
    d_cell = {zeros(n,2), zeros(n,2), zeros(n,2), zeros(n,2)};
    
    %% Rekonstruktion
    N = size(Korrespondenzen,2);
    M1 = zeros(N,N+1);
    M2 = zeros(N,N+1);

    
    % 1. M1 und M2 aufstellen
    for i = 1:4
        for j = 1:N
            M1(1+(j-1)*3 : 3+(j-1)*3, j) = skew(x2(:,j)) * R_cell{i} * x1(:,j);
            M1(1+(j-1)*3 : 3+(j-1)*3, N+1) = skew(x2(:,j)) * T_cell{i};       % letzte Spalte in M
            
            M2(1+(j-1)*3 : 3+(j-1)*3, j) = skew(x1(:,j)) * R_cell{i}.' * x2(:,j);
            M2(1+(j-1)*3 : 3+(j-1)*3, N+1) = -skew(x1(:,j)) * R_cell{i}.' * T_cell{i};       % letzte Spalte in M
        end
        
        % 2. d1 und d2 ermitteln
        [~, ~, V1] = svd(M1);
        [~, ~, V2] = svd(M2);
        
        d1 = V1(:, N+1);
        d2 = V2(:, N+1);
        % normieren
        d1 = d1/(d1(N+1));
        d2 = d2/(d2(N+1));
        
        % 3.
        d_cell{i}(:,1) = d1(1:N);
        d_cell{i}(:,2) = d2(1:N);
    end

    
    % lambdas mit meisten pos. Tiefeninformationen finden -> sign -> sum -> max 
    for i = 1:4
        depth(i) = sum(sum(sign(d_cell{i})));
    end
    [~, bestCombi] = max(depth);
    
    T = T_cell{bestCombi};
    R = R_cell{bestCombi};
    lambda = d_cell{bestCombi};
    
end


function [xhat]=skew(x)
xhat = [0 -x(3) x(2); 
        x(3) 0 -x(1); 
        -x(2) x(1) 0];
end