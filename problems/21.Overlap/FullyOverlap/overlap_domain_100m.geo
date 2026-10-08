// =====================================================================
// FULLY-OVERLAPPED hydraulic-fracture injection-production well pair.
// Domain: 25 m (x, fracture spacing) x 100 m (y = fracture length).
//   Injection fracture (lower well): left edge,  x in [0,wf],   y in [0,H]
//   Production fracture (upper well): right edge, x in [W-wf,W], y in [0,H]
//   Both fractures are Lf = 100 m long and span the FULL height: they are
//   fully overlapped, directly facing each other across the matrix.
// Structured quad mesh, refined toward both fracture walls.
//
// Blocks (Physical Surfaces): "fracture", "matrix"
// Sidesets: "inlet"(inj frac bottom), "outlet"(prod frac top),
//           "left","right","bottom","top"
// =====================================================================

// ---- parameters ----
W  = 25.0;     // width  (x) = fracture spacing
H  = 100.0;    // height (y) = fracture length Lf (full overlap)
wf = 0.1;      // equivalent fracture width

// key coordinates
xL0 = 0.0;  xL1 = wf;            // left fracture (injection) x-range
xR0 = W-wf; xR1 = W;             // right fracture (production) x-range

// mesh controls
nx_frac = 1;     // cells across each fracture width (single-cell, apparent)
nx_mid  = 34;    // cells across 25 m matrix, refined toward both walls
ny      = 20;    // cells along the 100 m height (5 m/cell)

// ---- points: x = {0, wf, W-wf, W}, y = {0, H} (2 rows) ----
Point(1) = {xL0, 0, 0};
Point(2) = {xL1, 0, 0};
Point(3) = {xR0, 0, 0};
Point(4) = {xR1, 0, 0};
Point(5) = {xL0, H, 0};
Point(6) = {xL1, H, 0};
Point(7) = {xR0, H, 0};
Point(8) = {xR1, H, 0};

// ---- lines ----
// horizontal (2 rows x 3 segments)
Line(1)={1,2}; Line(2)={2,3}; Line(3)={3,4};
Line(4)={5,6}; Line(5)={6,7}; Line(6)={7,8};
// vertical (4 cols)
Line(7)={1,5}; Line(8)={2,6}; Line(9)={3,7}; Line(10)={4,8};

// ---- 3 surfaces (3 cols x 1 row) ----
Line Loop(1)={1,8,-4,-7};   Plane Surface(1)={1};  // col0: injection frac
Line Loop(2)={2,9,-5,-8};   Plane Surface(2)={2};  // col1: matrix
Line Loop(3)={3,10,-6,-9};  Plane Surface(3)={3};  // col2: production frac

// ---- transfinite ----
// x-divisions
Transfinite Curve {1,4}  = nx_frac + 1;                   // left frac width (col0)
Transfinite Curve {3,6}  = nx_frac + 1;                   // right frac width (col2)
Transfinite Curve {2,5}  = nx_mid + 1 Using Bump 0.06;    // matrix: refined toward both walls
// y-divisions: full height
Transfinite Curve {7,8,9,10} = ny + 1;

Transfinite Surface {1,2,3};
Recombine Surface {1,2,3};

// ---- physical groups ----
// fracture = injection (surf 1, left) + production (surf 3, right), both full height
Physical Surface("fracture") = {1, 3};
Physical Surface("matrix")   = {2};

Physical Curve("inlet")  = {1};     // injection frac bottom (lower well, left edge y=0)
Physical Curve("outlet") = {6};     // production frac top (upper well, right edge y=H)
Physical Curve("bottom") = {2, 3};  // rest of lower boundary
Physical Curve("top")    = {4, 5};  // rest of upper boundary
Physical Curve("left")   = {7};
Physical Curve("right")  = {10};

Mesh 2;
