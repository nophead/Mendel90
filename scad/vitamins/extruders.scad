//
// Mendel90
//
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Extruder descriptions
//
extruder_mount_pitch = 50;

Wades    = [96, 16, 26, [36, 36,   5], NEMA17, 45];
Direct14 = [63,  0, 20, [28, 26,   3], NEMA14, 35];

function extruder_length(type)         = type[0];
function extruder_x_offset(type)       = type[1];
function extruder_width(type)          = type[2];
function extruder_hole(type)           = type[3];
function extruder_motor(type)          = type[4];
function extruder_d_screw_length(type) = type[5];
