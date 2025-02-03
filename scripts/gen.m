addpath('./functions/');

M = 128;
K = 128;
K_f = 10;

H = ricianChannelGenerator(M , K , K_f);

save('channel.mat', 'H');