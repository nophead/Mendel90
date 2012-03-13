//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Couples the leadscrews to the motor
//
include <conf/config.scad>

studding_dia = Z_screw_dia;
shaft_dia = 7;        // includes tubing
holeR = M3_clearance_radius;
nutR = M3_nut_radius;
nutH = M3_nut_trap_depth;
corner_cut = 26;
wall = 2;

holeX = 7.5;
holeY2 = studding_dia / 2 + M3_clearance_radius;
holeY1 = shaft_dia / 2 + M3_clearance_radius;

nut_flat_radius = M3_nut_radius * cos(30);
width = 2 * (max(holeY2, holeY1) + nut_flat_radius + wall);
length = 30;

function z_coupling_length() = length;

depth = 8;
centre_line = depth / 2 + 0.5;

rad = M3_nut_radius + wall;

module z_coupling_stl(){
    stl("z_coupling");

    color(z_coupling_color) translate([0, 0, depth / 2]) union() {
        difference(){
            linear_extrude(height = depth, center = true)
                hull() {
                    polygon([
                        [ length / 2,  shaft_dia / 2 + 1],
                        [ length / 2, -shaft_dia / 2 - 1],
                        [-length / 2, -studding_dia / 2 - 1],
                        [-length / 2,  studding_dia / 2 + 1]
                    ]);
                    translate([holeX, holeY1])
                        circle(r = rad, center = true);
                    translate([holeX, -holeY1])
                        circle(r = rad, center = true);
                    translate([-holeX, holeY2])
                        circle(r = rad, center = true);
                    translate([-holeX, -holeY2])
                        circle(r = rad, center = true);
                }

           //nut holes
            translate([ holeX,  holeY1, nutH/2 - 4.01]) rotate([0,0, 30]) cylinder(h = nutH, r=nutR, $fn=6, center=true);
            translate([-holeX,  holeY2, nutH/2 - 4.01]) rotate([0,0,-30]) cylinder(h = nutH, r=nutR, $fn=6, center=true);

            //shaft groves
            translate([ -17, 0, centre_line]) rotate([0,90,0])  cylinder(h = 16, r=studding_dia / 2);
            translate([   1, 0, centre_line]) rotate([0,90,0])  cylinder(h = 16, r=shaft_dia / 2);

            //screw holes
            for(y = [-1, 1]) {
                translate([ holeX,  y * holeY1, -10]) rotate([0,0, y * 360/28]) poly_cylinder(h = 20, r=holeR);
                translate([-holeX,  y * holeY2, -10]) rotate([0,0, y * 360/28]) poly_cylinder(h = 20, r=holeR);
            }
            //slots to prevent screw holes beading into the shaft holes
            translate([holeX, 0, centre_line])
                cube([2 * holeR, 2 * holeY1, shaft_dia], center = true);

            translate([-holeX, 0, centre_line])
                cube([2 * holeR, 2 * holeY2, studding_dia], center = true);

        }
         // bridge
        translate([ holeX,  holeY1, nutH-3.9]) cylinder(h = 0.4, r=nutR+0.1, $fn=6, center=true);
        translate([-holeX,  holeY2, nutH-3.9]) cylinder(h = 0.4, r=nutR+0.1, $fn=6, center=true);
    }
}

module z_coupler_assembly() {
    //assembly("z_coupler_assembly");

    for(side = [-1, 1])
        explode([10 * side, 0, 0])
            translate([centre_line * side, 0, 0])
                rotate([0, 90, 90 * side + 90]) {
                    color(z_coupling_color) render() translate([0, 0, -depth/2]) z_coupling_stl();
                    for(pos = [[holeX, -holeY1], [-holeX, -holeY2]])
                        translate([pos[0], pos[1], -depth/2])
                            rotate([180, 0, 0])
                                screw_and_washer(M3_cap_screw, 20);

                    for(pos = [[holeX, holeY1], [-holeX, holeY2]])
                        translate([pos[0], pos[1], -depth/2 + nutH])
                            rotate([180, 0, 0])
                                nut(M3_nut, true);

                }

    translate([0,0, -9])
        tubing(shaft_dia, 5, 16);

    //end("z_coupler_assembly");
}

if(0)
    z_coupling_stl();
else
    z_coupler_assembly();
