//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Holds a mains inlet and covers the PSU mains connections
//
include <conf/config.scad>

thickness = 4;
tab = 2 + washer_diameter(frame_washer);
foot = part_base_thickness;
holes = tab / 2 + 1;

cut_out_width = 19;
cut_out_length = 27;
hole_pitch = 40;

depth = 40;

terminal_depth = 10;
terminal_height = 30;

function mains_inlet_height() = 55;
function mains_inlet_width() = 52 + 2 * tab;
function mains_inlet_top_width() = mains_inlet_width() - 2 * tab;
function mains_inlet_inset() = tab + thickness;
function mains_inlet_depth() = depth - terminal_depth;

module mains_inlet_stl() {
    height = mains_inlet_height();
    width = mains_inlet_width();

    stl("mains_inlet");

    difference() {
        translate([0, 0, depth / 2])                    // main body
            cube([width, height, depth], center = true);

        difference() {
            translate([0, -thickness, depth / 2])
                cube([width - 2 * tab - 2 * thickness, height, depth - 2 * thickness], center = true);        // hollow inside
            for(side = [-1, 1])
                translate([side * hole_pitch / 2, height / 2 - thickness - cut_out_width / 2, 0])
                    cylinder(r = washer_diameter(M3_washer) / 2, h = 10);
        }

        translate([-thickness - tab, - height / 2 + eta, depth])
            cube([width, terminal_height * 2, terminal_depth * 2], true);           // cut out for terminal strip

        translate([0, height / 2 - cut_out_width / 2 - thickness, 0])
            cube([cut_out_length, cut_out_width, 2 * thickness + 1], center = true);    // connector apperture

        for(side = [-1, 1]) {
            //
            // mounting screw holes
            //
            for(z = side > 0 ? [depth - holes, holes] : [depth - terminal_depth - holes])
                translate([side * (width / 2 - tab / 2), - height / 2, z])
                    rotate([90, 0, 0]) teardrop_plus(r = screw_clearance_radius(base_screw), h = foot * 2 + 1, center = true);

            translate([side * width / 2, foot, 1])
                cube([tab * 2,  height, depth * 2], center = true);     // cut outs for lugs

            translate([side * hole_pitch / 2, height / 2 - thickness - cut_out_width / 2, 0])
                poly_cylinder(r = M3_tap_radius, h = depth, center = true);
        }

    }
}

module mains_inlet_holes()
    for(side = [-1, 1])
        for(z = side > 0 ? [depth - holes, holes] : [depth - terminal_depth - holes])
            translate([side * (mains_inlet_width() / 2 - tab / 2), -mains_inlet_height() / 2 + foot, z])
                rotate([-90, 0, 0])
                        child();



module mains_inlet_assembly() {
    assembly("mains_inlet_assembly");
    translate([-mains_inlet_depth(), -mains_inlet_width() / 2 + mains_inlet_inset(),  mains_inlet_height() / 2]) rotate([90, 0, 90]) {

        color(plastic_part_color("lime")) render() mains_inlet_stl();
        //
        // Mounting screws and washers
        //
        mains_inlet_holes()
            frame_screw(foot);
    }
    end("mains_inlet_assembly");
}


if(1)
    mains_inlet_assembly();
else
    mains_inlet_stl();
