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

function jhead_groove() = 4.64;
function jhead_groove_offset() = 5.1; //4.76;

jhead_inset = jhead_groove_offset();

m90_hot_end_12mm    = [m90,      "HEM90340: Mendel 90 hot end", 57, 10,          12,    40, "tan", 6     + 3/2 - 1, false];
m90_hot_end_12p5mm  = [m90,      "HEM90340: Mendel 90 hot end", 57, 10,          12.5,  40, "tan", 6.25  + 3/2 - 1, false];
m90_hot_end_12p75mm = [m90,      "HEM90340: Mendel 90 hot end", 57, 10,          12.75, 40, "tan", 6.375 + 3/2 - 1, false];

JHeadMk4 =            [jhead,   "HEJH16340: JHead MK4 hot end", 64, jhead_inset, 16,    50, "black", 12,            true, 10.19 + 4, [0, 2.94, -5]];
JHeadMk5 =            [jhead,   "HEJH16340: JHead MK5 hot end", 54, jhead_inset, 16,    40, "black", 12,            true, 9     + 4, [0, 2.38, -5]];

function hot_end_style(type)              = type[0];
function hot_end_part(type)               = type[1];
function hot_end_total_length(type)       = type[2];
function hot_end_inset(type)              = type[3];
function hot_end_insulator_diameter(type) = type[4];
function hot_end_insulator_length(type)   = type[5];
function hot_end_insulator_colour(type)   = type[6];
function hot_end_screw_pitch(type)        = type[7];
function hot_end_groove_mount(type)       = type[8];
function hot_end_duct_radius(type)        = type[9];
function hot_end_duct_offset(type)        = type[10];

function hot_end_length(type) = hot_end_total_length(type) - hot_end_inset(type);
