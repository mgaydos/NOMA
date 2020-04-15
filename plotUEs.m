function plotUEs( UE_locations, cell_radius, min_distance_to_BS )
%plotUEs plots UEs, BS, and valid locations within cell
%   We plot the UE's as points and the BS in the center at 0,0. We then
%   plot a circle that encompasses the cell. Next, we plot the circle that
%   represents the minimum distance a UE can be from the BS.

% ===== PLOT UE LOCATIONS ===== %
hold on
plot(UE_locations(:, 1), UE_locations(:, 2), '.')

% ===== PLOT BS LOCATION ===== %
plot(0, 0, 'x')

% ===== FORM TWO CELL DEFINING CIRCLES ===== %
theta = 0:pi/100:2*pi;
cell_radius_x = cell_radius * cos(theta);
cell_radius_y = cell_radius * sin(theta);
min_radius_x = min_distance_to_BS * cos(theta);
min_radius_y = min_distance_to_BS * sin(theta);

% ===== PLOT CELL DEFINING CIRCLES ===== %
plot(cell_radius_x, cell_radius_y, 'b');
plot(min_radius_x, min_radius_y, 'b');

% ===== POSITION AXES TO BE IN MIDDLE OF SCREEN ===== %
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
hold off

end

