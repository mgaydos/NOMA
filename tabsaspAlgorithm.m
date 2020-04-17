function [ X_hat, AUS_hat ] = tabsaspAlgorithm( Y, G, noise_threshold )
%tabsaspAlgorithm: we use the threshold aided block sparse adaptive
%subspace pursuit (TA-BSASP) algorithm to find the best estimate of the
%transmitted signals X.
%   First, we will transform the matrices Y and G to a form that will
%   enable us to make full use of the block sparsity model.


% ===== VARIABLE INITS ===== %
N = size(Y, 1);
J = size(Y, 2);
K = size(G, 2);


% ===== TRANSFORM Y AND G ===== %
%Convert Y to a vector 'p' where we count 1 to N, J times, such that:
%p = [Y(1,1),Y(1,2),...,Y(1,J),Y(2,1),...,Y(2,J),...,Y(N,1),...,Y(N,J)]
%This implies p is a (N*J) x 1 vector.
%Covnert G to a matrix 'D' such that D = G (X) I_J, where (X) is the
%kronecker product and I_J is the identity matrix of dimensions JxJ. This
%implies that D will be a (N*J) x (K*J).
p = reshape(Y.', N*J, 1);
D = kron(G, eye(J));


% ===== TA-BSASP INITS ===== %
loop_control = 1;               %loop control var
gamma = [];                     %support set
gamma_hat = [];                 %current estimate of support set
gamma_hat_prev = gamma_hat;     %estimate of previous iteration's support set
r = p;                          %residue signal
r_prev = r;                     %residue signal from previous iteration
c_estimate = zeros(K*J, 1);     %estimated transmitted signal
c_estimate_prev = c_estimate;   %previous iterations estimated transmitted signal
c_hat_s = c_estimate;           %estimated transmitted signal for current sparsity level
c_hat_s_prev = c_hat_s;         %estimated transmitted signal for previous sparsity level
gamma_hat_s = [];               %estimated support set for c_hat_s
gamma_hat_s_prev = gamma_hat_s; %estimated support set for c_hat_s_prev
s = 1;                          %sparsity level
D_H = D';                       %Hermitian transpose of D


% ===== BEGIN ITERATIVE TA-BSASP CALCULATIONS ===== %
while loop_control
    
    % ===== SUPPORT ESTIMATE ===== %
    %Multiply residual signal by hermitian transposed channel estimate for
    %each user and take l2-norm. Add to xi set for further operation. We
    %will be considering the previous iteration's residual signal, as we
    %are exploiting the block-sparse framework.
    xi_set = zeros(1, K);
    for k=1:K
        a = (k - 1)*J + 1;      %start index for D_H[k]
        b = k*J;                %end index for D_H[k]
        xi_set(k) = norm(D_H(a:b, 1:J*N)*r_prev);
    end
    
    %Find the indices (or users) of the s largest values in the xi set,
    %where s is the user sparsity, or how many users we predict are
    %transmitting:
    [~, sorted_indices] = sort(xi_set, 'descend');
    xi_results = sorted_indices(1:s);
    
    %Add selected users to the previous iterations support set
    lambda = union(gamma, xi_results);
    
    % ===== LEAST SQUARES (LS) ESTIMATE ===== %
    %Initialize the least squares estimate to be zero. We will only
    %calculate the users that we suspect are transmitting, ie the users in
    %our current support set lambda, and leave the users we suspect are not
    %transmitting to be 0.
    w = zeros(K*J, 1);
    D_active = zeros(N*J, J*length(lambda));
    
    %Iterate over all members of lambda to create channel realization sub
    %matrix D_active:
    for i=1:length(lambda)
        
        %Generate appropriate indices of D such that we only evaluate over
        %D[lambda], where lambda is our support set
        D_row = 1:N*J;
        D_col = ((lambda(i) - 1)*J + 1):(lambda(i)*J);
    
        %Append estimated support user channel realization information to
        %end of channel sub matrix
        D_active_start = (i - 1)*J + 1;
        D_active_stop = i*J;
        D_active(:,D_active_start:D_active_stop)  = D(D_row, D_col);
    end
    
    %Calculate least squares estimate:
    w_active = pinv(D_active) * p;
    
    %Assign least square estimates to appropriate users:
    for i=1:length(lambda)
        
        %Generate appropriate indices of w and D such that the 
        w_start = ((lambda(i) - 1)*J + 1);
        w_stop = lambda(i)*J;
        w_active_start = (i - 1)*J + 1;
        w_active_stop = i*J;
        
        %Assign values
        w(w_start:w_stop) = w_active(w_active_start:w_active_stop);
    end
        
    
    % ===== SUPPORT PRUNING ===== %
    %Find the estimate of our support set gamma_hat such that we maintain
    %the appropriate estimated level of current sparsity s. This is
    %accomplished by first taking the l2-norm of the LS-estimate across all
    %users, and then finding the s users with the highest result. These
    %users are added to the gamma_hat set.
    w_l2_set = zeros(1, K);
    for m=1:length(lambda)
        %Generate correct start and stop indices for w:
        w_start = ((lambda(m) - 1)*J + 1);
        w_stop = lambda(m)*J;
        w_l2_set(lambda(m)) = norm(w(w_start:w_stop));
    end
    [~, w_sorted_indices] = sort(w_l2_set, 'descend');
    gamma_hat = w_sorted_indices(1:s);
    
    
    % ===== SIGNAL ESTIMATE ===== %
    %Here, we will estimate the transmitted signal based off of our
    %estimated support set gamma_hat. This is accomplished by using the
    %Moore-Pen Pseudo-Inverse of the channel matrix D times the received
    %signals, but only on users in our estimated support set. All other
    %users are estimated as 0.
    %Save previous estimate of c_estimate and init new estimate to all
    %zeros:
    c_estimate = zeros(K*J, 1);
    D_active = zeros(N*J, J*length(gamma_hat));
    
    %Iterate over all members of gamma_hat:
    for i=1:length(gamma_hat)
        %First, we will find the indices that correspond to the users in the
        %estimated support set gamma_hat in D:
        rows = 1:N*J;
        cols = ((gamma_hat(i) - 1)*J + 1):(gamma_hat(i)*J);
        
        %Append channel realization of estimated member of AUS to active
        %users channel realization D_active:
        D_active_start = (i - 1)*J + 1;
        D_active_stop = i*J;
        D_active(:, D_active_start:D_active_stop) = D(rows, cols); 
    end
    
    %Estimate signal:
    c_est_active = pinv(D_active) * p;
    
    %Assign estimated signal to appropriate members:
    for i=1:length(gamma_hat)
        
        %Generate appropriate indices of c_estimated such that we store in
        %correct user
        c_start = ((gamma_hat(i) - 1)*J + 1);
        c_stop = gamma_hat(i)*J;
        c_est_start = (i - 1)*J + 1;
        c_est_stop = i*J;
    
        %Next, we solve for the estimated transmitted signal:
        c_estimate(c_start:c_stop) = c_est_active(c_est_start:c_est_stop);
    end
        
    
    % ===== RESIDUE SIGNAL UPDATE ===== %
    %Now that we have estimated what we have transmitted, lets update the
    %residue signal:
    r = p - D*c_estimate;
    
    
    % ===== CHECK IF WE HAVE DECREASED POWER IN RESIDUE SIGNAL ===== %
    %Compare the power of the residue signal after this rounds iteration of
    %estimating transmitted signals with last rounds residue signal power.
    if norm(r) < norm(r_prev)
        
        % ===== POWER DECREASED BETWEEN ROUNDS ===== %
        %We assume that our current sparsity level is correct, and we allow
        %it to remain fixed. We update the support set from the estimated
        %support set
        gamma = gamma_hat;
        gamma_hat_prev = gamma_hat;
        c_estimate_prev = c_estimate;
        r_prev = r;
    
    else
        
        % ===== POWER DID NOT DECREASE BETWEEN ROUNDS ===== %
        %Because residue power did not decrease, we will assume that we
        %have limited our sparsity too much. We will increment sparsity by
        %one. This means we will consider one potential additional user who
        %encoded data into Y's original received signal. We will also save
        %the current estimated transmitted signal c_estimated as well as
        %the current estimated support set. We do this because we may
        %increment the sparsity and read in noise, which would be
        %incorrect, so we need to maintain a record of the last valid
        %'good' estimated transmitted signal.
        
        %Save estimated transmitted symbols for last sparsity level
        c_hat_s_prev = c_hat_s;
        %Save estimated support set for last sparsity level
        gamma_hat_s_prev = gamma_hat_s;
        
        %Increment Sparsity Level
        s = s + 1;
        
        %Save the last estimated symbols
        c_hat_s = c_estimate_prev;
        %Save the last estimated support set        
        gamma_hat_s = gamma_hat_prev;
    end
    
    
    % ===== CHECK NOISE FLOOR THRESHOLD CONDITION ===== %
    %c_estimate contains the estimated transmitted symbol for s users. We
    %want to ensure that we decode as many messages as we possibly can. If
    %we terminate early, we may be missing messages, but if we continue
    %trying to decode messages, we may be making messages out of the noise
    %floor. This is not intended, so, we analyze the power of the estimated
    %transmitted symbols of c for each user in our estimated active set
    %gamma_hat. If we find that the power associated with this estimated
    %message is lower than the noise floor, we say that we have gone too
    %high in our sparsity level. This is our terminating condition, and we
    %use the last valid sparisty measure.
    
    %Obtain power measure of estimated transmitted symbol for each user in
    %the estimated support set gamma_hat:
    c_power = zeros(1, length(gamma_hat));
    for m=1:length(gamma_hat)
        %first obtain correct start and stop indices for indexing
        %c_estimate
        c_start_index = (gamma_hat(m) - 1)*J + 1;
        c_stop_index = (gamma_hat(m))*J;
        
        %add estimated active user m estimated transmit symbol power
        %calculation to c_power set
        c_power(m) = norm(c_estimate(c_start_index:c_stop_index))^2;
    end
    
    %compare minimum power to noise threshold
    if min(c_power) <= J*noise_threshold
        
        % ===== SIGNAL CONSTRUCTED FROM NOISE ===== %
        %Exit loop
        loop_control = 0;
    end
    
    
    % ===== FORCE EXIT AS SPARSITY > TOTAL USERS ===== %
    %In very poor environments where the noise is very powerful, we may
    %detect everything as a valid user. If sparsity exceeds total users,
    %exit!
    if s > K
        loop_control = 0;
    end
end


% ===== BACK OFF BY ONE LEVEL OF SPARSITY ===== %
c_hat = c_hat_s;
AUS_hat = sort(gamma_hat_s)';


% ===== FORM X_HAT ===== %
X_hat = reshape(c_hat, J, K).';

end

