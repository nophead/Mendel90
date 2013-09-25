//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// End caps for the aluminium box tubes used on the dibond version
//
include <conf/config.scad>
include <positions.scad>

tube_end_clearance = 1;

wall = 2.5;
function tube_cap_base_thickness() = wall + tube_end_clearance;

module base_tube() {
    difference() {
        translate([0, 0, -tube_height(AL_square_tube) / 2])
            rotate([90, 0, 0])
                square_tube(AL_square_tube, base_depth - 2 * AL_tube_inset);

        for(end = [-1, 1])
            translate([0, end * (base_depth / 2 - fixing_block_width() / 2 - base_clearance), -tube_height(AL_square_tube)]) {
                difference() {
                    base_screw_hole();
                    // made negative to remove bottom hole without leaving top hole going all the way through
                    cylinder(r = screw_head_radius(base_screw) + 0.5, h = tube_thickness(AL_square_tube) * 2 + 1, center = true);
                }
            }
    }
}

module tube_cap_stl() {
    stl("tube_cap");
    w = tube_height(AL_square_tube);
    h = tube_width(AL_square_tube);
    t = tube_thickness(AL_square_tube);
    clearance = 0.15;
    base_screw_offset = fixing_block_width() / 2 + base_clearance - AL_tube_inset;
    base_thickness = tube_cap_base_thickness();
    depth = 6;


    w_outer = w + 2 * (clearance + wall);
    h_outer = h - 1;
    w_inner = w - 2 * t - clearance;
    h_inner = h - 2 * t - clearance;

    rad = 2;
    layer_height = 0.25;
    height = base_thickness + base_screw_offset + nut_radius(base_nut) + 3;

    //echo(w_inner/2 - nut_radius(base_nut) * cos(30));

    difference() {
        translate([-w_outer / 2, - h_outer / 2, 0])
            cube([w_outer, h_outer, height]);

        difference() {
            union() {
                translate([-(w_outer - 2 * wall) / 2, -h_outer / 2 - 1, wall])
                    cube([w_outer - 2 * wall, h_outer + 2, height]);

                translate([-w_outer / 2 - 1, -h_outer / 2 - 1, depth])
                    cube([w_outer + 2, h_outer + 2, height]);
            }
            difference() {
                translate([-w_inner / 2,  h / 2 - h_inner - clearance - t, -1])
                    hull() {
                        cube([w_inner, h_inner, height]);
                        translate([0.5, 0.5, 0])
                            cube([w_inner - 1, h_inner - 1, height + 1]);
                    }

                translate([0, h_inner / 2 - nut_thickness(base_nut, true) - 1.5, base_screw_offset + tube_end_clearance + wall])
                    rotate([-90, 90, 0]) {
                        hull()
                            for(z = [-1, 1])
                                translate([z * layer_height / 2, 0, 0])
                                    cylinder(r = nut_radius(base_nut), $fn = 6, h = 100);

                        rotate([0,0,90])
                            teardrop_plus(r = screw_clearance_radius(base_screw), h = 100, center = true);
                    }
            }
        }


    }
}

module tube_assembly() {

    color("silver") render() base_tube();

    translate([0, -(base_depth / 2 - fixing_block_width() / 2 - base_clearance), sheet_thickness(base)]) {
        translate([0, 0, exploded * 20])
            washer(screw_washer(base_screw))
                translate([0, 0, exploded * 6])
                    washer(screw_washer(base_screw))
                        screw_and_washer(base_screw, base_screw_length);

        translate([0, 0, -sheet_thickness(base) - tube_thickness(AL_square_tube)])
            rotate([180, 0, 90])
                explode([-25, 0, -20])
                    nut(base_nut, true);
    }

    for(end = [-1, 1])
        translate([0, end * (base_depth / 2 - AL_tube_inset + tube_cap_base_thickness() + eta), -tube_height(AL_square_tube) / 2])
            rotate([90, 0, 90 - 90 * end])
                explode([0, 0, -25])
                    color("lime") render()
                        tube_cap_stl();
}


if(0)
    tube_cap_stl();
else
    tube_assembly();
