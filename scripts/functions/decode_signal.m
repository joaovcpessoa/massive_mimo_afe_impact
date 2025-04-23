function decoder = decode_signal(decoder_type, H, N_SNR, snr)

    [M, K] = size(H);

    switch upper(decoder_type)
        case 'ZF'
            decoder = (H' * conj(H)) \ H';
        case 'MF'
            decoder = conj(H) ./ (vecnorm(H).^2);
        case 'MMSE'
            decoder = zeros(K, M, N_SNR);
            HH = H' * H;
            for snr_idx = 1:N_SNR
                decoder(:,:,snr_idx) = inv(HH + (1/snr(snr_idx)) * eye(K)) * H';
            end
        otherwise
            error('Invalid receiver type. Choose "ZF", "MF", or "MMSE".');
    end
end