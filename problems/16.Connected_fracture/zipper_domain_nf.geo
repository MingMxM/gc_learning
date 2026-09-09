// =====================================================================
// Zipper-fracture injection-production well pair, study unit.
// Domain: 50 m (x, width = matrix sweep distance) x 150 m (y, well spacing).
//   Injection fracture (lower well): left edge,  x in [0,wf],   y in [0,Lf]
//   Production fracture (upper well): right edge, x in [W-wf,W], y in [H-Lf,H]
//   Two hydraulic fractures are offset (zipper), overlap over y in [H-Lf, Lf].
//   THREE horizontal natural fractures span the full width at y = 25, 75, 125.
// Structured quad mesh, refined toward hydraulic-fracture walls (x) and
// toward each natural fracture (y).
//
// Blocks (Physical Surfaces): "fracture" (hydraulic), "natural_fracture", "matrix"
// Sidesets: "inlet"(inj frac bottom), "outlet"(prod frac top),
//           "left","right","bottom","top"
// =====================================================================

// ---- parameters ----
W   = 50.0;    // width  (x) = matrix sweep distance
H   = 150.0;   // height (y)
wf  = 0.1;     // equivalent hydraulic-fracture width
Lf  = 100.0;   // hydraulic-fracture length
wnf = 0.1;     // equivalent natural-fracture aperture (full thickness of band)

// natural fracture center y-positions
ynf1 = 25.0;
ynf2 = 75.0;
ynf3 = 125.0;

// x key coordinates
xL0 = 0.0;  xL1 = wf;            // left fracture (injection) x-range
xR0 = W-wf; xR1 = W;             // right fracture (production) x-range

// y structural coordinates (hydraulic-fracture ends / overlap)
yA  = H-Lf;                      // = 50, bottom of production frac / overlap start
yB  = Lf;                        // = 100, top of injection frac / overlap end

// natural-fracture band edges (center +/- half aperture)
h = wnf/2.0;
y1a = ynf1 - h; y1b = ynf1 + h;   // 24.95 , 25.05
y2a = ynf2 - h; y2b = ynf2 + h;   // 74.95 , 75.05
y3a = ynf3 - h; y3b = ynf3 + h;   // 124.95, 125.05

// mesh controls
nx_frac  = 1;      // cells across each hydraulic-fracture width (apparent)
nx_mid   = 36;     // cells across 50 m matrix, refined toward both x-walls
ny_nf    = 1;      // cells across each natural-fracture band
nyb      = 8;      // cells in each matrix y-sub-band, refined toward the NF
bumpx    = 0.03;   // x bump (toward both hydraulic-fracture walls)
bumpy    = 0.10;   // y bump (toward the natural fracture on each side)

// =====================================================================
// The y-axis is split into ordered break levels. Between consecutive
// structural breaks {0,50,100,150} and NF bands, matrix rows are refined
// toward whichever side hosts a natural fracture.
//
// Ordered y-levels (bottom -> top):
//   L0 = 0
//   L1 = y1a (24.95)   L2 = y1b (25.05)     <- NF1 band
//   L3 = 50  (yA)
//   L4 = y2a (74.95)   L5 = y2b (75.05)     <- NF2 band
//   L6 = 100 (yB)
//   L7 = y3a (124.95)  L8 = y3b (125.05)    <- NF3 band
//   L9 = 150 (H)
// => 9 y-intervals, 10 y-levels.
//
// x-levels (left -> right): {0, wf, W-wf, W}  => 3 x-intervals, 4 x-levels.
// Grid of points: 4 x-levels x 10 y-levels = 40 points.
// =====================================================================

ylev0 = 0;
ylev1 = y1a;  ylev2 = y1b;
ylev3 = yA;
ylev4 = y2a;  ylev5 = y2b;
ylev6 = yB;
ylev7 = y3a;  ylev8 = y3b;
ylev9 = H;

xlev0 = xL0; xlev1 = xL1; xlev2 = xR0; xlev3 = xR1;

