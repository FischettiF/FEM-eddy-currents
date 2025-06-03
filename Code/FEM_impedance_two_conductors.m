function [Z_self_1, Z_self_2, Z_mut12, Z_mut21] = FEM_impedance_two_conductors(mesh_file_name, freq, mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2)

  output_paraview = false;

  % IMPEDANCE ON 1
  I_1 = 1;
  I_2 = 0;
  [~, A, Js] = FEM_two_conductors_AC(mesh_file_name, freq, I_1, I_2, mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2, output_paraview);

  Z_self_1 = Js(1) / (sigma_C_1 * I_1);
  Z_mut12 = Js(2) / (sigma_C_2 * I_1);


  % IMPEDANCE ON 2
  I_1 = 0;
  I_2 = 1;
  [~, A, Js] = FEM_two_conductors_AC(mesh_file_name, freq, I_1, I_2, mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2, output_paraview);

  Z_self_2 = Js(2) / (sigma_C_2 * I_2);
  Z_mut21 = Js(1) / (sigma_C_1 * I_2);

 endfunction
