function [A, Js] = FEM_two_conductors_AC( mesh_file_name, freq, I_1, I_2, ...
                    mu_0, mu_r_1, mu_r_2, sigma_C_1, sigma_C_2, output_type)
  % Solve the eddy-current problem for two conductors at a given frequency.
  %
  % Inputs:
  %   mesh_file_name    : path to a .m mesh file generated by Gmsh
  %   freq              : excitation frequency [Hz]
  %   I_1, I_2          : total currents in conductors 1 and 2 [A]
  %   mu_0              : vacuum permeability [H/m]
  %   mu_r_1, mu_r_2    : relative permeabilities of conductors
  %   sigma_C_1, sigma_C_2 : conductivities of conductors [S/m]
  %   output_type       : can be "paraview" (results are written to .vtu files),
  %                       "octave" (results are plotted in Octave),
  %                       or "off" (no output is produced)
  %
  % Outputs:
  %   A               : nodal values of magnetic vector potential [T*m]
  %   Js              : source current density in each conductor [A/m^2]

  # LOAD PACKAGES
  try
    pkg load msh fpl bim
  catch
    disp(["Needed packages were not found, make shure to have bim ", ...
           "installed with the relative dependencies.\n", ...
           "To install them run:\n pkg -forge install splines msh fpl bim \n"]);
    A = NaN; Js = NaN; return;
  end_try_catch


  ## MESH PARAMETERS
  %--- Define region identifiers in the Gmsh .m file
  cell_id.external = 1;     % outer domain tag
  cell_id.bc  = 2;          % outer boundary tag
  cell_id.conduct_1 = 11;   % first conductor tag
  cell_id.conduct_2 = 22;   % second conductor tag


  ## MESH LOADING
  disp('Loading data ...')
  source (mesh_file_name);

  %--- Build octave mesh structure 'm'
  m.p = msh.POS'([1 2], :); % mesh nodes coordinates as 2xN
  x = msh.POS(:, 1);        % x-coordinates
  y = msh.POS(:, 2);        % y-coordinates
  m.e = msh.LINES';         % mesh edges
  % (reformat Gmsh linedata to match bim format)
  m.e(5, :) = m.e(3, :); m.e(3, :) = 0; m.e(7, :) = 1;
  m.t = msh.TRIANGLES';     % mesh elements (mesh triangles)

  %--- compute area of each element (m.area), wheigh_i*det(Jacobian) in each
  %    node of each element (m.wjacdet), and gradient of basis functions (m.shg)
  m = bim2c_mesh_properties (m);

  Nnodes = columns(m.p);  % Total number of nodes in the mesh
  Nelem = columns(m.t);   % Total number of elements in the mesh


  ## EXTRACT CONDUCTORS AND BOUNDARY CELLS AND NODES
  % conduct_1_nodes, conduct_2_nodes, bc_nodes are vectors containing respectively
  % the indices of the nodes in 1st conductor, 2nd conductor, external boundary.
  % While conduct_1_elem, conduct_2_elem are vectors containing respectively
  % the indices of the elements in 1st and 2nd conductor
  [~, conduct_1_nodes, conduct_1_elem] = msh2m_submesh (m, [], cell_id.conduct_1);
  [~, conduct_2_nodes, conduct_2_elem] = msh2m_submesh (m, [], cell_id.conduct_2);
  bc_nodes = bim2c_unknowns_on_side (m, cell_id.bc);


  ## SETTING PARAMETERS
  omega = 2*pi*freq;  % angular frequency, is a scalar

  %--- Build element mu vector: mu0 in external region, mu_0*mu_r in conductors
  mu = ones(Nelem, 1) * mu_0;
  mu(conduct_1_elem) = mu(conduct_1_elem) * mu_r_1;
  mu(conduct_2_elem) = mu(conduct_2_elem) * mu_r_2;

  %--- Build element indicator function for conductors
  ones_c_1 = zeros(Nelem, 1);
  ones_c_1(conduct_1_elem) = 1;
  ones_c_2 = zeros(Nelem, 1);
  ones_c_2(conduct_2_elem) = 1;

  %--- Build element sigma vector: 0 in external region, sigma_C in conductors
  sigma = sigma_C_1 * ones_c_1 + sigma_C_2 * ones_c_2;


  ## ASSEMBPLING SYSTEM
  disp('Assembling system ...')

  S = bim2a_laplacian(m, 1./mu, 1);           % Laplacian matrix with mu as coefficient

  M = reaction_full(m, omega.*sigma.*i, 1);   % Full mass matrix with sigma as coefficient

  q_1 = bim2a_rhs(m, ones_c_1, 1);            % conductor 1 specific source vector

  q_2 = bim2a_rhs(m, ones_c_2, 1);            % conductor 2 specific source vector

  Q = [omega.*sigma_C_1.*i.*q_1, omega.*sigma_C_2.*i.*q_2]; % om * sigma * j * Q

  W = [omega*sigma_C_1*i*sum(q_1), 0; 0, omega*sigma_C_2*i*sum(q_2)]; % om * sigma * j * W
  % sum(q_1) and sum(q_2) are the areas of the conductors

  %--- Assemble global system
  System = [S+M, Q; Q.', W];
  Rhs = [zeros(Nnodes, 1); -I_1; -I_2];


  ## SOLVE LINEAR SYSTEM
  disp('Solving system ...')

  % Internal nodes are all nodes except the boundary nodes, with the addition of
  % the two unknowns for the source magnetic vector potential in the conductors
  internal_nodes = setdiff (1:Nnodes + 2, bc_nodes);
  A_J = zeros(Nnodes + 2, 1);   % setup solution vector

  % solve linear system applying omogeneous Dirichlet boundary conditions
  A_J(internal_nodes) = System(internal_nodes, internal_nodes) \ Rhs(internal_nodes);

  ## GET RESULTS
  %--- Split solution into A (first N) and As (last 2)
  A = A_J(1:end-2);
  Js = [-omega * sigma_C_1 * i * A_J(end-1); -omega * sigma_C_2 * i * A_J(end)];

  %--- Compute current density J = -omega*sigma*i*A
  J = zeros(size(A));
  J(conduct_1_nodes) = -omega * sigma_C_1 * i * A(conduct_1_nodes) + Js(1);
  J(conduct_2_nodes) = -omega * sigma_C_2 * i * A(conduct_2_nodes) + Js(2);


  ## OUTPUT RESULTS
  if strcmp(output_type, "paraview") % Output results to paraview using fpl functions ...

    disp('Writing output to paraview ...')
    if !isfolder ("Results/")
      mkdir Results
    endif

    if isfile("Results/FEM_eddy_currents.vtu")
      delete Results/FEM_eddy_currents.vtu
    endif
    fpl_vtk_raw_write_field ("Results/FEM_eddy_currents", m, ...
        {real(A), "Re(A)"; imag(A), "Im(A)"; abs(A), "Abs(A)"; real(J), "Re(J)"; imag(J), "Im(J)"; abs(J), "Abs(J)"}, {});

    [conduct_mesh, conduct_nodes, ~] = msh2m_submesh (m, [], [cell_id.conduct_1, cell_id.conduct_2]);
    if isfile("Results/Current_density.vtu")
      delete Results/Current_density.vtu
    endif
    fpl_vtk_raw_write_field ("Results/Current_density", conduct_mesh, ...
        {real(J(conduct_nodes)), "Re(J)"; imag(J(conduct_nodes)), "Im(J)"; abs(J(conduct_nodes)), "Abs(J)"}, {});


  elseif strcmp(output_type, "octave") % Plot results using patch function of octave ...

    disp('Plotting output with octave ...')

    figure;
    patch('Faces', m.t'(:,1:3), 'Vertices', [x, y], ...
          'FaceVertexCData', abs(A), 'FaceColor', 'interp', 'EdgeColor', 'none');
    title("Magnetic vector potential magnitude");
    xlabel("x"); ylabel("y");
    axis equal tight;
    colorbar;

    figure;
    [conduct_mesh, conduct_nodes, ~] = msh2m_submesh (m, [], [cell_id.conduct_1, cell_id.conduct_2]);
    patch('Faces', conduct_mesh.t'(:,1:3), 'Vertices', [x(conduct_nodes), y(conduct_nodes)], ...
          'FaceVertexCData', abs(J(conduct_nodes)), 'FaceColor', 'interp', 'EdgeColor', 'none');
    title("Current density magnitude in the conductors");
    xlabel("x"); ylabel("y");
    axis equal tight;
    colorbar;

  elseif ! strcmp(output_type, "off") % Invalid output tag

    disp("Warning: Unrecognized output type, no output is produced!")

  endif

 endfunction