// ---- points: p = 100*i + j  (i = x-index 0..3, j = y-index 0..9) ----
// (macro-free explicit list for clarity)
Point(1)  = {xlev0, ylev0, 0}; Point(2)  = {xlev1, ylev0, 0}; Point(3)  = {xlev2, ylev0, 0}; Point(4)  = {xlev3, ylev0, 0};
Point(5)  = {xlev0, ylev1, 0}; Point(6)  = {xlev1, ylev1, 0}; Point(7)  = {xlev2, ylev1, 0}; Point(8)  = {xlev3, ylev1, 0};
Point(9)  = {xlev0, ylev2, 0}; Point(10) = {xlev1, ylev2, 0}; Point(11) = {xlev2, ylev2, 0}; Point(12) = {xlev3, ylev2, 0};
Point(13) = {xlev0, ylev3, 0}; Point(14) = {xlev1, ylev3, 0}; Point(15) = {xlev2, ylev3, 0}; Point(16) = {xlev3, ylev3, 0};
Point(17) = {xlev0, ylev4, 0}; Point(18) = {xlev1, ylev4, 0}; Point(19) = {xlev2, ylev4, 0}; Point(20) = {xlev3, ylev4, 0};
Point(21) = {xlev0, ylev5, 0}; Point(22) = {xlev1, ylev5, 0}; Point(23) = {xlev2, ylev5, 0}; Point(24) = {xlev3, ylev5, 0};
Point(25) = {xlev0, ylev6, 0}; Point(26) = {xlev1, ylev6, 0}; Point(27) = {xlev2, ylev6, 0}; Point(28) = {xlev3, ylev6, 0};
Point(29) = {xlev0, ylev7, 0}; Point(30) = {xlev1, ylev7, 0}; Point(31) = {xlev2, ylev7, 0}; Point(32) = {xlev3, ylev7, 0};
Point(33) = {xlev0, ylev8, 0}; Point(34) = {xlev1, ylev8, 0}; Point(35) = {xlev2, ylev8, 0}; Point(36) = {xlev3, ylev8, 0};
Point(37) = {xlev0, ylev9, 0}; Point(38) = {xlev1, ylev9, 0}; Point(39) = {xlev2, ylev9, 0}; Point(40) = {xlev3, ylev9, 0};

// point id helper: id(i,j) = 4*j + i + 1  (i:0..3, j:0..9)

// ---- horizontal lines: 10 rows x 3 segments = 30 lines ----
// H-line at row j, segment s (s=0..2): id = 100 + 3*j + s
// connects id(s,j)->id(s+1,j)
// ---- vertical lines: 4 cols x 9 segments = 36 lines ----
// V-line at col i, segment s (s=0..8): id = 300 + 9*i + s
// connects id(i,s)->id(i,s+1)

// Because Gmsh .geo has no loops without macros, generate explicitly below.

// Row horizontal lines (j = 0..9)
// j0
Line(100)={1,2};  Line(101)={2,3};  Line(102)={3,4};
// j1
Line(103)={5,6};  Line(104)={6,7};  Line(105)={7,8};
// j2
Line(106)={9,10}; Line(107)={10,11};Line(108)={11,12};
// j3
Line(109)={13,14};Line(110)={14,15};Line(111)={15,16};
// j4
Line(112)={17,18};Line(113)={18,19};Line(114)={19,20};
// j5
Line(115)={21,22};Line(116)={22,23};Line(117)={23,24};
// j6
Line(118)={25,26};Line(119)={26,27};Line(120)={27,28};
// j7
Line(121)={29,30};Line(122)={30,31};Line(123)={31,32};
// j8
Line(124)={33,34};Line(125)={34,35};Line(126)={35,36};
// j9
Line(127)={37,38};Line(128)={38,39};Line(129)={39,40};

// Vertical lines, col i (=0..3), segment s (=0..8): connect id(i,s)->id(i,s+1)
// col 0 (points 1,5,9,13,17,21,25,29,33,37)
Line(300)={1,5};   Line(301)={5,9};   Line(302)={9,13};  Line(303)={13,17};
Line(304)={17,21}; Line(305)={21,25}; Line(306)={25,29}; Line(307)={29,33}; Line(308)={33,37};
// col 1 (points 2,6,10,14,18,22,26,30,34,38)
Line(309)={2,6};   Line(310)={6,10};  Line(311)={10,14}; Line(312)={14,18};
Line(313)={18,22}; Line(314)={22,26}; Line(315)={26,30}; Line(316)={30,34}; Line(317)={34,38};
// col 2 (points 3,7,11,15,19,23,27,31,35,39)
Line(318)={3,7};   Line(319)={7,11};  Line(320)={11,15}; Line(321)={15,19};
Line(322)={19,23}; Line(323)={23,27}; Line(324)={27,31}; Line(325)={31,35}; Line(326)={35,39};
// col 3 (points 4,8,12,16,20,24,28,32,36,40)
Line(327)={4,8};   Line(328)={8,12};  Line(329)={12,16}; Line(330)={16,20};
Line(331)={20,24}; Line(332)={24,28}; Line(333)={28,32}; Line(334)={32,36}; Line(335)={36,40};

// ---- surfaces: 3 cols x 9 rows = 27 surfaces ----
// cell (i,j): i=0..2 (x-interval), j=0..8 (y-interval)
// bottom H-line: 100 + 3*j + i
// top    H-line: 100 + 3*(j+1) + i
// left   V-line: 300 + 9*i + j
// right  V-line: 300 + 9*(i+1) + j
// Loop = { bottomH, rightV, -topH, -leftV }
// Surface id = 3*j + i + 1  (1..27)

