function precoder = precode_signal(precoder_type, H, N_SNR, snr)
    
    [M, K] = size(H);
    
    switch upper(precoder_type)
        case 'ZF'
            if M == K
                precoder = (conj(H) / (H.' * conj(H)));
            else
                precoder = sqrt(M-K) * (conj(H) / (H.' * conj(H)));
            end
        case 'MF'
            precoder = conj(H) ./ sqrt(M);
        case 'MMSE'
            precoder = zeros(M, K, N_SNR);
            for snr_idx = 1:N_SNR
                if M == K
                    precoder(:,:,snr_idx) = (conj(H) / (H.' * conj(H) + 1/snr(snr_idx)*eye(K))); 
                else
                    precoder(:,:,snr_idx) = sqrt(M-K) * (conj(H) / (H.' * conj(H) + 1/snr(snr_idx)*eye(K)));
                end
            end
        otherwise
            error('Invalid precoder type. Choose "ZF", "MF", or "MMSE".');
    end
end