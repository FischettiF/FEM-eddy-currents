clear
pkg load bim msh


% PARAMETERS
I_1 = 1e2;
I_2 = -5e2;
frequence = 1e3;

sigma_C_1 = 58e6;     % conductivity of conductor 1
sigma_C_2 = sigma_C_1;  % conductivity of conductor 2

mu_0 = 4*pi*1e-7;
mu_r_1 = 1;   % permeabilities of conductors
mu_r_2 = 1;

omega = 2*pi*frequence;


% MESH PARAMETERS
external_id = 1;
bc_id  = 2;
conduct_1_id = 11;
conduct_2_id = 22;
source ("mesh_two_circ_cond.m");


% MESH LOADING
disp('Loading data ...')

m.p = msh.POS'([1 2], :);
x = msh.POS(:, 1);
y = msh.POS(:, 2);
m.e = msh.LINES';
m.e(5, :) = m.e(3, :);
m.e(3, :) = 0;
m.e(7, :) = 1;
m.t = msh.TRIANGLES';

m = bim2c_mesh_properties (m);

[~, conduct_1_nodes, ~] = msh2m_submesh (m, [], conduct_1_id);
[~, conduct_2_nodes, ~] = msh2m_submesh (m, [], conduct_2_id);

bc_nodes = bim2c_unknowns_on_side (m, bc_id);


% SETTING INDICATORS OF CONDUCTORS
id_1 = zeros(columns(m.p), 1);
id_1(conduct_1_nodes) = 1;

id_2 = zeros(columns(m.p), 1);
id_2(conduct_2_nodes) = 1;

mu = ones(columns(m.p), 1)*mu_0;
mu(conduct_1_nodes) = mu(conduct_1_nodes) * mu_r_1;
mu(conduct_2_nodes) = mu(conduct_2_nodes) * mu_r_2;

sigma = zeros(columns(m.p), 1);
sigma(conduct_1_nodes) = sigma_C_1;
sigma(conduct_2_nodes) = sigma_C_2;


% ASSEMBPLING SYSTEM
disp('Assembling system ...')

S = bim2a_laplacian(m, 1, 1./mu);
T = bim2a_reaction(m, 1, omega.*sigma.*i);

##f = bim2a_rhs(m, 1, 1);
##
##q_1 = zeros(columns(m.p), 1);
##q_1(conduct_1_nodes) = f(conduct_1_nodes);
##
##q_2 = zeros(columns(m.p), 1);
##q_2(conduct_2_nodes) = f(conduct_2_nodes);
q_1 = bim2a_rhs(m, 1, id_1);
q_2 = bim2a_rhs(m, 1, id_2);

Q = [-omega.*sigma.*i.*q_1, -omega.*sigma.*i.*q_2];

W = [sum(q_1), 0; 0, sum(q_2)];

System = [S+T, Q; Q', W];
Rhs = [zeros(columns(m.p), 1); I_1; I_2];


% SOLVE LINEAR SYSTEM

disp('Solving system ...')
% A_J = System \ Rhs; % no BC case

internal_nodes = setdiff (1:numel(x)+2, bc_nodes);
A_J = zeros(columns(m.p)+2, 1);
A_J(internal_nodes) = System(internal_nodes, internal_nodes) \ (- System(internal_nodes, bc_nodes) * A_J(bc_nodes) + Rhs(internal_nodes));


% OUTPUT RESULTS
A = A_J(1:end-2);
J = -omega.*sigma.*i.*A;
J(conduct_1_nodes) += A_J(end-1);
J(conduct_2_nodes) += A_J(end);

disp('Writing output ...')

delete FEM_eddy_currents.vtu
fpl_vtk_raw_write_field ("FEM_eddy_currents", m, {real(A), "Re(A)"; imag(A), "Im(A)"; abs(A), "Abs(A)"; real(J), "Re(J)"; imag(J), "Im(J)"; abs(J), "Abs(J)"}, {});

[conduct_mesh, conduct_nodes, ~] = msh2m_submesh (m, [], [conduct_1_id, conduct_2_id]);
delete Eddy_currents.vtu
fpl_vtk_raw_write_field ("Eddy_currents", conduct_mesh, {real(J(conduct_nodes)), "Re(J)"; imag(J(conduct_nodes)), "Im(J)"; abs(J(conduct_nodes)), "Abs(J)"}, {});

[void_mesh, void_nodes, ~] = msh2m_submesh (m, [], external_id);
delete Magnetic_potential.vtu
fpl_vtk_raw_write_field ("Magnetic_potential", void_mesh, {real(A(void_nodes)), "Re(A)"; imag(A(void_nodes)), "Im(A)"; abs(A(void_nodes)), "Abs(A)"}, {});



