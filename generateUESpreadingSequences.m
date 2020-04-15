function seqs = generateUESpreadingSequences( num_UEs, N )
%generateUESpreadingSequences: generates N spreading sequences assigns
%spreading sequences to each UE. Typically, N < num_UEs.
%   The spreading sequences are walsh codes built from hadamard matrices.
%   As these are walsh codes, N must be a power of 2. We generate the code
%   by creating a hadamard matrix of order N, and then extracting each row
%   as a spreading sequence. We will need to generate two of these, as we
%   need to independent codes: one for the real component and one for the
%   imaginary component. Once we have obtained our 2N sequences, we will
%   assign a code to each user. However, we would like to assign the codes
%   such that each code is used an equal amount of times.

% ===== CREATE HADAMARD MATRIX ===== %
H_N = hadamard(N);


% ===== ASSIGN SPREADING SEQUENCES EVENLY AMONG ALL UEs ===== %
seqs = zeros(num_UEs, N);
walsh_code_index = 2;
for i=1:num_UEs
    seqs(i, :) = H_N(walsh_code_index, :);
    walsh_code_index = walsh_code_index + 1;
    if walsh_code_index > N
        walsh_code_index = 2;
    end
end

end

