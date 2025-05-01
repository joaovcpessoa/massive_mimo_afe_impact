clear;
close all;
clc;

decoder_list = {'ZF', 'MMSE'};
for decoder_idx = 1:length(decoder_list)
    decoder_type = decoder_list{decoder_idx};
    for K = [64, 128, 256]
        run ber_uplink.m
    end
end