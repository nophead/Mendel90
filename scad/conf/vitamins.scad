//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Off the shelf parts
//
include <../vitamins/washers.scad>
include <../vitamins/nuts.scad>
include <../vitamins/screws.scad>
include <../vitamins/microswitch.scad>
include <../vitamins/stepper-motors.scad>
include <../vitamins/ball-bearings.scad>
include <../vitamins/linear-bearings.scad>
include <../vitamins/pillars.scad>
include <../vitamins/belts.scad>
include <../vitamins/sheet.scad>
include <../vitamins/springs.scad>
include <../vitamins/d-connectors.scad>
include <../vitamins/ziptie.scad>
include <../vitamins/bulldog.scad>
include <../vitamins/cable_strip.scad>
include <../vitamins/fans.scad>
include <../vitamins/electronics.scad>


module rod(d , l) {
    vitamin(str("RD", d, round(l), ": Smooth rod ", d, " x ", round(l)));
    color([0.8,0.8,0.8])
        cylinder(r = d / 2, h = l, center = true);
}

module studding(d , l) {
    vitamin(str("ST", d, round(l),": Threaded rod ", d, " x ", round(l)));
    color([0.5,0.5,0.5])
        cylinder(r = d / 2, h = l, center = true);
}


module tubing(od, id, length) {
    vitamin(str("TB", od, id, length,": Tubing OD ",od, " ID ", id," x ",length));
    color([0.8, 0.8, 0.8, 0.75]) render() difference() {
        cylinder(r = od / 2, h = length,    center = true);
        cylinder(r = id / 2, h = length + 1, center = true);
    }
}
