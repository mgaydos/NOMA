clear, clc;
% ===== INITIALIZATIONS ===== %
%Cell Inits
avg_num_UEs = 200;                  %average number of users in MMT cell
cell_radius = 250;                  %radius of MMT cell
min_distance_to_BS = 50;            %closest UE can be to BS
%Spreading Sequence Inits
N = 100;                            %spread sequence length, must be power of 2
%Traffic Inits
prob_of_tx = 0.1;                   %probability some UE has data to tx
min_packet_len = 20*8;              %minimum packet length in bits
max_packet_len = 200*8;             %maximum packet length in bits
%Frame Inits
J = 7;                              %number of time slots per frame
t_f = 0.1e-3;                       %duration of frame in seconds
%Transmission Inits
noise_threshold = 0.48;             %temp var, i think this should be a function of snr
SNR = 4;                            %desired SNR in dB
Pmax = 0.48;                        %maximum transmit power in watts
M = 4;                              %speicifies M-ary modulation
M_map = 1/sqrt(2) * [1 + 1i, ...
    -1 + 1i, -1 - 1i, 1 - 1i];      % unit constellation for M-ary comms
%Error Stats Inits



% ===== GENERATE UE LOCATIONS ACCORDING TO PPP ===== %
UE_locations = generateUEs(avg_num_UEs, cell_radius, min_distance_to_BS);
%plotUEs(UE_locations, cell_radius, min_distance_to_BS);


% ===== GENERATE EACH UE SPREADING SEQUENCE ===== %
spreading_sequences = generatePseudoRandomComplexNoiseSeqs(length(UE_locations), N);


% ===== GENERATE ACTIVE SET OF USERS AND THEIR DATA FOR CURRENT FRAME ===== %
[X, AUS, raw_bits] = generateTxSymbols(length(UE_locations), prob_of_tx, J, M, M_map);


% ===== TRANSMIT ACROSS CHANNEL ===== %
[Y, H, G] = applyChannelEffects(X, spreading_sequences, SNR);


% ===== APPLY TA-BSASP ALGORITHM TO RECOVER X_HAT ===== %
[X_hat, AUS_hat] = tabsaspAlgorithm(Y, G, noise_threshold);


% ===== DECODE SYMBOLS AS BITS ===== %
rx_bits = demodQPSK(M_map, X_hat, AUS_hat);


% ===== GENERATE ERROR STATISTICS ===== %
[total_tx_symbols, symbol_errors, AUS_false_positives] = getErrorStatistics(X, X_hat, AUS, AUS_hat);


