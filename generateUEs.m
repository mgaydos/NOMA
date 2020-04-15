function UE_locations = generateUEs( avg_num_UEs, cell_radius, min_distance_to_BS )
%generateUEs: generates UE locations for MMT cell
%   We use the avg_num_UEs as the intensity for the PPP. This will return
%   us the number of users in our cell num_UEs. We will then generate that
%   number of users in polar coordinates. This will be done by generating
%   an angle, between 0 and 2pi num_UEs times. Then, a radial coordinates
%   will be generated between min_distance_to_BS and cell_radius. These
%   polar coordinates will be converted to cartesian.

% ===== GENERATE NUMBER OF UEs FOR SIMULATION ===== %
num_UEs = poissrnd(avg_num_UEs);

% ===== GENERATE POLAR COORDINATES ===== %
theta = 2*pi*rand(num_UEs, 1);
rho = min_distance_to_BS + (cell_radius - min_distance_to_BS) * rand(num_UEs, 1);

% ===== CONVERT TO CARTESIAN ===== %
[x, y] = pol2cart(theta, rho);

% ===== STORE IN SINGLE VARIABLE ===== %
UE_locations = zeros(num_UEs, 2);
UE_locations(:, 1) = x;
UE_locations(:, 2) = y;

end

