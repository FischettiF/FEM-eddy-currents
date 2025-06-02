//+SetFactory("Built-in");
//----------------------------------------------------------------------------//
//---------------------USER-DEFINED-INPUT-------------------------------------//
//----------------------------------------------------------------------------//

// Geometrical Input
R_COND_1 = 15e-2;         // Conductor 1
R_COND_2 = 15e-2;         // Conductor 2
GAP=45e-2;                // Gap between collectors
shift=0;
n_emi = 1;
n_coll = 1;

Ly = 1;                 // Domain HEIGHT (twice)
Lx = 1;                   // Domain Lenght


//Control
REF_EMI=5e-3;
REF_COLL=6e-3;
MSIZE_OUT =1e-1;

CONTROL_REFINE_COLLECTOR=1.5e-3;
CONTROL_REFINE_INNER_EMI=2e-5;
CONTROL_REFINE_OUTER_EMI=1e-4;

SIZE_BL_COLL=0.5*R_COND_2;
SIZE_BL_EMI=R_COND_1;

R_OUTER_COLL=2*R_COND_2;
R_INNER_EMI=10*R_COND_1;
R_OUTER_EMI=25*R_COND_1;

Y_E=0;// y coordinate of the emitter
Y_C=0;// y coordinate of the collector

//------------------------------------------------------------------------------//
//------Macros------------------------------------------------------------------//
//------------------------------------------------------------------------------//
Macro EMITTER

    p1 = newp; Point(p1) = {x,      y,      0,  ref_emi*10};
    p2 = newp; Point(p2) = {x-re,   y,      0,  ref_emi};
    p3 = newp; Point(p3) = {x,      y-re,   0,  ref_emi};
    p4 = newp; Point(p4) = {x+re,   y,      0,  ref_emi};
    p5 = newp; Point(p5) = {x,      y+re,   0,  ref_emi};
    
    c1 = newc; Circle(c1) = {p2,p1,p3}; c2 = newc; Circle(c2) = {p3,p1,p4};
    c3 = newc; Circle(c3) = {p4,p1,p5}; c4 = newc; Circle(c4) = {p5,p1,p2};
    emitter_center[n_emi]=p1;
    the_emitter_list += {c1,c2,c3,c4};
    the_emitter[n_emi] = newcl; Curve Loop(the_emitter[n_emi]) = {c1,c2,c3,c4};
    
    
Return

Macro COLLECTOR

    p1 = newp; Point(p1) = {x,      y,      0,  ref_coll*10};
    p2 = newp; Point(p2) = {x-rc,   y,      0,  ref_coll};
    p3 = newp; Point(p3) = {x,      y-rc,   0,  ref_coll};
    p4 = newp; Point(p4) = {x+rc,   y,      0,  ref_coll};
    p5 = newp; Point(p5) = {x,      y+rc,   0,  ref_coll};
    
    c1 = newc; Circle(c1) = {p2,p1,p3}; c2 = newc; Circle(c2) = {p3,p1,p4};
    c3 = newc; Circle(c3) = {p4,p1,p5}; c4 = newc; Circle(c4) = {p5,p1,p2};
    collector_center[n_coll]=p1;
    the_collector_list += {c1,c2,c3,c4};
    the_collector[n_coll] = newcl; Curve Loop(the_collector[n_coll]) = {c1,c2,c3,c4};
    
    
Return

Macro CIRCLE_REFINE

    p1 = newp; Point(p1) = {x,     y,     0,  ref_circle};
    p2 = newp; Point(p2) = {x-r,   y,     0,  ref_circle};
    p3 = newp; Point(p3) = {x,     y-r,   0,  ref_circle};
    p4 = newp; Point(p4) = {x+r,   y,     0,  ref_circle};
    p5 = newp; Point(p5) = {x,     y+r,   0,  ref_circle};
    
    c1 = newc; Circle(c1) = {p2,p1,p3}; c2 = newc; Circle(c2) = {p3,p1,p4};
    c3 = newc; Circle(c3) = {p4,p1,p5}; c4 = newc; Circle(c4) = {p5,p1,p2};
    ref_cirlce_center[n_circle]=p1;
    the_circle_list += {c1,c2,c3,c4};
    the_circle[n_circle] = newcl; Curve Loop(the_circle[n_circle]) = {c1,c2,c3,c4};
    
