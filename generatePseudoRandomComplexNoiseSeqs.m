function seqs = generatePseudoRandomComplexNoiseSeqs( K, N )
%generatePseudoRandomComplexNoiseSeqs: Generates sequences of complex
%pseudorandom noise for K users of length N
%   Generating these sequences IID can be shown that for long sequence
%   lengths, there will be zero correlation. Thus the dot product bewteen
%   any two sequences that are not identical will tend towards zero as N
%   grows large. When a sequence is multiplied by itself, it yields a large
%   number. This can be shown to be roughly orthogonal between sequences.


seqs = 1/sqrt(2) * (randi([0, 1], N, K) - 0.5) * 2;


end
