function [y] = amplifier(x, type, A0)
    
    switch upper(type)
        case 'IDEAL'
            y = x;
        case 'CLIP'
            y = min(abs(x), A0) .* exp(1j * angle(x));
        case 'TWT'
            chi_A = 1;
            kappa_A = 0.25;
            chi_phi = 0.26;
            kappa_phi = 0.25;
            g_A = (chi_A .* abs(x)) ./ (1 + kappa_A .* abs(x).^2);
            g_phi = (chi_phi .* abs(x).^2) ./ (1 + kappa_phi .* abs(x).^2);
            y = g_A .* exp(1i * (angle(x) + g_phi));
        case 'SS'
            rho = 1;
            y = abs(x) ./ (1 + (abs(x) / A0).^(2 * rho)).^(1 / (2 * rho)) .* exp(1j * angle(x));
        otherwise
            error('Invalid amplifier type.');
    end
end