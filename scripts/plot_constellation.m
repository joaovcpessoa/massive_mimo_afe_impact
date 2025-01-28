% Sinal decodificado (com normalização) ZF
figure;
for users_idx = 1:K    
    s_received_ZF = y_ZF(users_idx, :).';
    Ps_received_ZF = norm(s_received_ZF)^2 / N_BLK;

    s_received_ZF_normalized = sqrt(Ps(users_idx) / Ps_received_ZF) * s_received_ZF;
    
    plot(real(s_received_ZF_normalized), imag(s_received_ZF_normalized),'.','MarkerSize', markersize,'Color',colors(users_idx, :));
    xlabel('Re', 'FontName', fontname, 'FontSize', fontsize);
    ylabel('Im', 'FontName', fontname, 'FontSize', fontsize);
end

% Sinal decodificado (com normalização) MMSE
figure;
for users_idx = 1:K   
    s_received_MMSE = y_MMSE(users_idx, :).';
    Ps_received_MMSE = norm(s_received_MMSE)^2 / N_BLK;

    s_received_MMSE_normalized = sqrt(Ps(users_idx) / Ps_received_MMSE) * s_received_MMSE;

    plot(real(s_received_MMSE_normalized), imag(s_received_MMSE_normalized),'.','MarkerSize', markersize,'Color',colors(users_idx, :));
    xlabel('Re', 'FontName', fontname, 'FontSize', fontsize);
    ylabel('Im', 'FontName', fontname, 'FontSize', fontsize);
end