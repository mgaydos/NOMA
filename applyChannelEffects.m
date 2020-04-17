function [ Y, H, G ] = applyChannelEffects( X, spreading_sequences, SNR_dB )
%applyChannelEffects: modulate signals onto spreading sequences and
%simulate transmission across channel by applying channel gain and AWGN.
%   First, we generate the channel gains for each subchannel for each user.
%   These values will not change across our J time slots; the channel will
%   not change over this frame. This is because we are assuming that this
%   simulation will follow a block fading model. It is assumed that our
%   channel uses an OFDM system which has N subchannels, where N is also
%   the length of the spreading sequence. Each user will send on chip
%   across each of the N subchannels. Thus, each user will have N channel
%   realizations, one for each subchannel. This will yield a num_UEs X N
%   size channel gains matrix. Next, we will spread the transmitted symbol
%   across each N subchannels, and apply the appropriate channel gain. We
%   then add up the sum of what is received at each subchannel from each
%   user. We do this for all J time slots. Lastly, we apply the complex 
%   AWGN. The symbol was originally transmitted with unit power, so we
%   scale the noise power to achieve the desired transmission SNR. As each
%   subchannel on each time slot will have independent noise, we generate
%   an N x J noise matrix of appropriate power and add it to our received
%   symbol matrix Y.


% ===== INITS ===== %
%Extract Data
num_UEs = size(X, 1);                   %number of total UE's
J = size(X, 2);                         %number of time slots in a frame
N = size(spreading_sequences, 1);       %length of spreading sequence


% ===== GENERATE BLOCK FADING CHANNEL REALIZATIONS FOR EACH USER'S N SUBCHANNELS ===== %
%The channel gains will not change over time (across any of the J time
%slots in this frame) becasue we are assuming a block fading channel
H = 1/sqrt(2) * (randn(N, num_UEs) + 1i*randn(N, num_UEs));
G = H .* spreading_sequences;


% ===== APPLY ADDITIVE WHITE GAUSSIAN NOISE ===== %
%We must add this AWGN and keep its power in mind with respect to the
%desired SNR. Each subchannel at each time slot will experience its own
%independent complex noise.
%Generate compplex normalized gaussian noise with variance 1:
Z_norm = 1/sqrt(2) * (randn(N, J) + 1i*randn(N, J));
%Scale noise to acheive desired SNR:
SNR = 10^(SNR_dB/10);
sigma = 1/sqrt(SNR);
Z = sigma * Z_norm;


% ===== APPLY CHANNEL EFFECTS AND NOISE FOR EACH TIME SLOT IN FRAME ===== %
%Apply effects of spreading sequence, complex channel gain, and AWGN across
%all J time frames
Y = G * X + Z;

end