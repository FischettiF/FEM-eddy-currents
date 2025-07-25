clear

## SETTABLE PARAMETERS

sigma_C = 58e6;         % conductivity of both conductors [S/m]

mu_0 = 4*pi*1e-7;       % vacuum permeability [H/m]
mu_r_1 = 1;             % permeability of conductor 1
mu_r_2 = 1;             % permeability of conductor 2

freq_list = logspace(3, 6, 7);  % analyzed frequencies [Hz]

% Parameters that need to be consistent with the mesh (copy from .geo file)
mesh_file_name = "mesh_two_circ_cond.m";
radius = 5e-3;                % Radius of both conductors [m]
dist = 15e-3;                 % Distance between circle centers [m]
Ref_bound_C = radius*5e-3;    % Mesh refinement at the boundary of conductors [m]
Ref_center_C = 9*Ref_bound_C; % Mesh refinement at the center of conductors [m]


## COMPUTATIONS

I_1 = 1;
I_2 = -1;

R_fem = zeros(size(freq_list)); L_fem = zeros(size(freq_list));
R_an = zeros(size(freq_list)); L_an = zeros(size(freq_list));

for n_f = 1:numel(freq_list)

  freq = freq_list(n_f);
  printf("Currently computed frequency: %d \n", freq);

  % numerical solution
  [~, Js] = FEM_two_conductors_AC(mesh_file_name, freq, I_1, I_2, mu_0, mu_r_1, mu_r_2, sigma_C, sigma_C, "off");
  Z_self_1 = Js(1) / (sigma_C * I_1);
  R_fem(n_f) = real(Z_self_1);
  L_fem(n_f) = imag(Z_self_1)/(2*pi*freq);

  % analitycal solution
  [R_an(n_f), L_an(n_f)]= analytical_two_circular_conductors (radius, dist, sigma_C, mu_r_1, mu_r_2, freq);

endfor

error_R = 100*(R_fem-R_an)./R_an;
error_L = 100*(L_fem-L_an)./L_an;

## PLOTS

figure;
delta = (pi * freq_list * sigma_C * mu_0 * mu_r_1).^(-1/2); % [m]
loglog(freq_list, delta, "linewidth", 2, freq_list, Ref_bound_C*ones(size(freq_list)), "linewidth", 2);
xlabel("Frequency [Hz]");
ylabel("Length [m]");
legend("Skin depth", "Mesh dimension at boundary of the conductors");
title("Skin depth and mesh dimension (log-log scale)")
set(gca, "fontsize", 15)
grid on

figure;
loglog(freq_list, abs(error_R), "linewidth", 2, 's-k', freq_list, abs(error_L), "linewidth", 2, 'o-r');
xlabel("Frequency [Hz]");
ylabel("Relative error [%]");
legend({"Error on resistance", "Error on inductance"}, "location", "southeast");
title("Relative error on resistance and inductance (log-log scale)")
set(gca, "fontsize", 15)
grid on



