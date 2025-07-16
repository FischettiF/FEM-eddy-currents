clear

## PHYSICAL PARAMETERS

I_1 = 5;                % current in conductor 1
I_2 = -5;               % current in conductor 2
freq = 1e3;             % frequency

sigma_C_1 = 58e6;       % conductivity of conductor 1
sigma_C_2 = sigma_C_1;  % conductivity of conductor 2

mu_0 = 4*pi*1e-7;
mu_r_1 = 1;             % permeability of conductor 1
mu_r_2 = 1;             % permeability of conductor 1

mesh_file_name = "mesh_two_circ_cond.m";

output_type = "octave";  % The options are: "octave", "paraview", "off"
% To avoid possible visual bugs and obtain a better quality of the results,
% the option "paraview" is recommended if the software is available

[A, Js] = FEM_two_conductors_AC(mesh_file_name, freq, I_1, I_2, mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2, output_type);

[Z_self_1, Z_self_2, Z_mut12, Z_mut21] = FEM_impedance_two_conductors(mesh_file_name, freq, mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2);

R_11 = real(Z_self_1)   % Teor: R_11 = 3.74978e-4
L_11 = imag(Z_self_1)/(2*pi*freq) % Teor: L_11 = 2.45522e-07


