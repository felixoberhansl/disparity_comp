function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % Diese Funktion berechnet die Sampson Distanz basierend auf der
    % Fundamentalmatrix F
    e3_hat = [0 -1 0; 1 0 0; 0 0 0];

    % mit Schleifen sd = (x2_pixel(:,1).' * F * x1_pixel(:,1))^2 / (sum((e3_hat * F * x1_pixel(:,1)).^2) + sum((x2_pixel(:,1).' * F * e3_hat).^2));    %|| ||^2 = euklidische norm^2
    sd = sum(x2_pixel .* (F*x1_pixel)).^2 ./ (sum((e3_hat*F*x1_pixel).^2) + sum((e3_hat*F.'*x2_pixel).^2));    %
end