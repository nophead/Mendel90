//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Raspberry PI assembly view
//
// assembly 1071 765 35 23 150 60 0 127 1003
//
use <../scad/main.scad>
use <../scad/raspberry_pi.scad>

include <../scad/conf/config.scad>

electronics_assembly();
*psu_assembly();
raspberry_pi_assembly();
color(sheet_colour(frame)) render() frame_stay(false);
color(sheet_colour(frame)) render() frame_gantry();
color(sheet_colour(frame)) render() frame_base();

$exploded = 0;
