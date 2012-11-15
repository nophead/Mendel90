//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Cable sizes
//
function cable_wires(cable)     = cable[0];
function cable_wire_size(cable) = cable[1];

// numbers from http://mathworld.wolfram.com/CirclePacking.html
function cable_radius(cable) = ceil([0, 1, 2, 2.15, 2.41, 2.7, 3, 3, 3.3][cable_wires(cable)] * cable_wire_size(cable)) / 2; // radius of a bundle

function wire_hole_radius(cable) = cable_radius(cable) + 0.5;

module wire_hole(r) {
    cylinder(r = r, h = 100, center = true);
}

// arrangement of bundle in flat cable clip
function cable_bundle(cable) = [[0,0], [1,1], [2,1], [2, 0.5 + sin(60)], [2,2], [3, 0.5 + sin(60)], [3,2]][cable_wires(cable)];

function cable_width(cable)  = cable_bundle(cable)[0] * cable_wire_size(cable); // width in flat clip
function cable_height(cable) = cable_bundle(cable)[1] * cable_wire_size(cable); // height in flat clip