// I list all 27 explicitly.
// j0
Line Loop(1)={100,309,-103,-300};  Plane Surface(1)={1};
Line Loop(2)={101,318,-104,-309};  Plane Surface(2)={2};
Line Loop(3)={102,327,-105,-318};  Plane Surface(3)={3};
// j1  (NF1 band, y in [24.95,25.05])
Line Loop(4)={103,310,-106,-301};  Plane Surface(4)={4};
Line Loop(5)={104,319,-107,-310};  Plane Surface(5)={5};
Line Loop(6)={105,328,-108,-319};  Plane Surface(6)={6};
// j2
Line Loop(7)={106,311,-109,-302};  Plane Surface(7)={7};
Line Loop(8)={107,320,-110,-311};  Plane Surface(8)={8};
Line Loop(9)={108,329,-111,-320};  Plane Surface(9)={9};
// j3
Line Loop(10)={109,312,-112,-303}; Plane Surface(10)={10};
Line Loop(11)={110,321,-113,-312}; Plane Surface(11)={11};
Line Loop(12)={111,330,-114,-321}; Plane Surface(12)={12};
// j4  (NF2 band, y in [74.95,75.05])
Line Loop(13)={112,313,-115,-304}; Plane Surface(13)={13};
Line Loop(14)={113,322,-116,-313}; Plane Surface(14)={14};
Line Loop(15)={114,331,-117,-322}; Plane Surface(15)={15};
// j5
Line Loop(16)={115,314,-118,-305}; Plane Surface(16)={16};
Line Loop(17)={116,323,-119,-314}; Plane Surface(17)={17};
Line Loop(18)={117,332,-120,-323}; Plane Surface(18)={18};
// j6
Line Loop(19)={118,315,-121,-306}; Plane Surface(19)={19};
Line Loop(20)={119,324,-122,-315}; Plane Surface(20)={20};
Line Loop(21)={120,333,-123,-324}; Plane Surface(21)={21};
// j7  (NF3 band, y in [124.95,125.05])
Line Loop(22)={121,316,-124,-307}; Plane Surface(22)={22};
Line Loop(23)={122,325,-125,-316}; Plane Surface(23)={23};
Line Loop(24)={123,334,-126,-325}; Plane Surface(24)={24};
// j8
Line Loop(25)={124,317,-127,-308}; Plane Surface(25)={25};
Line Loop(26)={125,326,-128,-317}; Plane Surface(26)={26};
Line Loop(27)={126,335,-129,-326}; Plane Surface(27)={27};

// =====================================================================
// TRANSFINITE
// =====================================================================
// ---- x-divisions (apply to every horizontal line, grouped by segment) ----
// left frac width  (segment i=0): H-lines with (id-100)%3 == 0
Transfinite Curve {100,103,106,109,112,115,118,121,124,127} = nx_frac + 1;
// matrix middle    (segment i=1): (id-100)%3 == 1
Transfinite Curve {101,104,107,110,113,116,119,122,125,128} = nx_mid + 1 Using Bump bumpx;
// right frac width (segment i=2): (id-100)%3 == 2
Transfinite Curve {102,105,108,111,114,117,120,123,126,129} = nx_frac + 1;

// ---- y-divisions (apply to every vertical line, grouped by y-segment j) ----
// For each col i, the 9 vertical segments are ids 300+9*i + j, j=0..8.
// y-segment types by j:
//   j0: [0,24.95]     matrix, refine toward TOP (NF1 above)      -> Bump, dense near top
//   j1: [24.95,25.05] NF1 band                                   -> ny_nf
//   j2: [25.05,50]    matrix, refine toward BOTTOM (NF1 below)   -> Bump, dense near bottom
//   j3: [50,74.95]    matrix, refine toward TOP (NF2 above)      -> Bump
//   j4: [74.95,75.05] NF2 band                                   -> ny_nf
//   j5: [75.05,100]   matrix, refine toward BOTTOM (NF2 below)   -> Bump
//   j6: [100,124.95]  matrix, refine toward TOP (NF3 above)      -> Bump
//   j7: [124.95,125.05] NF3 band                                 -> ny_nf
//   j8: [125.05,150]  matrix, refine toward BOTTOM (NF3 below)   -> Bump
//
// Gmsh "Progression p": clusters toward the START node (p>1) of the curve.
// Vertical curves go bottom->top, so:
//   refine toward TOP    -> Progression  pnf   (p>1 clusters at start=bottom) => use 1/pnf? 
// To avoid confusion we use "Bump" only where symmetric is fine, and
// "Progression" with sign handled by curve orientation. Simplest robust
// choice: use Progression and pick ratio so cells shrink toward the NF.
//
// Curve j goes from y_j (bottom) to y_{j+1} (top).
//   Progression r  -> element sizes grow by factor r from the FIRST point.
//   r>1 : small elements at bottom, large at top  (dense near BOTTOM)
//   r<1 : dense near TOP
pnf = 1.20;   // growth ratio away from the natural fracture

