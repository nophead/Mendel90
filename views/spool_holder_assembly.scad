//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// The spool holder assembly view
//
$vpt = [-143, 41, 19];
$vpr = [76, 0, 63];
$vpd = 650;
//
// assembly 1300 965
//
use <../scad/spool_holder.scad>

translate(-spool_holder_view_pos())
    spool_assembly(show_spool = false);

$exploded = 1;
