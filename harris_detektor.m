function features = harris_detektor(input_image)
    % In dieser Funktion soll der Harris-Detektor implementiert werden, der
    % Merkmalspunkte aus dem Bild extrahiert
    %% Input Parser
    % set default values
    segment_length = 15;
    k = 0.05;
    tau = 10^6;
    min_dist = 20;
    tile_size = [200, 200];
    N = 5;
        
    %% Pre-Processing of the image
    % Pruefe ob es sich um ein Grauwertbild handelt
    if size(input_image,3) ~= 1
        error('Image format has to be NxMx1');
    end
    % convert to double
    dInputImage = double(input_image);
    % Approximation des Bildgradienten
    [Fx, Fy] = sobel_xy(dInputImage);
    % Gewichtung
    w1 = [1:segment_length/2 + 1];
    w2 = [int16(segment_length/2 - 1):-1:1];
    w = [w1, w2];
    w_norm = double(w)/norm(double(w),1);
    % Harris Matrix G
    G11 = conv2(w_norm,w_norm.',(Fx .* Fx),'same');        % G11
    G12 = conv2(w_norm,w_norm.',(Fx .* Fy),'same');        % G12
    G21 = G12;                                             % G21
    G22 = conv2(w_norm,w_norm.',(Fy .* Fy),'same');        % G22
    
    %% Feature extraction
    H = G11.*G22 - G12.*G12 - k*((G11+G22).^2);                 % det(G) - k*(trace(G)^2)
    corners = (H > tau).*H;                                          % corner if H > threshold tau
    %[rowMerkmale, colMerkmale] = find(corners);
    %disp(corners);
    
    %% Post-Processing features
    % Nullrand
    corners = [zeros(size(corners,1),min_dist), corners, zeros(size(corners,1),min_dist)];
    corners = [zeros(min_dist,size(corners,2)); corners; zeros(min_dist,size(corners,2))];
    
    % sortieren
    [~, sorted_index_mitNull] = sort(corners(:), 'descend');      % corners(:) -> Matrix zu vektor machen wegen sort
    sorted_index = sorted_index_mitNull(1:size(find(corners)));   % 1 : Anzahl nicht-Nullen
    
    %% Akkumulatorfeld aus Aufgabe 1.10
    iAnzTilesHeight = ceil(size(input_image,1)/tile_size(1,1));       % Anzahl Tiles in x(Width) und y(Height) Richtung
    iAnzTilesWidth  = ceil(size(input_image,2)/tile_size(1,2));       % tile_size nicht geeignet gewählt! aufrunden?!
    AKKA = zeros(iAnzTilesHeight, iAnzTilesWidth);
    if numel(AKKA)*N <=size(sorted_index,1)                          % max N Merkmale pro Kachel -> N*numel(AKKA)
        features = zeros(2,numel(AKKA)*N);                           % ausser in sorted_index sind schon weniger Elemente
    else                                                             % dann -> size(sorted_index,2)
        features = zeros(2,size(sorted_index,1));
    end
    
    %% Merkmalsbestimmung mit Mindestabstand und Maximalzahl pro Kachel
    [row_sorted_index,col_sorted_index] = ind2sub(size(corners),sorted_index);  % rows and cols der sorted_index ausgeben
    iAnzMerkmale = 0;                                                           
    iAnzMerkmaleMax = size(features, 2);                                         % bedingt durch entweder maximale Anzahl an Merkmalen oder tiles * N
    for i=1:size(sorted_index)
        row_AKKA = ceil((row_sorted_index(i)-min_dist)/tile_size(1));        
        col_AKKA = ceil((col_sorted_index(i)-min_dist)/tile_size(2));        
        if AKKA(row_AKKA,col_AKKA) < N                                       % max Anzahl an Merkmalen in dieser Kachel schon erreicht?
            if corners(row_sorted_index(i), col_sorted_index(i)) ~= 0        % min_dist eingehalten?!!
                AKKA(row_AKKA,col_AKKA) = AKKA(row_AKKA,col_AKKA) + 1;
                % Teil der matrix auswählen die mit cake multipliziert werden sollen, vom punkt min_dist nach links und oben bis vom punkt min_dist nach rechts und unten
                corners(row_sorted_index(i) - min_dist : row_sorted_index(i) + min_dist, col_sorted_index(i) - min_dist : col_sorted_index(i) + min_dist) = corners(row_sorted_index(i) - min_dist : row_sorted_index(i) + min_dist, col_sorted_index(i) - min_dist : col_sorted_index(i) + min_dist) .* cake(min_dist);
                iAnzMerkmale = iAnzMerkmale + 1;
                features(:,iAnzMerkmale) = [col_sorted_index(i)-min_dist; row_sorted_index(i)-min_dist];
                if iAnzMerkmale == iAnzMerkmaleMax
                   disp("max erreicht")
                   break                                                     % wenn maximale Anzahl an Merkmalen (alle Merkmale verarbeitet oder tiles*N) erreicht -> break 
                end
            end
        end
    end
    features(:, all(features == 0) ) = [];                                    % hinteren Nullen entfernen
    
end

%-------------------------functions----------------------------------------
%--------------------------------------------------------------------------

function Cake = cake(min_dist)
    % Die Funktion cake erstellt eine "Kuchenmatrix", die eine kreisfoermige
    % Anordnung von Nullen beinhaltet und den Rest der Matrix mit Einsen
    % auffuellt. Damit koennen, ausgehend vom staerksten Merkmal, andere Punkte
    % unterdrueckt werden, die den Mindestabstand hierzu nicht einhalten. 
    Cake = true(2*min_dist+1,2*min_dist+1);

    for i = 1:size(Cake,1)
        for j = 1:size(Cake,2)
            if (min_dist)^2 >= (i-(min_dist+1))^2+(j-(min_dist+1))^2
                Cake(i,j)=false;
            end
        end
    end
    
end