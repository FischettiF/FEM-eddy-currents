clear

## PHYSICAL PARAMETERS

I_1 = 1;                % current in conductor 1
I_2 = -1;               % current in conductor 2
freq = 1e3;             % frequency

sigma_C_1 = 58e6;       % conductivity of conductor 1
sigma_C_2 = sigma_C_1;  % conductivity of conductor 2

mu_0 = 4*pi*1e-7;
mu_r_1 = 1;             % permeability of conductor 1
mu_r_2 = 1;             % permeability of conductor 1

mesh_file_name = "mesh_two_circ_cond.m";

output_type = "paraview";  % The options are: "octave", "paraview", "off"
% For performance reasons (expecially with fine meshes) the option "paraview" is recommended if the software is available

[A, Js] = FEM_two_conductors_AC(mesh_file_name, freq, I_1, I_2, mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2, output_type);

