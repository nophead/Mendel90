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

wall = 3;
clearance = 0.25;
boss = washer_diameter(M3_washer) + 1;
punch = 3;
base_screw_offset = fixing_block_width() / 2 + base_clearance - AL_tube_inset;
length = wall + base_screw_offset + 10;
width = tube_width(AL_square_tube) + 2 * wall + clearance;

function tube_cap_base_thickness() = 3 * layer_height;
function tube_jig_base_thickness() = wall;

module tube_jig(open) {
    stl("tube_jig");
    h = tube_height(AL_square_tube);
    w = tube_width(AL_square_tube);

    translate([-wall, - width / 2, 0])
        difference() {
            union() {
                cube([length, width, h + tube_jig_base_thickness()]);
                hull()
                    for(side = [-1, 1])
                        translate([length / 2, side * (width + boss) / 2 + width / 2, 0])
                            cylinder(r = boss / 2, h = wall);
            }
            translate([open ? -eta : wall, wall + clearance / 2, tube_jig_base_thickness()])
                cube([length + 1, w + clearance, h + tube_jig_base_thickness()]);

            translate([wall + base_screw_offset, width / 2, -1])
                poly_cylinder(r = punch / 2, h = h);

            for(side = [-1, 1])
                translate([length / 2, side * (width + boss) / 2 + width / 2, 0])
                    poly_cylinder(r = M3_clearance_radius, h = 100, center = true);
        }
}

module base_tube() {
    difference() {
        translate([0, 0, -tube_height(AL_square_tube) / 2])
            rotate([90, 0, 0])
                square_tube(AL_square_tube, base_depth - 2 * AL_tube_inset);

        for(end = [-1,1])
            translate([0, end * (base_depth / 2 - fixing_block_width() / 2 - base_clearance), -tube_height(AL_square_tube)]) {
                base_screw_hole();
                cylinder(r = screw_head_radius(base_screw) + 0.5, h = tube_thickness(AL_square_tube) * 2 + 1, center = true);
            }
    }
}

module tube_cap_stl() {
    stl("tube_cap");
    w = tube_height(AL_square_tube);
    h = tube_width(AL_square_tube);
    t = tube_thickness(AL_square_tube);
    clearance = 0.3;

    base_thickness = tube_cap_base_thickness();

    w_outer = w - 1;
    h_outer = h - 1;
    w_inner_base = w - 2 * t;
    w_inner_top  = w_inner_base - clearance;
    h_inner_base = h - 2 * t;
    h_inner_top  = h_inner_base - clearance;

    union() {
        translate([-w_outer / 2, - h_outer / 2, 0])
            cube([w_outer, h_outer, base_thickness]);

        hull() {
            translate([-w_inner_top / 2, - h_inner_top / 2, 0])
                cube([w_inner_top, h_inner_top, 5]);

            translate([-w_inner_base / 2, - h_inner_base / 2, 0])
                cube([w_inner_base, h_inner_base, base_thickness + 1]);
        }
    }
}

module tube_jig_base() {
    w = tube_width(AL_square_tube) + 2 * wall + clearance + 2 * boss + 2;

    difference() {
        sheet(DiBond, base_depth, w, [5,5,5,5]);
        for(end = [-1,1]) {
            translate([end * (base_depth / 2 - fixing_block_width() / 2 - base_clearance), 0, 0])
                cylinder(r = punch / 2, h = 100, center = true);

            for(side = [-1, 1])
                translate([end * (base_depth / 2 - AL_tube_inset - length / 2 + wall), side * (width / 2 + boss / 2), 0])
                    cylinder(r = M3_clearance_radius, h = 100, center = true);
        }
    }
}

module tube_jig_dxf() projection(cut = true) tube_jig_base();

module tube_jig_assembly() {
    translate([0, 0, -tube_height(AL_square_tube) - wall - sheet_thickness(DiBond) / 2])
        rotate([0, 0, 90])
            tube_jig_base();

    base_tube();
    for(end = [-1, 1])
        translate([0, end * (base_depth / 2 - AL_tube_inset), -tube_height(AL_square_tube) - tube_jig_base_thickness() - eta])
            rotate([0, 0, -90 * end])
                color("lime") render()
                    tube_jig(end == -1);

}

module tube_jigs_stl() {
    tube_jig(true);
    translate([25, 0, 0])
        tube_jig(false);
}

if(0)
    tube_jig_dxf();
else
    if(1)
        tube_jig_assembly();
    else
        tube_jigs_stl();