Return

//------------------------------------------------------------------------------//
//Doamin------------------------------------------------------------------------//
//------------------------------------------------------------------------------//


p1_domain=newp; Point(p1_domain) = {-Lx,    -Ly,  0, MSIZE_OUT};
p2_domain=newp; Point(p2_domain) = {Lx, -Ly,  0, MSIZE_OUT};
p3_domain=newp; Point(p3_domain) = {Lx,  Ly,  0, MSIZE_OUT};
p4_domain=newp; Point(p4_domain) = {-Lx,     Ly,  0, MSIZE_OUT};



l1_domain=newc; Line(l1_domain)={p1_domain,p2_domain};
l2_domain=newc; Line(l2_domain)={p2_domain,p3_domain};
l3_domain=newc; Line(l3_domain)={p3_domain,p4_domain};
l4_domain=newc; Line(l4_domain)={p4_domain,p1_domain};

Curve Loop(1) = {l1_domain, l2_domain, l3_domain, l4_domain}; //Domain Rectangle


//---------------------------------------------------------------------------------//
//Emitters-------------------------------------------------------------------------//
//---------------------------------------------------------------------------------//

x=-GAP/2; y=Y_E; z=0; re=R_COND_1; ref_emi=REF_EMI;
the_emitter_list={}; the_emitter[]={}; emitter_center[]={};

Call EMITTER;

Plane Surface(11) = {the_emitter[1]};
Physical Surface("11", 11) = {11};
Point{p1} In Surface{11};


//---------------------------------------------------------------------------------//
// Refinement Circles: Emitters----------------------------------------------------//
//---------------------------------------------------------------------------------//
// the_circle[]={}; the_circle_list[]={};
// 
// //Refinement Circle: Upper Emitter (Inner Circle)
// r=R_INNER_EMI; 
// n_circle=1; y=Y_E; ref_circle=CONTROL_REFINE_INNER_EMI;Call CIRCLE_REFINE;
// 
// //Refinement Circle: Upper Emitter (Outer Circle)
// r=R_OUTER_EMI; 
// n_circle=2; y=Y_E; ref_circle=CONTROL_REFINE_OUTER_EMI;Call CIRCLE_REFINE;


//---------------------------------------------------------------------------------//
//Collectors-----------------------------------------------------------------------//
//---------------------------------------------------------------------------------//

x=GAP/2; y=Y_C; z=0; rc=R_COND_2; ref_coll=REF_COLL;
the_collector_list={}; the_collector[]={}; collector_center[]={};

Call COLLECTOR;

Plane Surface(22) = {the_collector[1]};
Physical Surface("22", 22) = {22};
Point{p1} In Surface{22};



//---------------------------------------------------------------------------------//
// Refinement Circles: Collectors--------------------------------------------------//
//---------------------------------------------------------------------------------//

// //Refinement Circle: Upper Collector 
// r=R_OUTER_COLL; 
// n_circle=3; y=Y_C; ref_circle=CONTROL_REFINE_COLLECTOR;Call CIRCLE_REFINE;



   
//---------------------------------------------------------------------------------//


// Plane Surface(1) = {1,the_circle[2],the_circle[3]};
// 
// Plane Surface(10)={the_collector[1],the_circle[3]};
// Plane Surface(100)={the_emitter[1],the_circle[1]};
// Plane Surface(1000)={the_circle[1],the_circle[2]};
// 
// Physical Surface("1", 1) = {1,10,100,1000};

Plane Surface(1) = {1, the_emitter[1], the_collector[1]};
Physical Surface("1", 1) = {1};



Physical Curve("2",2)={l1_domain, l2_domain, l3_domain, l4_domain};
Physical Curve("3", 3) = {the_emitter_list[]};
Physical Curve("4", 4) = {the_collector_list[]};


