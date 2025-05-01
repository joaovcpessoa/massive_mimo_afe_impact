function decoder = decode_signal_gpu(decoder_type, H, snr)
    [M, K] = size(H);

    switch upper(decoder_type)
        case 'ZF'
            decoder = (H' * H) \ H';

        case 'MF'
            norms = vecnorm(H).^2;
            decoder = H ./ norms;
            decoder = decoder';

        case 'MMSE'
            I_K = eye(K, 'like', H);
            HH = H' * H;
            decoder = (HH + (1/snr) * I_K) \ H';

        otherwise
            error('Invalid receiver type. Choose "ZF", "MF", or "MMSE".');
    end
end
