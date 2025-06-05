/*
    Gmsh script for a 2D rectangular domain with two circles inside.
    Boundary is assigned physical group id 2.
    Rectangle outside circles: Physical Surface 1
    Circle 1: Physical Surface 11
    Circle 2: Physical Surface 22
    Nodes: Physical Point 1 (rectangle), 11 (circle 1), 22 (circle 2)
*/

// ------------------------------------------ //
// ------------ PARAMETERS ------------------ //
// ------------------------------------------ //

// Parameters for rectangle size
lx = 2e-1;          // Length of rectangle in x-direction
ly = 2e-1;          // Length of rectangle in y-direction

// Rectangle center
cx = lx/2;
cy = ly/2;

// Parameters for circles
R1 = 5e-3;          // Radius of circle 1
R2 = 5e-3;          // Radius of circle 2
dist = 15e-3;       // Distance between circle centers
dist1 = -dist/2;    // Distance from rectangle center to circle 1 center
dist2 = dist/2;     // Distance from rectangle center to circle 2 center

// Refinement Parameters (cell dimensions)
Ref1 = R1*5e-3;         // Refinement at the boundary of circle 1
Ref2 = R2*5e-3;         // Refinement at the boundary of circle 2
Ref_center_1 = 9*Ref1;  // Refinement at the center of circle 1
Ref_center_2 = 9*Ref2;  // Refinement at the center of circle 2
Ref_rect = lx*5e-2;     // Refinement at the rectangle boundary


// ------------------------------------------ //
// ------------ IMPLEMENTATION -------------- //
// ------------------------------------------ //

// Rectangle corners
Point(1) = {0, 0, 0, Ref_rect};
Point(2) = {lx, 0, 0, Ref_rect};
Point(3) = {lx, ly, 0, Ref_rect};
Point(4) = {0, ly, 0, Ref_rect};

// Rectangle edges
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// Circle 1 center 
Point(10) = {cx + dist1, cy, 0, Ref_center_1};
// Circle 2 center 
Point(20) = {cx + dist2, cy, 0, Ref_center_2};

// Circle 1 points
Point(11) = {cx + dist1 + R1, cy, 0, Ref1};
Point(12) = {cx + dist1, cy + R1, 0, Ref1};
Point(13) = {cx + dist1 - R1, cy, 0, Ref1};
Point(14) = {cx + dist1, cy - R1, 0, Ref1};

// Circle 2 points
Point(21) = {cx + dist2 + R2, cy, 0, Ref2};
Point(22) = {cx + dist2, cy + R2, 0, Ref2};
Point(23) = {cx + dist2 - R2, cy, 0, Ref2};
Point(24) = {cx + dist2, cy - R2, 0, Ref2};

// Circle 1 arcs
Circle(101) = {11, 10, 12};
Circle(102) = {12, 10, 13};
Circle(103) = {13, 10, 14};
Circle(104) = {14, 10, 11};

// Circle 2 arcs
Circle(201) = {21, 20, 22};
Circle(202) = {22, 20, 23};
Circle(203) = {23, 20, 24};
Circle(204) = {24, 20, 21};

// Curve loops for circles
Curve Loop(11) = {101, 102, 103, 104};
Curve Loop(12) = {201, 202, 203, 204};

// Rectangle curve loop
Line Loop(1) = {1, 2, 3, 4};

// Surfaces
Plane Surface(1) = {1, 11, 12}; // Rectangle minus circles (outside)
Plane Surface(11) = {11};       // Circle 1
Plane Surface(22) = {12};       // Circle 2

// Assign boundaries to physical group 2
Physical Line(2) = {1, 2, 3, 4};

// Assign physical surfaces
Physical Surface(1) = {1};      // Rectangle outside circles
Physical Surface(11) = {11};    // Circle 1
Point{10} In Surface{11};
Physical Surface(22) = {22};    // Circle 2
Point{20} In Surface{22};

// Assign physical points for nodes
Physical Point(1) = {1, 2, 3, 4}; // Rectangle corners
Physical Point(11) = {10, 11, 12, 13, 14}; // Circle 1 center and points
Physical Point(22) = {20, 21, 22, 23, 24}; // Circle 2 center and points
