//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Rail supports
//
include <conf/config.scad>
include <positions.scad>

nut_trap_meat = 4;                  // how much plastic above the nut trap
wall = 3;
tab_height = 5;

function bar_clamp_inner_rad(d) = d / 2;
function bar_clamp_outer_rad(d) = bar_clamp_inner_rad(d) + bar_clamp_band;
function bar_clamp_stem(d) = bar_clamp_inner_rad(d) + bar_clamp_outer_rad(d) + bar_clamp_tab - 2;
function bar_clamp_length(d) = bar_clamp_tab + bar_clamp_stem(d) + bar_clamp_tab;
function bar_rail_offset(d) = bar_clamp_tab + d / 2 + bar_clamp_band;

function bar_clamp_switch_y_offset() = 12;

function y_switch_x(w) = -w / 2 - bar_clamp_switch_y_offset();
function y_switch_y(d) = bar_clamp_inner_rad(d) + microswitch_thickness() / 2 + 2;
function y_switch_z(h) = h + microswitch_button_x_offset();

function bar_clamp_switch_x_offset() = y_switch_y(Y_bar_dia);
function bar_clamp_switch_z_offset() = microswitch_button_x_offset();

module bar_clamp_holes(d)
    for(y = [bar_rail_offset(d) - bar_clamp_length(d) + 0.5 * bar_clamp_tab,
             bar_rail_offset(d)                       - 0.5 * bar_clamp_tab])
        translate([0, y, 0])
            child();

module bar_clamp(d, h, w, switch = false, yaxis = false) {
    gap = 1.5;
    inner_rad = bar_clamp_inner_rad(d);
    outer_rad = bar_clamp_outer_rad(d);
    stem = bar_clamp_stem(d);
    length = bar_clamp_length(d);
    rail_offset = bar_rail_offset(d);

    cavity_l = stem - 2 * wall;
    cavity_h = h - nut_trap_meat - nut_trap_depth;
    cavity_w = w - 2 * wall;

    sbracket_length = -y_switch_x(w) + 4;
    sbracket_thickness = 7;
    sbracket_height = microswitch_length();

    color(clamp_color) {
        translate([0, rail_offset, 0]) {
            union() {
                difference() {
                    translate([0,-length/2,0]) rotate([90,0,90]) linear_extrude(height = w, center = true, convexity = 6) {
                        difference() {
                            union() {
                                translate([0, tab_height / 2, 0])
                                    square([length, tab_height], center = true);            // base
                                translate([0, h / 2, 0])
                                    square([stem, h], center = true);                       // stem
                                translate([(stem/2 - outer_rad), h, 0])
                                    circle(r = outer_rad, center = true);                   // band
                                translate([-stem/2 ,h,0])
                                    square([stem - outer_rad, outer_rad]);                  // band tab

                            }
                            translate([(stem/2 - outer_rad), h, 0])
                                poly_circle(r = inner_rad, center = true);                  // bore

                            translate([-rail_offset, h, 0])
                                square([stem, gap]);                                        // gap

                            }
                        }
                    //
                    // plastic saving cavity
                    //
                    translate([0, -cavity_l / 2 - bar_clamp_tab - wall, cavity_h / 2 - eta])
                        cube([cavity_w, cavity_l, cavity_h], center = true);
                    //
                    // nut trap
                    //
                    translate([0,-length + 1.5 * bar_clamp_tab,0])
                        rotate([0,0,90])
                            nut_trap(screw_clearance_radius, nut_radius, h - nut_trap_meat, horizontal = true);
                    //
                    // mounting holes
                    //
                    translate([0, -rail_offset, 0])
                        bar_clamp_holes(d)
                            rotate([0,0,90])
                                tearslot( h = 100, r = screw_clearance_radius(frame_screw), center = true, w = 2); // mounting screw

                    if(switch && !yaxis)
                        translate([-w / 2 - axis_endstop_clearance,
                                   outer_rad + microswitch_thickness() / 2 - rail_offset,
                                   h - outer_rad + microswitch_first_hole_x_offset()])
                            rotate([0, 90, 90])
                                microswitch_holes();

                    *translate([0,-50,-1]) cube([100,100,100]);             // cross section for debug
                }
                if(switch && yaxis) {                                       // switch bracket
                    difference() {
                        union() {
                            translate([w / 2 -sbracket_length,
                                        y_switch_y(d) + microswitch_thickness() / 2 - rail_offset,
                                        y_switch_z(h) - microswitch_button_x_offset() - microswitch_length() / 2])
                                cube([sbracket_length, sbracket_thickness, sbracket_height]);

                            translate([w / 2 - eta - sbracket_thickness,
                                       y_switch_y(d) - microswitch_thickness() / 2 - rail_offset +0.5,
                                       y_switch_z(h) - microswitch_button_x_offset() - microswitch_length() / 2])
                                cube([sbracket_thickness,
                                      y_switch_y(d) - outer_rad + microswitch_thickness() / 2 + 1,
                                      h - (y_switch_z(h) - microswitch_button_x_offset() - microswitch_length() / 2)]);
                        }
                        translate([y_switch_x(w), y_switch_y(d) - rail_offset, y_switch_z(h)])
                            mirror([0,1,0]) rotate([0, 90, 90])
                                microswitch_holes();

                        translate([0, - 0.5 * bar_clamp_tab - 0.5,0]) // screwdriver access
                            rotate([0,0,90])
                                teardrop(h = 100, r = 3, center = true, truncate = false);
                    }
                }
            }
        }
    }
}

