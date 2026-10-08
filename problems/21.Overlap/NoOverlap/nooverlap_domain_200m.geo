// =====================================================================
// NO-OVERLAP hydraulic-fracture injection-production well pair.
// Domain: 25 m (x, fracture spacing) x 200 m (y, well spacing).
//   Injection fracture (lower well): left edge,  x in [0,wf],   y in [0,  Lf]
//   Production fracture (upper well): right edge, x in [W-wf,W], y in [Lf, H]
//   Each fracture is Lf = 100 m long; they TOUCH at y = Lf = 100 m,
//   with NO overlap.
// Structured quad mesh, refined toward both fracture walls.
//
// Blocks (Physical Surfaces): "fracture", "matrix"
// Sidesets: "inlet"(inj frac bottom), "outlet"(prod frac top),
//           "left","right","bottom","top"
// =====================================================================

// ---- parameters ----
W   = 25.0;     // width  (x) = fracture spacing
H   = 200.0;    // height (y) = total domain height
wf  = 0.1;      // equivalent fracture width
Lf  = 100.0;    // hydraulic-fracture length; also the touch midline

// key coordinates
xL0 = 0.0;  xL1 = wf;            // left fracture (injection) x-range
xR0 = W-wf; xR1 = W;             // right fracture (production) x-range

// mesh controls
nx_frac = 1;     // cells across each fracture width (single-cell, apparent)
nx_mid  = 34;    // cells across 25 m matrix, refined toward both walls
ny_seg  = 20;    // cells along each 100 m y-segment (5 m/cell): 2 segments

// ---- points: x = {0, wf, W-wf, W}, y = {0, Lf, H} (3 rows) ----
Point(1)  = {xL0, 0,  0};
Point(2)  = {xL1, 0,  0};
Point(3)  = {xR0, 0,  0};
Point(4)  = {xR1, 0,  0};
Point(5)  = {xL0, Lf, 0};
Point(6)  = {xL1, Lf, 0};
Point(7)  = {xR0, Lf, 0};
Point(8)  = {xR1, Lf, 0};
Point(9)  = {xL0, H,  0};
Point(10) = {xL1, H,  0};
Point(11) = {xR0, H,  0};
Point(12) = {xR1, H,  0};

// ---- lines ----
// horizontal (3 rows x 3 segments)
Line(1)={1,2}; Line(2)={2,3}; Line(3)={3,4};
Line(4)={5,6}; Line(5)={6,7}; Line(6)={7,8};
Line(7)={9,10}; Line(8)={10,11}; Line(9)={11,12};
// vertical (4 cols x 2 segments)
Line(10)={1,5}; Line(11)={5,9};
Line(12)={2,6}; Line(13)={6,10};
Line(14)={3,7}; Line(15)={7,11};
Line(16)={4,8}; Line(17)={8,12};

// ---- 6 surfaces (3 cols x 2 rows) ----
// row 0 (y 0..Lf)
Line Loop(1)={1,12,-4,-10};   Plane Surface(1)={1};  // col0: injection frac
Line Loop(2)={2,14,-5,-12};   Plane Surface(2)={2};  // col1: matrix
Line Loop(3)={3,16,-6,-14};   Plane Surface(3)={3};  // col2: matrix (no prod here)
// row 1 (y Lf..H)
Line Loop(4)={4,13,-7,-11};   Plane Surface(4)={4};  // col0: matrix (no inj here)
Line Loop(5)={5,15,-8,-13};   Plane Surface(5)={5};  // col1: matrix
Line Loop(6)={6,17,-9,-15};   Plane Surface(6)={6};  // col2: production frac

// ---- transfinite ----
// x-divisions
Transfinite Curve {1,4,7}  = nx_frac + 1;                    // left frac width (col0)
Transfinite Curve {3,6,9}  = nx_frac + 1;                    // right frac width (col2)
Transfinite Curve {2,5,8}  = nx_mid + 1 Using Bump 0.06;     // matrix: refined toward both walls
// y-divisions: two 100 m segments
Transfinite Curve {10,12,14,16} = ny_seg + 1;                // y 0..Lf
Transfinite Curve {11,13,15,17} = ny_seg + 1;                // y Lf..H

Transfinite Surface {1,2,3,4,5,6};
Recombine Surface {1,2,3,4,5,6};

// ---- physical groups ----
// fracture = injection (surf 1, lower-left) + production (surf 6, upper-right)
Physical Surface("fracture") = {1, 6};
Physical Surface("matrix")   = {2, 3, 4, 5};

Physical Curve("inlet")  = {1};      // injection frac bottom (lower well, left edge y=0)
Physical Curve("outlet") = {9};      // production frac top (upper well, right edge y=H)
Physical Curve("bottom") = {2, 3};   // rest of lower boundary
Physical Curve("top")    = {7, 8};   // rest of upper boundary
Physical Curve("left")   = {10, 11};
Physical Curve("right")  = {16, 17};

Mesh 2;
