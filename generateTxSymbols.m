function [X, AUS, raw_bits] = generateTxSymbols( num_UEs, prob_of_tx, J, M, M_map )
%generateTxSymbols: chooses active users and generates random data to
%transmtit for those users
%   First, we will randomly generate an array of dimension num_UEs x 1 of
%   random numbers between [0,1]. If the value is less than or equal to the
%   prob_of_tx, we will assign that user to the active user set AUS. Next,
%   because we are doing frame-wise joint sparsity, this implies that if a
%   user is going to be active and transmitting, it will do so for an
%   entire frame. Thus, for each active user, we will generate enough
%   random binary data to fill a frame of length J considering M-ary
%   symbols. We will then convert these generated bits into unit complex
%   symbols that correspond to the M-ary constellation M_map. If a user is
%   not transmitting, a 0 symbol will be used instead. These complex
%   symbols and 0's will be stored in a num_UEs x J array X which
%   represents the data to transmit.

% ===== GENERATE ACTIVE USER SET ===== %
raw_rand_users = rand(num_UEs, 1);
AUS = find(raw_rand_users <= prob_of_tx);

% ===== GENERATE EACH ACTIVE USERS RANDOM DATA ===== %
%Generate random binary data
raw_rand_binary_seq = round(rand(length(AUS), J*log2(M)));
%Convert binary data to M-ary constellation
raw_rand_mary_seq = zeros(length(AUS), J);
for i=1:length(AUS)
    for j=1:J
        %Consider log2(M) bits at a time
        a = (j - 1)*log2(M) + 1;
        b = j*log2(M);
        mary_symbol_index = binaryVectorToDecimal(raw_rand_binary_seq(i, a:b)) + 1;
        raw_rand_mary_seq(i, j) = M_map(mary_symbol_index);
    end
end

% ===== CREATE X ===== %
X = zeros(num_UEs, J);
X(AUS, :) = raw_rand_mary_seq;
raw_bits = raw_rand_binary_seq;

end

