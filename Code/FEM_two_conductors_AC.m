function [m, A, Js] = FEM_two_conductors_AC(mesh_file_name, freq, I_1, I_2, mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2, output_paraview)

  pkg load bim msh

  ## MESH PARAMETERS
  cell_id.external = 1;
  cell_id.bc  = 2;
  cell_id.conduct_1 = 11;
  cell_id.conduct_2 = 22;

  ## MESH LOADING
  disp('Loading data ...')
  source (mesh_file_name);
  m.p = msh.POS'([1 2], :);
  x = msh.POS(:, 1);
  y = msh.POS(:, 2);
  m.e = msh.LINES';
  m.e(5, :) = m.e(3, :);
  m.e(3, :) = 0;
  m.e(7, :) = 1;
  m.t = msh.TRIANGLES';
  % compute area of each element, and gradient of basis functions
  m = bim2c_mesh_properties (m);

  % Data struct m contains mesh elements, nodes, area of each element
  % and gradient of basis functions

  ## EXTRACT CONDUCTORS AND BOUNDARY CELLS
  [~, conduct_1_nodes, ~] = msh2m_submesh (m, [], cell_id.conduct_1);
  [~, conduct_2_nodes, ~] = msh2m_submesh (m, [], cell_id.conduct_2);
  bc_nodes = bim2c_unknowns_on_side (m, cell_id.bc);

  % conduct_1_nodes, conduct_2_nodes, bc_nodes are vectors containing
  % respectively the indices of 1st conductor, 2nd conductor, external boundary

  ## SETTING PARAMETERS
  omega = 2*pi*freq;  % is a scalar

  mu = ones(columns(m.p), 1) * mu_0;
  mu(conduct_1_nodes) = mu(conduct_1_nodes) * mu_r_1;
  mu(conduct_2_nodes) = mu(conduct_2_nodes) * mu_r_2;

  sigma = zeros(columns(m.p), 1);
  sigma(conduct_1_nodes) = sigma_C_1;
  sigma(conduct_2_nodes) = sigma_C_2;

  % mu and sigma are vectors containing respectively the values of mu and sigma
  % in the corresponding nodes

  ## ASSEMBPLING SYSTEM
  disp('Assembling system ...')

  S = bim2a_laplacian(m, 1, 1./mu);
  M = reaction_full(m, 1, -omega.*sigma.*i);

  f = bim2a_rhs(m, 1, 1);

  q_1 = zeros(columns(m.p), 1);
  q_1(conduct_1_nodes) = f(conduct_1_nodes);

  q_2 = zeros(columns(m.p), 1);
  q_2(conduct_2_nodes) = f(conduct_2_nodes);

  Q = [-omega.*sigma.*i.*q_1, -omega.*sigma.*i.*q_2];

  W = [-omega*sigma_C_1*i*sum(q_1), 0; 0, -omega*sigma_C_2*i*sum(q_2)];

  System = [S+M, Q; Q', W];
  Rhs = [zeros(columns(m.p), 1); I_1; I_2];

  ## SOLVE LINEAR SYSTEM
  disp('Solving system ...')

  internal_nodes = setdiff (1:numel(x)+2, bc_nodes);
  A_J = zeros(columns(m.p)+2, 1); % setup soultion vector

  % solve linear system applying omogeneous Dirichlet boundary conditions
  A_J(internal_nodes) = System(internal_nodes, internal_nodes) \
    (- System(internal_nodes, bc_nodes) * A_J(bc_nodes) + Rhs(internal_nodes));

  ## GET RESULTS
  A = A_J(1:end-2);
  Js = [ -omega*sigma_C_1*j*A_J(end-1); -omega*sigma_C_2*j*A_J(end)];

  J = -omega.*sigma.*i.*A;
  J(conduct_1_nodes) += Js(1);
  J(conduct_2_nodes) += Js(2);

  ## OUTPUT RESULTS
  if output_paraview % Output results to paraview using bim functions ...

    disp('Writing output ...')
    if !isfolder ("Results/")
      mkdir Results
    endif

    if isfile("Results/FEM_eddy_currents.vtu")
      delete Results/FEM_eddy_currents.vtu
    endif
    fpl_vtk_raw_write_field ("Results/FEM_eddy_currents", m, {real(A), "Re(A)"; imag(A), "Im(A)"; abs(A), "Abs(A)"; real(J), "Re(J)"; imag(J), "Im(J)"; abs(J), "Abs(J)"}, {});

    [conduct_mesh, conduct_nodes, ~] = msh2m_submesh (m, [], [cell_id.conduct_1, cell_id.conduct_2]);
    if isfile("Results/Eddy_currents.vtu")
      delete Results/Eddy_currents.vtu
    endif
    fpl_vtk_raw_write_field ("Results/Eddy_currents", conduct_mesh, {real(J(conduct_nodes)), "Re(J)"; imag(J(conduct_nodes)), "Im(J)"; abs(J(conduct_nodes)), "Abs(J)"}, {});

    [void_mesh, void_nodes, ~] = msh2m_submesh (m, [], cell_id.external);
    if isfile("Results/Magnetic_potential.vtu")
      delete Results/Magnetic_potential.vtu
    endif
    fpl_vtk_raw_write_field ("Results/Magnetic_potential", void_mesh, {real(A(void_nodes)), "Re(A)"; imag(A(void_nodes)), "Im(A)"; abs(A(void_nodes)), "Abs(A)"}, {});

  endif

 endfunction
