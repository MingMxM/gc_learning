// =====================================================================
// Zipper-fracture injection-production well pair, study unit.
// Domain: 10 m (x, width = fracture spacing) x 150 m (y, well spacing).
//   Injection fracture (lower well): left edge, x in [0,wf], y in [0,Lf]
//   Production fracture (upper well): right edge, x in [W-wf,W], y in [H-Lf,H]
//   Two fractures are offset (zipper), overlapping over y in [H-Lf, Lf].
// Structured quad mesh, refined toward both fracture walls.
//
// Blocks (Physical Surfaces): "fracture", "matrix"
// Sidesets: "inlet"(inj frac bottom), "outlet"(prod frac top),
//           "left","right","bottom","top"
// =====================================================================

// ---- parameters ----
W  = 10.0;    // width  (x) = matrix sweep distance (fracture spacing)
H  = 150.0;   // height (y)
wf = 0.1;     // equivalent fracture width
Lf = 100.0;   // fracture half-length

// key coordinates
xL0 = 0.0;  xL1 = wf;            // left fracture (injection) x-range
xR0 = W-wf; xR1 = W;             // right fracture (production) x-range
yA  = H-Lf;                      // = 50, bottom of production frac / overlap start
yB  = Lf;                        // = 100, top of injection frac / overlap end

// mesh controls
nx_frac  = 1;      // cells across each fracture width (single-cell, apparent)
nx_mid   = 30;     // cells across 10 m matrix, refined toward both walls
ny_seg   = 10;     // cells along each 50 m y-segment (5 m/cell): 3 segments
// -> y split into [0,50],[50,100],[100,150], each ny_seg cells

// ---- points (grid of x = {0, wf, W-wf, W}, y = {0, 50, 100, 150}) ----
// x indices: 0=0, 1=wf, 2=W-wf, 3=W ; y indices: 0=0,1=50,2=100,3=150
Point(1)  = {xL0, 0,   0};
Point(2)  = {xL1, 0,   0};
Point(3)  = {xR0, 0,   0};
Point(4)  = {xR1, 0,   0};
Point(5)  = {xL0, yA,  0};
Point(6)  = {xL1, yA,  0};
Point(7)  = {xR0, yA,  0};
Point(8)  = {xR1, yA,  0};
Point(9)  = {xL0, yB,  0};
Point(10) = {xL1, yB,  0};
Point(11) = {xR0, yB,  0};
Point(12) = {xR1, yB,  0};
Point(13) = {xL0, H,   0};
Point(14) = {xL1, H,   0};
Point(15) = {xR0, H,   0};
Point(16) = {xR1, H,   0};

// ---- build 3x3 grid of surfaces via lines ----
// horizontal lines (4 rows x 3 segments)
Line(1)={1,2}; Line(2)={2,3}; Line(3)={3,4};
Line(4)={5,6}; Line(5)={6,7}; Line(6)={7,8};
Line(7)={9,10}; Line(8)={10,11}; Line(9)={11,12};
Line(10)={13,14}; Line(11)={14,15}; Line(12)={15,16};
// vertical lines (4 cols x 3 segments)
Line(13)={1,5}; Line(14)={5,9}; Line(15)={9,13};
Line(16)={2,6}; Line(17)={6,10}; Line(18)={10,14};
Line(19)={3,7}; Line(20)={7,11}; Line(21)={11,15};
Line(22)={4,8}; Line(23)={8,12}; Line(24)={12,16};

// ---- 9 surfaces (3x3) ----
// row 0 (y 0..50)
Line Loop(1)={1,16,-4,-13};   Plane Surface(1)={1};  // col0: injection frac
Line Loop(2)={2,19,-5,-16};   Plane Surface(2)={2};  // col1: matrix
Line Loop(3)={3,22,-6,-19};   Plane Surface(3)={3};  // col2: matrix
// row 1 (y 50..100, overlap)
Line Loop(4)={4,17,-7,-14};   Plane Surface(4)={4};  // col0: injection frac
Line Loop(5)={5,20,-8,-17};   Plane Surface(5)={5};  // col1: matrix
Line Loop(6)={6,23,-9,-20};   Plane Surface(6)={6};  // col2: production frac
// row 2 (y 100..150)
Line Loop(7)={7,18,-10,-15};  Plane Surface(7)={7};  // col0: matrix
Line Loop(8)={8,21,-11,-18};  Plane Surface(8)={8};  // col1: matrix
Line Loop(9)={9,24,-12,-21};  Plane Surface(9)={9};  // col2: production frac

// ---- transfinite ----
// x-divisions: frac width (cols touching xL1 and xR0), matrix middle
Transfinite Curve {1,4,7,10}    = nx_frac + 1;                       // left frac width
Transfinite Curve {3,6,9,12}    = nx_frac + 1;                       // right frac width
Transfinite Curve {2,5,8,11}    = nx_mid + 1 Using Bump 0.1;         // matrix: refined toward BOTH walls, coarser middle
// y-divisions: three 50 m segments
Transfinite Curve {13,16,19,22} = ny_seg + 1;                        // y 0..50
Transfinite Curve {14,17,20,23} = ny_seg + 1;                        // y 50..100
Transfinite Curve {15,18,21,24} = ny_seg + 1;                        // y 100..150

Transfinite Surface {1,2,3,4,5,6,7,8,9};
Recombine Surface {1,2,3,4,5,6,7,8,9};

// ---- physical groups ----
// fracture = injection frac (surf 1,4) + production frac (surf 6,9)
Physical Surface("fracture") = {1, 4, 6, 9};
Physical Surface("matrix")   = {2, 3, 5, 7, 8};

Physical Curve("inlet")  = {1};      // injection frac bottom (lower well)
Physical Curve("outlet") = {12};     // production frac top (upper well)
Physical Curve("bottom") = {2, 3};   // rest of lower boundary
Physical Curve("top")    = {10, 11}; // rest of upper boundary
Physical Curve("left")   = {13,14,15};
Physical Curve("right")  = {22,23,24};

Mesh 2;
