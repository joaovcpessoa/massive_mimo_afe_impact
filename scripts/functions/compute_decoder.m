function decoder = compute_decoder(decoder_type, H, N_SNR, snr)

    [M, K] = size(H);
    decoder = zeros(M, K, N_SNR);

    switch upper(decoder_type)
        case 'ZF'
            decoder = (H' * conj(H)) \ H';
        
        case 'MF'
            decoder = conj(H) ./ (vecnorm(H).^2);

        case 'MMSE'
            for snr_idx = 1:N_SNR
                decoder(:,:,snr_idx) = pinv(H' * H + (1/snr(snr_idx)) * eye(K)) * H';
            end
        
        otherwise
            error('Invalid receiver type. Choose "ZF", "MF", or "MMSE".');
    end
end