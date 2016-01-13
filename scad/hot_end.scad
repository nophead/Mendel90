//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Virual extruder
//
include <conf/config.scad>
use <vitamins/m90_hot_end.scad>
use <vitamins/stoffel_hot_end.scad>
use <vitamins/jhead_hot_end.scad>

module hot_end_assembly() {
    assembly("hot_end_assembly");

    if(hot_end_style(hot_end) == m90)
        m90_hot_end(hot_end);
    if(hot_end_style(hot_end) == Stoffel)
        stoffel_hot_end(hot_end);
    if(hot_end_style(hot_end) == jhead)
        jhead_hot_end(hot_end, exploded = 0);

    end("hot_end_assembly");
}
