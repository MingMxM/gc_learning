// =====================================================================
// PARALLEL-fracture injection-production well pair, study unit.
// Domain: 5 m (x, fracture spacing) x 150 m (y, well spacing).
//   Injection fracture (lower well): left edge,  x in [0,wf],   y in [0,H]
//   Production fracture (upper well): right edge, x in [W-wf,W], y in [0,H]
//   Two PARALLEL fractures, full height, facing each other across matrix.
// Blocks: "fracture","matrix"; Sidesets: inlet,outlet,left,right,bottom,top
// =====================================================================
W  = 5;
H  = 150.0;
wf = 0.1;
xL0 = 0.0;  xL1 = wf;
xR0 = W-wf; xR1 = W;
y1  = 50.0;  y2 = 100.0;
nx_frac = 1;
nx_mid  = 20;
ny_seg  = 10;

Point(1)={xL0,0,0};  Point(2)={xL1,0,0};  Point(3)={xR0,0,0};  Point(4)={xR1,0,0};
Point(5)={xL0,y1,0}; Point(6)={xL1,y1,0}; Point(7)={xR0,y1,0}; Point(8)={xR1,y1,0};
Point(9)={xL0,y2,0}; Point(10)={xL1,y2,0};Point(11)={xR0,y2,0};Point(12)={xR1,y2,0};
Point(13)={xL0,H,0}; Point(14)={xL1,H,0}; Point(15)={xR0,H,0}; Point(16)={xR1,H,0};

Line(1)={1,2}; Line(2)={2,3}; Line(3)={3,4};
Line(4)={5,6}; Line(5)={6,7}; Line(6)={7,8};
Line(7)={9,10}; Line(8)={10,11}; Line(9)={11,12};
Line(10)={13,14}; Line(11)={14,15}; Line(12)={15,16};
Line(13)={1,5}; Line(14)={5,9}; Line(15)={9,13};
Line(16)={2,6}; Line(17)={6,10}; Line(18)={10,14};
Line(19)={3,7}; Line(20)={7,11}; Line(21)={11,15};
Line(22)={4,8}; Line(23)={8,12}; Line(24)={12,16};

Line Loop(1)={1,16,-4,-13};   Plane Surface(1)={1};
Line Loop(2)={2,19,-5,-16};   Plane Surface(2)={2};
Line Loop(3)={3,22,-6,-19};   Plane Surface(3)={3};
Line Loop(4)={4,17,-7,-14};   Plane Surface(4)={4};
Line Loop(5)={5,20,-8,-17};   Plane Surface(5)={5};
Line Loop(6)={6,23,-9,-20};   Plane Surface(6)={6};
Line Loop(7)={7,18,-10,-15};  Plane Surface(7)={7};
Line Loop(8)={8,21,-11,-18};  Plane Surface(8)={8};
Line Loop(9)={9,24,-12,-21};  Plane Surface(9)={9};

Transfinite Curve {1,4,7,10}    = nx_frac + 1;
Transfinite Curve {3,6,9,12}    = nx_frac + 1;
Transfinite Curve {2,5,8,11}    = nx_mid + 1 Using Bump 0.06;
Transfinite Curve {13,16,19,22} = ny_seg + 1;
Transfinite Curve {14,17,20,23} = ny_seg + 1;
Transfinite Curve {15,18,21,24} = ny_seg + 1;

Transfinite Surface {1,2,3,4,5,6,7,8,9};
Recombine Surface {1,2,3,4,5,6,7,8,9};

Physical Surface("fracture") = {1, 4, 7, 3, 6, 9};
Physical Surface("matrix")   = {2, 5, 8};
Physical Curve("inlet")  = {1};
Physical Curve("outlet") = {12};
Physical Curve("bottom") = {2, 3};
Physical Curve("top")    = {10, 11};
Physical Curve("left")   = {13,14,15};
Physical Curve("right")  = {22,23,24};

Mesh 2;
