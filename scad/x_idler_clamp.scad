//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Bodge to stop x_idler slipping
//
include <conf/config.scad>

shaft_dia = 8;


holeR = M3_clearance_radius;
nutR = M3_nut_radius;
nutH = M3_nut_trap_depth;
wall = 2;
rad = M3_nut_radius + wall;

holeX1 = rad;
holeY1 = shaft_dia / 2 + M3_clearance_radius;

depth = 8;
centre_line = depth / 2 + 0.5;

module x_idler_clamp_stl(){
    stl("x_idler_clamp");

    translate([0, 0, depth / 2]) union() {
        difference(){
            linear_extrude(height = depth, center = true, convexity = 5) {
                hull() {
                    translate([holeX1, holeY1])
                        circle(r = rad, center = true);
                    translate([holeX1, -holeY1])
                        circle(r = rad, center = true);
                }
            }

           //nut holes
            translate([holeX1,  holeY1, nutH/2 - 4.01]) rotate([0,0, 30]) cylinder(h = nutH, r=nutR, $fn=6, center=true);

            //shaft groves
            translate([holeX1, 0, centre_line]) rotate([0,90,0])  cylinder(h = 2 * rad + 1, r = shaft_dia / 2, center = true);

            //screw holes
            for(y = [-1, 1])
                translate([holeX1,  y * holeY1, -10]) rotate([0,0, y * 360/28]) poly_cylinder(h = 20, r=holeR);

            //slots to prevent screw holes beading into the shaft holes
            translate([holeX1, 0, centre_line])
                cube([2 * holeR, 2 * holeY1, shaft_dia], center = true);
        }
         // support bridge
        translate([holeX1,  holeY1, nutH-3.9]) cylinder(h = 0.4, r=nutR+0.1, $fn=6, center=true);
    }
}

module x_idler_clamp_assembly() {

    for(side = [-1, 1])
        explode([10 * side, 0, 0])
            translate([centre_line * side, 0, 0])
                rotate([0, 90, 90 * side + 90]) {
                    color(z_coupling_color) render() translate([0, 0, -depth/2]) x_idler_clamp_stl();
                    for(pos = [[holeX1, -holeY1]])
                        translate([pos[0], pos[1], -depth/2])
                            rotate([180, 0, 0])
                                screw_and_washer(M3_cap_screw, 20);

                    for(pos = [[holeX1, holeY1]])
                        translate([pos[0], pos[1], -depth/2 + nutH])
                            rotate([180, 0, 90])
                                nut(M3_nut, true);

                }
}

if(0) {
    x_idler_clamp_stl();
    translate([- 2 * rad - 2, 0, 0])
        x_idler_clamp_stl();
}
else
    x_idler_clamp_assembly();
