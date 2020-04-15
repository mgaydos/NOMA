function [ total_tx_symbols, symbol_errors, AUS_false_positives] = getErrorStatistics(X, X_hat, AUS, AUS_hat)
%getErrorStatistics: Generate error statistics for this frame.
%   This function will determine the number of symbol errors by comparing
%   the quadrant that the original tx symbol was sent in, and what quadrant
%   we estimated that it was after decoding. We will also check if any
%   users were false positives, meaning they showed up in the AUS_hat
%   (estimate) but not in the actual AUS.


% ===== INITS ===== %
J = size(X, 2);
symbol_errors = 0;
total_tx_symbols = length(AUS) * J;
AUS_false_positives = 0;


% ===== FIND NUMBER OF SYMBOL ERRORS ===== %
%Go symbol by symbol of users in AUS and check transmitted symbols
%quadrant. Compare to decoded X_hat symbol quadrant:
for k=1:length(AUS)
    for j=1:J
        
        %Find quadrant of tx_symbol in X
        tx_symbol = X(AUS(k), j);
        tx_symbol_location = 0;
        if real(tx_symbol) > 0 && imag(tx_symbol) > 0
            %Symbol decoded to fall in quadrant 1
            tx_symbol_location = 1;
        elseif real(tx_symbol) < 0 && imag(tx_symbol) > 0
            %Symbol decoded to fall in quadrant 2
            tx_symbol_location = 2;
        elseif real(tx_symbol) < 0 && imag(tx_symbol) < 0
            %Symbol decoded to fall in quadrant 3
            tx_symbol_location = 3;
        elseif real(tx_symbol) > 0 && imag(tx_symbol) < 0
            %Symbol decoded to fall in quadrant 4
            tx_symbol_location = 4;
        end
        
        %Find quadrant of rx_symbol in X_hat
        rx_symbol = X_hat(AUS(k), j);
        rx_symbol_location = 0;
        if real(rx_symbol) > 0 && imag(rx_symbol) > 0
            %Symbol decoded to fall in quadrant 1
            rx_symbol_location = 1;
        elseif real(rx_symbol) < 0 && imag(rx_symbol) > 0
            %Symbol decoded to fall in quadrant 2
            rx_symbol_location = 2;
        elseif real(rx_symbol) < 0 && imag(rx_symbol) < 0
            %Symbol decoded to fall in quadrant 3
            rx_symbol_location = 3;
        elseif real(rx_symbol) > 0 && imag(rx_symbol) < 0
            %Symbol decoded to fall in quadrant 4
            rx_symbol_location = 4;
        end
        
        %Compare tx_symbol quadrant to rx_symbol quadrant
        if tx_symbol_location ~= rx_symbol_location
            %Symbol error has occurred!
            symbol_errors = symbol_errors + 1;
        end
    end
end


% ===== CHECK FOR FALSE POSITIVES IN AUS_HAT ===== %
%We will do this using the union operator. If there is an element in
%AUS_hat that isn't in AUS, when we apply a union operator between the two,
%the result will have more elements than AUS originally had:
if length(union(AUS, AUS_hat)) > length(AUS)
    %Extra users in AUS_hat!
    AUS_false_positives = AUS_false_positives + (length(union(AUS, AUS_hat)) - length(AUS));
end


end

