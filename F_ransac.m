function [Korrespondenzen_robust] = F_ransac(Korrespondenzen, varargin)
    % Diese Funktion implementiert den RANSAC-Algorithmus zur Bestimmung von
    % robusten Korrespondenzpunktpaaren
    
    %% Input parser
    % Bekannte Variablen:
    % epsilon       geschätzte Wahrscheinlichkeit
    % p             gewünschte Wahrscheinlichkeit
    % tolerance     Toleranz um als Teil des Consensus-Sets zu gelten
    % x1_pixel      homogene Pixelkoordinaten
    % x2_pixel      homogene Pixelkoordinaten
    
    % set default values
    default_epsilon = 0.5;
    default_prob = 0.5;
    default_tolerance = 0.01;
    
    % input parser
    p = inputParser;
    addRequired(p, 'Korrespondenzen');
    addOptional(p, 'epsilon', default_epsilon, @(x) isnumeric(x) && (x > 0) && (x < 1));
    addOptional(p, 'prob', default_prob, @(x) isnumeric(x) && (x > 0) && (x < 1));
    addOptional(p, 'tolerance', default_tolerance, @(x) isnumeric(x));
    
    parse(p,Korrespondenzen,varargin{:});
    epsilon = p.Results.epsilon;
    prob = p.Results.prob;
    tolerance = p.Results.tolerance;
      
    % x1, x2 homogenisieren
    x1_pixel = [Korrespondenzen(1:2,:); ones(1, size(Korrespondenzen,2))];
    x2_pixel = [Korrespondenzen(3:4,:); ones(1, size(Korrespondenzen,2))];
    
    %% RANSAC Algorithmus Vorbereitung
    % Vorinitialisierte Variablen:
    % k                     Anzahl der benötigten Punkte
    % s                     Iterationszahl
    % largest_set_size      Größe des bisher größten Consensus-Sets
    % largest_set_dist      Sampson-Distanz des bisher größten Consensus-Sets
    % largest_set_F         Fundamentalmatrix des bisher größten Consensus-Sets
    k = 8;                                      % Anzahl benötigter Punkte
    s = log(1-prob)/log(1-(1-epsilon)^k);          % Iterationszahl
    largest_set_size = 0;
    largest_set_dist = Inf;
    largest_set_F = zeros(3,3);
    
    %% RANSAC Algorithmus
    % 1. estimate F
    idx_rand = randperm(size(Korrespondenzen,2), k);
    F = achtpunktalgorithmus(Korrespondenzen(:,idx_rand));
    % 2. Samspson distance for the whole dataset
    sd = sampson_dist(F, x1_pixel, x2_pixel);
    % 3. 4. 5. 6.
    idx_inlier = find(sd<tolerance);
    current_set_dist = sum(sd(idx_inlier));
    current_set_size = size(idx_inlier,2);
    if current_set_size > largest_set_size || (current_set_size == largest_set_size && current_set_dist < largest_set_dist)
        largest_set_size = current_set_size;
        largest_set_dit = current_set_dist;
        largest_set_F = F;
        largest_set = idx_inlier;
    end

    % return
    Korrespondenzen_robust = Korrespondenzen(:,largest_set);
    
end