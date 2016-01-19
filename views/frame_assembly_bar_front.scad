//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Frame front bar detail
//
$vpt = [18, 13, -11];
$vpr = [65.5, 0, 314];
$vpd = 261;
//
// assembly 958 842
//
include <../scad/conf/config.scad>
include <../scad/positions.scad>

use <../scad/main.scad>

translate([-right_stay_x + fixing_block_height() / 2 + sheet_thickness(frame) / 2, (base_depth / 2 - fixing_block_width() / 2 - base_clearance), 0])
    frame_assembly();

$exploded = 1;
