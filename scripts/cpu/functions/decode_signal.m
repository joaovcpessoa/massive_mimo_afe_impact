function decoder = decode_signal(decoder_type, H, snr)

    [M, K] = size(H);

    switch upper(decoder_type)
        case 'ZF'
            decoder = (H' * H) \ H';
        case 'MF'
            decoder = (H ./ (vecnorm(H).^2))';
        case 'MMSE'
            HH = H' * H;
            decoder = inv(HH + (1/snr) * eye(K)) * H';
            % precoder = zeros(M, K, N_SNR);
            % for snr_idx = 1:N_SNR
            %     precoder(:,:,snr_idx) = conj(H) / (H.' * conj(H) + 1/snr(snr_idx)*eye(K));
            % end
        otherwise
            error('Invalid receiver type. Choose "ZF", "MF", or "MMSE".');
    end
end