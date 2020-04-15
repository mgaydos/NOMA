function rx_bits = demodQPSK( qpsk_map, X_hat, AUS_hat )
%demodQPSK: Convert QPSK symbols to bits based on supplied constellation
%map
%   Each original QPSK symbol is in one of the IQ quadrants. We will
%   estimate the received symbol based on which quadrant the received
%   symbol resides.


% ===== INITS ===== %
J = size(X_hat, 2);


% ===== FORM RECEIVED BITS SHELL ===== %
%Create a shell to hold the 2*J bits for each user in the AUS
rx_bits = zeros(length(AUS_hat), 2*J);


% ===== GET BIT TO SYMBOL CORRESPONDENCE ===== %
Q1 = find(real(qpsk_map) > 0 & imag(qpsk_map) > 0) - 1;
Q2 = find(real(qpsk_map) < 0 & imag(qpsk_map) > 0) - 1;
Q3 = find(real(qpsk_map) < 0 & imag(qpsk_map) < 0) - 1;
Q4 = find(real(qpsk_map) > 0 & imag(qpsk_map) < 0) - 1;


% ===== DECODE EACH SYMBOL INDIVIDUALLY ===== %
for k=1:length(AUS_hat)
    for j=1:J
        % ===== DETERMINE WHAT QUADRANT EACH SYMBOL FALLS IN ===== %
        curr_symbol = X_hat(AUS_hat(k), j);
        if real(curr_symbol) > 0 && imag(curr_symbol) > 0
            %Symbol decoded to fall in quadrant 1
            decoded_bits = decimalToBinaryVector(Q1, 2);
        elseif real(curr_symbol) < 0 && imag(curr_symbol) > 0
            %Symbol decoded to fall in quadrant 2
            decoded_bits = decimalToBinaryVector(Q2, 2);
        elseif real(curr_symbol) < 0 && imag(curr_symbol) < 0
            %Symbol decoded to fall in quadrant 3
            decoded_bits = decimalToBinaryVector(Q3, 2);
        else
            %Symbol decoded to fall in quadrant 4
            decoded_bits = decimalToBinaryVector(Q4, 2);
        end
        
        
        % ===== INPUT BITS TO RAW BITS VECTOR ===== %
        a = (j-1)*2 + 1;        %Start index for raw bits
        b = a+1;                %Stop index for raw bits
        rx_bits(k, a:b) = decoded_bits;
    end
end

end

