clear

% PHYSICAL PARAMETERS
I_1 = 1;
I_2 = -1;
freq = 1e3;

sigma_C_1 = 58e6;     % conductivity of conductor 1
sigma_C_2 = sigma_C_1;  % conductivity of conductor 2

mu_0 = 4*pi*1e-7;
mu_r_1 = 1;   % permeabilities of conductors
mu_r_2 = 1;

mesh_file_name = "mesh_two_circ_cond.m";
output_paraview = true;

[m, A, Js] = FEM_two_conductors_AC(mesh_file_name, freq, I_1, I_2, mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2, output_paraview);

[Z_self_1, Z_self_2, Z_mut12, Z_mut21] = FEM_impedance_two_conductors(mesh_file_name, freq, mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2);

R_11 = real(Z_self_1)   % Teor: R_11 = 3.74978e-4
L_11 = imag(Z_self_1)/(2*pi*freq) % Teor: L_11 = 2.45522e-07