module bar_clamp_assembly(d, h, w, name, switch = false, yaxis = true) {
    inner_rad = bar_clamp_inner_rad(d);
    outer_rad = bar_clamp_outer_rad(d);
    length = bar_clamp_length(d);
    rail_offset = bar_rail_offset(d);

    //assembly(name);
    stl(str(name, switch ? "_switch" : ""));
    color(clamp_color) render() bar_clamp(d, h, w, switch, yaxis);
    //
    // screw and washer for clamp
    //
    translate([0, rail_offset - length + 1.5 * bar_clamp_tab, h + inner_rad + bar_clamp_band])
         screw_and_washer(cap_screw, screw_longer_than(outer_rad + nut_trap_meat + washer_thickness(washer) + nut_thickness(nut, true)));
    //
    // Captive nut
    //
    translate([0, rail_offset - length + 1.5 * bar_clamp_tab, h - nut_trap_meat])
        rotate([180, 0, 90])
            nut(nut, true);
    //
    // mounting screws and washers
    //
    for(y = [rail_offset - length + 0.5 * bar_clamp_tab, rail_offset - 0.5 * bar_clamp_tab])
        translate([0, y, tab_height])
            if(yaxis)
                base_screw();
            else
                frame_screw(tab_height);
    //
    // limit switch
    //
    if(switch)
        if(yaxis)
            translate([y_switch_x(w), y_switch_y(d), y_switch_z(h)])
                mirror([0,1,0]) rotate([0, 90, 90]) {
                    microswitch();
                    microswitch_hole_positions()
                        screw_and_washer(No2_screw, 13);
                }
        else
            translate([-w / 2 - axis_endstop_clearance,
                       outer_rad + microswitch_thickness() / 2,
                       h - outer_rad + microswitch_first_hole_x_offset()])
                rotate([0, 90, 90]) {
                    microswitch();
                    microswitch_hole_positions()
                        screw_and_washer(No2_screw, 13);
                }

    //end(name);
}


module y_bar_clamp_assembly(d, h, w, switch = false) {
     bar_clamp_assembly(d, h, w, "y_bar_clamp", switch, yaxis = true);
}

module z_bar_clamp_assembly(d, h, w, switch = false) {
     bar_clamp_assembly(d, h, w, "z_bar_clamp", switch, yaxis = false);
}

//bar_clamp(Z_bar_dia, gantry_setback, bar_clamp_depth, true);

module y_bar_clamp_stl()        translate([0,0,bar_clamp_depth/2]) rotate([0,90,0]) bar_clamp(Y_bar_dia, Y_bar_height, bar_clamp_depth, false, true);
module y_bar_clamp_switch_stl() translate([0,0,bar_clamp_depth/2]) rotate([0,90,0]) bar_clamp(Y_bar_dia, Y_bar_height, bar_clamp_depth, true, true);

module z_bar_clamp_stl()        translate([0,0,bar_clamp_depth/2]) rotate([0,90,0]) bar_clamp(Z_bar_dia, gantry_setback, bar_clamp_depth, false, false);
module z_bar_clamp_switch_stl() translate([0,0,bar_clamp_depth/2]) rotate([0,90,0]) bar_clamp(Z_bar_dia, gantry_setback, bar_clamp_depth, true, false);

if(0) {
                                            z_bar_clamp_switch_stl();
    translate([gantry_setback + 15, 0, 0])  z_bar_clamp_stl() ;
    translate([10, 40, 0])                  y_bar_clamp_switch_stl();
    translate([gantry_setback + 25, 40, 0]) y_bar_clamp_stl();
    translate([gantry_setback + 15, 80, 0]) y_bar_clamp_stl();
    translate([0, 80, 0])                   y_bar_clamp_stl();
}
else {
    z_bar_clamp_assembly(Z_bar_dia, gantry_setback, bar_clamp_depth, true);
    //bar_clamp(Z_bar_dia, gantry_setback, bar_clamp_depth, true, false);

    //translate([30, 0, 0]) y_bar_clamp_assembly(Y_bar_dia, Y_bar_height, bar_clamp_depth, true);
    //translate([30, 0, 0]) bar_clamp(Y_bar_dia, Y_bar_height, bar_clamp_depth, true, true);

}
