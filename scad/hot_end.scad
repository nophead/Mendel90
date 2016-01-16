//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Virtual hot end
//
include <conf/config.scad>
use <vitamins/m90_hot_end.scad>
use <vitamins/stoffel_hot_end.scad>
use <vitamins/jhead_hot_end.scad>
use <vitamins/e3d_hot_end.scad>

module hot_end_assembly() {
    filament = extruder_filament(extruder);
    assembly("hot_end_assembly");

    if(hot_end_style(hot_end) == m90)
        m90_hot_end(hot_end);

    if(hot_end_style(hot_end) == Stoffel)
        stoffel_hot_end(hot_end);

    if(hot_end_style(hot_end) == jhead)
        jhead_hot_end(hot_end, filament, exploded = 0);

    if(hot_end_style(hot_end) == e3d)
        e3d_hot_end(hot_end, filament);

    end("hot_end_assembly");
}