// col 0 vertical lines: 300..308
Transfinite Curve {300} = nyb+1 Using Progression 1.0/pnf;  // j0 dense top
Transfinite Curve {301} = ny_nf+1;                          // j1 NF band
Transfinite Curve {302} = nyb+1 Using Progression pnf;      // j2 dense bottom
Transfinite Curve {303} = nyb+1 Using Progression 1.0/pnf;  // j3 dense top
Transfinite Curve {304} = ny_nf+1;                          // j4 NF band
Transfinite Curve {305} = nyb+1 Using Progression pnf;      // j5 dense bottom
Transfinite Curve {306} = nyb+1 Using Progression 1.0/pnf;  // j6 dense top
Transfinite Curve {307} = ny_nf+1;                          // j7 NF band
Transfinite Curve {308} = nyb+1 Using Progression pnf;      // j8 dense bottom
// col 1 vertical lines: 309..317
Transfinite Curve {309} = nyb+1 Using Progression 1.0/pnf;
Transfinite Curve {310} = ny_nf+1;
Transfinite Curve {311} = nyb+1 Using Progression pnf;
Transfinite Curve {312} = nyb+1 Using Progression 1.0/pnf;
Transfinite Curve {313} = ny_nf+1;
Transfinite Curve {314} = nyb+1 Using Progression pnf;
Transfinite Curve {315} = nyb+1 Using Progression 1.0/pnf;
Transfinite Curve {316} = ny_nf+1;
Transfinite Curve {317} = nyb+1 Using Progression pnf;
// col 2 vertical lines: 318..326
Transfinite Curve {318} = nyb+1 Using Progression 1.0/pnf;
Transfinite Curve {319} = ny_nf+1;
Transfinite Curve {320} = nyb+1 Using Progression pnf;
Transfinite Curve {321} = nyb+1 Using Progression 1.0/pnf;
Transfinite Curve {322} = ny_nf+1;
Transfinite Curve {323} = nyb+1 Using Progression pnf;
Transfinite Curve {324} = nyb+1 Using Progression 1.0/pnf;
Transfinite Curve {325} = ny_nf+1;
Transfinite Curve {326} = nyb+1 Using Progression pnf;
// col 3 vertical lines: 327..335
Transfinite Curve {327} = nyb+1 Using Progression 1.0/pnf;
Transfinite Curve {328} = ny_nf+1;
Transfinite Curve {329} = nyb+1 Using Progression pnf;
Transfinite Curve {330} = nyb+1 Using Progression 1.0/pnf;
Transfinite Curve {331} = ny_nf+1;
Transfinite Curve {332} = nyb+1 Using Progression pnf;
Transfinite Curve {333} = nyb+1 Using Progression 1.0/pnf;
Transfinite Curve {334} = ny_nf+1;
Transfinite Curve {335} = nyb+1 Using Progression pnf;

Transfinite Surface {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27};
Recombine Surface {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27};

// =====================================================================
// PHYSICAL GROUPS
// =====================================================================
// Hydraulic fracture (injection = left col i=0 over y in [0,100];
//                     production = right col i=2 over y in [50,150]).
// Injection frac surfaces (i=0): j=0..5  -> surf 3*j+1 = 1,4,7,10,13,16
// Production frac surfaces (i=2): j=3..8 -> surf 3*j+3 = 12,15,18,21,24,27
Physical Surface("fracture") = {1,4,7,10,13,16, 12,15,18,21,24,27};

// Natural fractures = the three full-width bands (j=1,4,7), all x-columns.
//   j1 -> surf 4,5,6 ; j4 -> surf 13,14,15 ; j7 -> surf 22,23,24
// Remove cells already claimed by the hydraulic fracture (4,13,15,24)
// so a cell is not in two blocks. Overlap cells stay "fracture".
Physical Surface("natural_fracture") = {5,6, 14, 22,23};

// Matrix = everything else.
Physical Surface("matrix") = {2,3, 8,9, 11, 17, 19,20, 25,26};

// ---- sidesets ----
Physical Curve("inlet")  = {100};                 // injection frac bottom (col0, j0)
Physical Curve("outlet") = {129};                 // production frac top   (col2, j9)
Physical Curve("bottom") = {101,102};             // rest of lower boundary
Physical Curve("top")    = {127,128};             // rest of upper boundary
Physical Curve("left")   = {300,301,302,303,304,305,306,307,308};
Physical Curve("right")  = {327,328,329,330,331,332,333,334,335};

Mesh 2;
