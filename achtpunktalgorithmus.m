function [EF] = achtpunktalgorithmus(Korrespondenzen, K)
    % Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix
    % mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K'
    % vorliegt oder nicht

    % x1, x2 homogenisieren
    x1 = [Korrespondenzen(1:2,:); ones(1, size(Korrespondenzen,2))];
    x2 = [Korrespondenzen(3:4,:); ones(1, size(Korrespondenzen,2))];
    
    % x1, x2 kalibrieren
    if (nargin>1)               % K vorhanden?
        x1 = (K^-1)*x1;              
        x2 = (K^-1)*x2;              
    end
    
    % A
    for i = 1:size(Korrespondenzen,2)           
        A(i,:) = (kron(x1(:,i), x2(:,i))).';        % Kronecker Produkte bilden, in eine Matrix packen
    end
    
    % V
    [~,~,V] = svd(A);
    
    %% Schaetzung der Matrizen
    G = reshape(V(:,9), [3 3]);     % "unstack"
    [UG,SG,VG] = svd(G);
  
    if nargin>1         % K gegeben -> Essentielle Matrix
        EF = UG * [1 0 0;0 1 0; 0 0 0] * VG.';
    else                % -> Fundamentalmatrix
        SG(3,3) = 0;    % 3. Singulärwert auf 0 setzen
        EF = UG * SG * VG.';
    end
end