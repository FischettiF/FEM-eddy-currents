clear
pkg load bim msh

external_id = 1;
bc_id  = 2;
conduct_1_id = 11;
conduct_2_id = 22;

source ("mesh_1.m");
m.p = msh.POS'([1 2], :);
x = msh.POS(:, 1);
y = msh.POS(:, 2);
m.e = msh.LINES';
m.e(5, :) = m.e(3, :);
m.e(3, :) = 0;
m.e(7, :) = 1;
m.t = msh.TRIANGLES';

m = bim2c_mesh_properties (m);

[~, conduct_1_nodes, ~] = msh2m_submesh (m, [],conduct_1_id);
[~, conduct_2_nodes, ~] = msh2m_submesh (m, [],conduct_2_id);

bc_nodes = bim2c_unknowns_on_side (m, bc_id);

%[~, external_nodes, ~] = msh2m_submesh (m, [], external_id);

edir = [0;0];
test = m.p' * edir;
%test(conduct_1_nodes) = 1;
%test(conduct_2_nodes) = 2;

%fpl_vtk_raw_write_field ("ddtest", m, {test, "test"}, {});

