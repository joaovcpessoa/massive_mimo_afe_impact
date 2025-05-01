function y = amplify_signal_gpu(x, type, varargin)
    % Amplifica o sinal x de acordo com o tipo de amplificador especificado.

    switch upper(type)
        case 'IDEAL'
            y = x;

        case 'CLIP'
            if isempty(varargin)
                error('Amplificador CLIP requer o parâmetro A0.');
            end
            A0 = varargin{1};
            y = min(abs(x), A0) .* exp(1j * angle(x));  % 'min' é compatível com gpuArray

        case 'SS'
            if isempty(varargin)
                error('Amplificador SS requer o parâmetro A0.');
            end
            A0 = varargin{1};
            rho = 1;
            amp = abs(x);
            y = amp ./ (1 + (amp / A0).^(2 * rho)).^(1 / (2 * rho)) .* exp(1j * angle(x));

        case 'TWT'
            % Valores padrão
            chi_A = 1;
            kappa_A = 0.25;
            chi_phi = 0.26;
            kappa_phi = 0.25;

            if ~isempty(varargin)
                if length(varargin) ~= 4
                    error(['Amplificador TWT requer 4 parâmetros: ' ...
                        'chi_A, kappa_A, chi_phi, kappa_phi.']);
                end
                chi_A = varargin{1};
                kappa_A = varargin{2};
                chi_phi = varargin{3};
                kappa_phi = varargin{4};
            end

            amp = abs(x);
            g_A = (chi_A .* amp) ./ (1 + kappa_A .* amp.^2);
            g_phi = (chi_phi .* amp.^2) ./ (1 + kappa_phi .* amp.^2);
            y = g_A .* exp(1j * (angle(x) + g_phi));

        otherwise
            error('Tipo de amplificador inválido: %s', type);
    end
end
