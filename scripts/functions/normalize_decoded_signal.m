function s_normalized = normalize_decoded_signal(decoder_type, K, s, N_SNR)
    % This function normalizes the decoded signal based on the specified decoder type.
    % Inputs:
    %   decoder_type: Type of decoder ('ZF', 'MF', or 'MMSE')
    %   s: Decoded signal (K x N_BLK) for ZF/MF or (K x N_BLK x N_SNR) for MMSE
    %   K: Number of users
    %   N_SNR: Number of SNR values (only for MMSE)
    %   N_BLK: Number of temporal samples (blocks)
    % Outputs:
    %   s_normalized: Normalized decoded signal (same size as s)

    N_BLK = size(s,1);

    switch upper(decoder_type)
        case {'ZF', 'MF'}
            s_normalized = zeros(size(s));            
            for k = 1:K
                Ps = norm(s(k, :))^2 / length(s(:, k));
                s_normalized(k, :) = s(k, :) / sqrt(Ps);
            end
        case 'MMSE'
            s_normalized = zeros(K, N_BLK, N_SNR);
            for snr_idx = 1:N_SNR
                for k = 1:K
                    Ps = norm(s(k, :, snr_idx))^2 / length(y(:, k, snr_idx));
                    s_normalized(k, :, snr_idx) = s(k, :, snr_idx) / sqrt(Ps);
                end
            end
        otherwise
            error('Invalid decoder type. Choose "ZF", "MF", or "MMSE".');
    end
end