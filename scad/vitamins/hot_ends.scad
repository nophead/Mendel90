//
// Mendel90
//
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Hot end descriptions
//
Stoffel = 1;
m90     = 2;
jhead   = 3;
e3d     = 4;

m90_hot_end_12mm    = [m90,   "HEM90340: Mendel 90 hot end",    57,  10,  12,    40, "tan",       6.5,   false];
m90_hot_end_12p5mm  = [m90,   "HEM90340: Mendel 90 hot end",    57,  10,  12.5,  40, "tan",       6.75,  false];
m90_hot_end_12p75mm = [m90,   "HEM90340: Mendel 90 hot end",    57,  10,  12.75, 40, "tan",       6.875, false];

JHeadMk4 =            [jhead, "HEJH16340: JHead MK4 hot end",   64,  5.1, 16,    50, "black",     12,    4.64, 14, [0, 2.94, -5], 20,   20];
JHeadMk5 =            [jhead, "HEJH16340: JHead MK5 hot end",   54,  5.1, 16,    40, "black",     12,    4.64, 13, [0, 2.38, -5], 20,   20];
JHeadMk5x =           [jhead, "HEJH16340: JHead MK5 hot end", 51.2,  5.1, 16,    40, "black",     12,    4.64, 13, [0, 2.38, -5], 20,   20];
e3dv5 =               [e3d,   "HEE3DV5NB: E3D V5 direct",       70,  3.7, 16,  50.1, "lightgrey", 12,    6,    15, [1, 5,  -4.5], 14.5, 28];
e3dv6 =               [e3d,   "HEE3DV6NB: E3D V6 direct",       62,  3.7, 16,  42.7, "lightgrey", 12,    6,    15, [1, 5,  -4.5], 14,   21];
e3d_clone =           [e3d,   "HEE3DCLNB: E3D clone aliexpress",66,  6.8, 16,    46, "lightgrey", 12,    5.6,  15, [1, 5,  -4.5], 14.5, 21];

function hot_end_style(type)              = type[0];
function hot_end_part(type)               = type[1];
function hot_end_total_length(type)       = type[2];
function hot_end_inset(type)              = type[3];
function hot_end_insulator_diameter(type) = type[4];
function hot_end_insulator_length(type)   = type[5];
function hot_end_insulator_colour(type)   = type[6];
function hot_end_screw_pitch(type)        = type[7]; // hot ends without a groove
function hot_end_groove_dia(type)         = type[7]; // hot ends with groove mount
function hot_end_groove(type)             = type[8];
function hot_end_duct_radius(type)        = type[9];
function hot_end_duct_offset(type)        = type[10];
function hot_end_invert_screw(type)       = hot_end_style(type) == e3d; // do we need to invert one screw to avoid the fan
function hot_end_need_cooling(type)       = hot_end_style(type) != e3d; // has own fan so don't need cooling hole
function hot_end_duct_height_nozzle(type) = type[11];   // duct height at nozzle end
function hot_end_duct_height_fan(type)    = type[12];   // duct heigth at fan end
//
// The actual length of a JHeadMk5 is 51.2 but at the time the kit was designed I thought it was 54. The effect of this is that the
// extension on the Wades block is shorter than it should be so the tip of the hot end is higher so the fan duct needs to be
// fitted a bit higher. This bodge allows the model to reflect reality without correcting the extruder block and changing the firmware.
//
function hot_end_bodge(type) = type == JHeadMk5 ? 54 - 51.2 : 0;

function hot_end_length(type) = hot_end_total_length(type) - hot_end_inset(type);
