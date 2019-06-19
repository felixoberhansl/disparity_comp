function Korrespondenzen = punkt_korrespondenzen(I1,I2,Mpt1,Mpt2,varargin)
    % In dieser Funktion sollen die extrahierten Merkmalspunkte aus einer
    % Stereo-Aufnahme mittels NCC verglichen werden um Korrespondenzpunktpaare
    % zu ermitteln.
    
    %% Input parser aus Aufgabe 2.1
    %% set default parameters
    default_window_length = 25;
    default_min_corr = 0.95;
    default_do_plot = false;
    
    %% Input parser
    p = inputParser;
    addRequired(p, 'I1');
    addRequired(p, 'I2');
    addRequired(p, 'Mpt1');
    addRequired(p, 'Mpt2');
    addOptional(p, 'window_length', default_window_length, @(x) isnumeric(x) && (mod(x,2)==1) && (x > 1));
    addOptional(p, 'min_corr', default_min_corr, @(x) isnumeric(x) && (0 < x) && (x < 1));
    addOptional(p, 'do_plot', default_do_plot, @(x) islogical(x));
    
    parse(p,I1,I2,Mpt1,Mpt2,varargin{:});
    window_length = p.Results.window_length;
    min_corr = p.Results.min_corr;
    do_plot = p.Results.do_plot;
    
    %% convert images to double
    I1 = double(p.Results.I1);
    I2 = double(p.Results.I2);
    
    %% Merkmalsvorbereitung aus Aufabe 2.2
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
        
    % number of points
    no_pts1 = size(Mpt1, 2);
    no_pts2 = size(Mpt2, 2);
    
    %% Normierung aus Aufgabe 2.3
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
    
    %% Normalized Cross Correlation aus Aufgabe 2.4
    N = window_length^2;
    NCC_matrix = zeros(size(Mat_feat_1,2), size(Mat_feat_2,2));
 
    %% NCC Brechnung (x:=2.Bild; y:=1.Bild)
    for i = 1:size(Mat_feat_1,2)        % 1.Bild -> y-Wert -> Zeilen
        
        for j = 1:size(Mat_feat_2,2)    % 2. Bild -> x-Wert -> Spalten
            NCC_matrix(i,j) = 1/(N-1) * trace(Mat_feat_2(:,j).' * Mat_feat_1(:,i));
        end
    end
    
    % min_corr filtern
    NCC_matrix(NCC_matrix < min_corr) = 0;
    
    NCC_matrix = NCC_matrix.';            % Angabe zu x und y falsch -> transponieren
    
    % indizes
    [~, sorted_index_mitNull] = sort(NCC_matrix(:), 'descend');      % NCC_matrix(:) -> Matrix zu vektor machen wegen sort
    sorted_index = sorted_index_mitNull(1:size(find(NCC_matrix)));   % 1 : Anzahl nicht-Nullen
    
    %% Korrespondenz
    Korrespondenzen = 0;
    k=0;
    size(sorted_index,1);
    for i=1:size(sorted_index,1)
        if NCC_matrix(sorted_index(i)) ~= 0
            k=k+1;
            [X,Y] = ind2sub(size(NCC_matrix), sorted_index(i));        % X:= Punkt im 2.Bild, Y:= Punkt im ersten Bild
            Korrespondenzen(1:2,k) = Mpt1(:,Y);
            Korrespondenzen(3:4,k) = Mpt2(:,X);
            NCC_matrix(:,Y) = 0;
            % NCC_matrix(Y,:) = 0;
         end
    end
        
end