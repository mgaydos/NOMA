close, clear, clc;
tic
% ===== INITIALIZATIONS ===== %
%Simulation Inits
sim_frames = 500;
%Cell Inits
avg_num_UEs = 200;                  %average number of users in MMT cell
cell_radius = 250;                  %radius of MMT cell
min_distance_to_BS = 50;            %closest UE can be to BS
%Spreading Sequence Inits
N = 100;                            %spread sequence length
%Traffic Inits
prob_of_tx = 0.1;                   %probability some UE has data to tx
min_packet_len = 20*8;              %minimum packet length in bits
max_packet_len = 200*8;             %maximum packet length in bits
%Frame Inits
J = 7;                              %number of time slots per frame
t_f = 0.1e-3;                       %duration of frame in seconds
%Transmission Inits
noise_threshold = [0.68 0.51 0.48...
                    0.38 0.28];     %temp var, i think this should be a function of snr
SNR_dB = [0 2 4 6 8];               %desired SNR in dB
Pmax = 0.48;                        %maximum transmit power in watts
M = 4;                              %speicifies M-ary modulation
M_map = 1/sqrt(2) * [1 + 1i, ...
    -1 + 1i, 1 - 1i, -1 - 1i];      % unit constellation for M-ary comms
%Error Stats Inits
tx_symbols = zeros(length(SNR_dB), sim_frames);
symbol_errors = zeros(length(SNR_dB), sim_frames);
AUS_false_positives = zeros(length(SNR_dB), sim_frames);
AUS_not_included = zeros(length(SNR_dB), sim_frames);


% ===== GENERATE UE LOCATIONS ACCORDING TO PPP ===== %
UE_locations = generateUEs(avg_num_UEs, cell_radius, min_distance_to_BS);
%plotUEs(UE_locations, cell_radius, min_distance_to_BS);


% ===== GENERATE EACH UE SPREADING SEQUENCE ===== %
spreading_sequences = generatePseudoRandomComplexNoiseSeqs(length(UE_locations), N);

for s=1:length(SNR_dB)
    for i=1:sim_frames

        % ===== GENERATE ACTIVE SET OF USERS AND THEIR DATA FOR CURRENT FRAME ===== %
        [X, AUS, raw_bits] = generateTxSymbols(length(UE_locations), prob_of_tx, J, M, M_map);


        % ===== TRANSMIT ACROSS CHANNEL ===== %
        [Y, H, G] = applyChannelEffects(X, spreading_sequences, SNR_dB(s));


        % ===== APPLY TA-BSASP ALGORITHM TO RECOVER X_HAT ===== %
        [X_hat, AUS_hat] = tabsaspAlgorithm(Y, G, noise_threshold(s));


        % ===== DECODE SYMBOLS AS BITS ===== %
        rx_bits = demodQPSK(M_map, X_hat, AUS_hat);


        % ===== GENERATE ERROR STATISTICS ===== %
        [tx_symbols(s, i), symbol_errors(s, i), AUS_false_positives(s, i), AUS_not_included(s, i)] = getErrorStatistics(X, X_hat, AUS, AUS_hat);

    end
end

SERS = sum(symbol_errors')./sum(tx_symbols')
SEs = sum(symbol_errors')
AUS_Errors = sum(AUS_not_included')
AUS_FP = sum(AUS_false_positives')
toc