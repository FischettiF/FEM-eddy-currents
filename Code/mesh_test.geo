/*
    Gmsh script for a 2D rectangular domain with variable edge lengths.
    Boundary is assigned physical group id 11.
*/

// Parameters for rectangle size
lx = 1.0; // length in x-direction
ly = 0.5; // length in y-direction

// Corner points
Point(1) = {0, 0, 0, 1.0};
Point(2) = {lx, 0, 0, 1.0};
Point(3) = {lx, ly, 0, 1.0};
Point(4) = {0, ly, 0, 1.0};

// Rectangle edges
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// Curve loop and surface
Line Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

// Assign all boundaries to physical group 11
Physical Line(11) = {1, 2, 3, 4};
Physical Surface("Domain") = {1};