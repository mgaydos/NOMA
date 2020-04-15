function seqs = generateToeplitzSpreadingMatrix( K, N )
%generateToeplitzSpreadingMatrix Summary of this function goes here
%   Detailed explanation goes here


% ===== GENERATE PSEUDO-RANDOM TOEPLITZ MATRIX ===== %
sigma = sqrt(1/K);
rand_vars = 1/sqrt(2)*((normrnd(0, sigma, N, 1)) + 1i*(normrnd(0, sigma, N, 1)));
toe = toeplitz(rand_vars);


% ===== ASSIGN SPREADING SEQUENCES EVENLY AMONG ALL UEs ===== %
seqs = zeros(K, N);
toe_index = 1;
for i=1:K
    seqs(i, :) = toe(toe_index, :);
    toe_index = toe_index + 1;
    if toe_index > N
        toe_index = 1;
    end
end

end

