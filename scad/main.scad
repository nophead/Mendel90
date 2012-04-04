//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// main assembly
//
include <conf/config.scad>
use <bed.scad>
use <z-screw_pointer.scad>
use <bar-clamp.scad>
use <pulley.scad>
use <y-bearing-mount.scad>
use <y-idler-bracket.scad>
use <y-belt-anchor.scad>
use <z-coupling.scad>
use <z-motor-bracket.scad>
use <z-limit-switch-bracket.scad>
use <fixing-block.scad>
use <ribbon_clamp.scad>
use <fan-guard.scad>
use <wade.scad>
use <cable_clip.scad>
use <pcb_spacer.scad>

include <positions.scad>

X = 0 * X_travel / 2; //sin(360 * $t) * bed_width / 2;
Y = 0 * Y_travel / 2; //cos(360 * $t) * bed_depth / 2;
Z = 0.5 * Z_travel;


//
// X axis
//
X_bar_length = motor_end - idler_end + 2 * x_end_bar_length();
module x_axis_assembly(show_extruder) {
    X_belt_gap = x_carriage_belt_gap() - 15;

    assembly("x_axis_assembly");
    for(side = [-1,1])
        translate([(idler_end + motor_end) / 2 + eta, side * x_bar_spacing() / 2, Z + Z0])
            rotate([0,90,0])
                rod(X_bar_dia, X_bar_length);

    translate([-X + X_origin, 0, Z + Z0 + x_carriage_offset()])
        rotate([180, 0, 180])
            x_carriage_assembly(show_extruder);

    color(belt_color)
    translate([0, -gantry_setback - belt_width(X_belt) / 2, Z + Z0])
        rotate([90, 0, 0]) render()
            union() {
                difference() {
                    twisted_belt(X_belt, idler_end + x_idler_offset(), 0, ball_bearing_diameter(X_idler_bearing) / 2,
                         motor_end - x_motor_offset(), 0, pulley_inner_radius, X_belt_gap - x_belt_loop_length());

                    translate([-X + X_origin - nozzle_x_offset + (x_carriage_belt_gap() - X_belt_gap + 5) / 2,
                            pulley_inner_radius + belt_thickness(X_belt)/2, 0])
                        cube([X_belt_gap + 5, belt_thickness(X_belt) * 3, belt_width(X_belt) * 2], center = true);
                }
            }


    elliptical_cable_strip(ribbon_clamp_slot(extruder_ways),
                [motor_end, 0, Z + Z0] + x_end_extruder_ribbon_clamp_offset(),
                [-X + X_origin, 0, Z + Z0 + x_carriage_offset()] + extruder_connector_offset(),
                [-X_travel / 2 + X_origin, 0, Z + Z0 + x_carriage_offset()] + extruder_connector_offset());
    end("x_axis_assembly");
}

//
// Z axis
//
Z_motor_length = NEMA_length(Z_motor);
Z_bar_length = height - Z_motor_length - base_clearance;
module z_end(motor_end) {
    Z_screw_length = Z0 + Z_travel + anti_backlash_height() + axis_endstop_clearance
        - (Z_motor_length + NEMA_shaft_length(Z_motor) + 2);

    if(!motor_end)
        translate([-z_bar_offset(), gantry_setback, Z0 - x_end_thickness() / 2])
            z_limit_switch_assembly();

    translate([-z_bar_offset(), 0, Z_motor_length]) {

        z_motor_assembly(gantry_setback, motor_end);

        translate([0, 0, NEMA_shaft_length(Z_motor) + 2 + Z_screw_length / 2]) {
            studding(d = Z_screw_dia, l = Z_screw_length);

            translate([0, 0, -Z_screw_length / 2 + z_coupling_length() / 2 - 1])
                render() z_screw_pointer_stl();
        }

        translate([z_bar_offset(), 0, Z_bar_length / 2])
            rod(Z_bar_dia, Z_bar_length);

        translate([z_bar_offset(), gantry_setback, Z_bar_length - bar_clamp_depth / 2]) {
            rotate([90,motor_end ? 90 : - 90, 0])
                z_bar_clamp_assembly(Z_bar_dia, gantry_setback, bar_clamp_depth, !motor_end);
        }
    }
    translate([0, 0, Z + Z0])
        x_end_assembly(motor_end, true);
}

module z_axis_assembly() {
    assembly("z_axis_assembly");
    translate([motor_end, 0, 0])
        mirror([1,0,0])
            z_end(true);
    translate([idler_end, 0, 0])
        z_end(false);
    end("z_axis_assembly");
}

//
// Y axis
//
Y_bar_length =  Y_travel + Y_carriage_depth + 2 * axis_endstop_clearance;

Y_bar_length2 = Y_travel + bearing_mount_length(Y_bearings) + 2 * bar_clamp_depth + axis_endstop_clearance + bar_clamp_switch_y_offset();

Y_bar_spacing = Y_carriage_width - bearing_mount_width(Y_bearings);
Y_bearing_inset = bearing_mount_length(Y_bearings) / 2 + bar_clamp_depth;

Y_belt_motor_offset = 13 + belt_width(Y_belt) / 2;

//Y_belt_line = min(X_origin,
//                  X_origin + Y_bar_spacing / 2
//                  - max(bar_rail_offset(Y_bar_dia), bearing_mount_width(Y_bearings) /2)
//                 - NEMA_length(Y_motor) - Y_belt_motor_offset - X_carriage_clearance);
Y_belt_line = X_origin - ribbon_clamp_slot(bed_ways) / 2 - y_belt_anchor_width() / 2 - 5;

Y_motor_end = -base_depth / 2 + y_motor_bracket_width() / 2 + base_clearance;
Y_idler_end =  base_depth / 2 - y_idler_offset() - base_clearance;
Y_belt_anchor_m = Y_motor_end +  NEMA_width(Y_motor) / 2 + Y_travel / 2;
Y_belt_anchor_i = Y_idler_end - y_idler_clearance() - Y_travel / 2;
Y_belt_end = 20;
Y_belt_gap = Y_belt_anchor_i - Y_belt_anchor_m - 2 * Y_belt_end;


//
// supported bar
//
module rail(length, height, endstop) {
    translate([0, 0, height])
        rotate([90,0,0])
            rod(Y_bar_dia, length);

    for(end = [-1, 1])
        translate([0, end * (length / 2 - bar_clamp_depth / 2), 0])
            rotate([0, 0, 90])
                y_bar_clamp_assembly(Y_bar_dia, height, bar_clamp_depth, endstop && end == 1);
}

module y_rails() {
    offset = bar_clamp_switch_y_offset() - axis_endstop_clearance;

    translate([-Y_bar_spacing / 2, 0, 0])
        rail(Y_bar_length, Y_bar_height);

    rotate([0,0,180])
        translate([-Y_bar_spacing / 2, offset / 2, 0])
            rail(Y_bar_length2, Y_bar_height, true);
}

module rail_holes(length) {
    for(end = [-1, 1])
        translate([0, end * (length / 2 - bar_clamp_depth / 2), 0])
            rotate([0, 0, 90])
                bar_clamp_holes(Y_bar_dia)
                    base_screw_hole();
}

module y_rail_holes() {
    offset = bar_clamp_switch_y_offset() - axis_endstop_clearance;

    translate([-Y_bar_spacing / 2, 0, 0])
        rail_holes(Y_bar_length);

    rotate([0,0,180])
        translate([-Y_bar_spacing / 2, offset / 2, 0])
             rail_holes(Y_bar_length2);
}

cable_clamp_y = Y_carriage_depth / 2 - ribbon_clamp_width(cap_screw);

module y_carriage() {
    difference() {
        sheet(Y_carriage, Y_carriage_width, Y_carriage_depth, [3,3,3,3]);

        translate([0, cable_clamp_y, 0])
            rotate([180, 0, 0])
                ribbon_clamp_holes(bed_ways, cap_screw)
                    cylinder(r = screw_clearance_radius(cap_screw), h = 100, center = true);

        translate([Y_bar_spacing / 2, 0, 0])
            rotate([0,180,0])
                bearing_mount_holes()
                    cylinder(r = screw_clearance_radius(cap_screw), h = 100, center = true);

        for(end = [-1, 1])
            translate([-Y_bar_spacing / 2, end * (Y_carriage_depth / 2 - Y_bearing_inset), 0])
                rotate([0,180,0])
                    bearing_mount_holes()
                        cylinder(r = screw_clearance_radius(cap_screw), h = 100, center = true);

        for(end = [[Y_belt_anchor_m, 0], [Y_belt_anchor_i, 180]])
            translate([Y_belt_line - X_origin, end[0], 0])
                rotate([0, 180, end[1]])
                    y_belt_anchor_holes()
                        cylinder(r = M3_clearance_radius, h = 100, center = true);

        for(x = [-bed_holes / 2, bed_holes / 2])
            for(y = [-bed_holes / 2, bed_holes / 2])
                translate([x, y, 0])
                    cylinder(r = 2.5/2, h = 100, center = true);
    }
}

module y_heatshield() {
    width =  Y_carriage_width - 2 * bar_clamp_tab;
    difference() {
        group() {
            difference() {
                sheet(Cardboard, width, Y_carriage_depth);

                translate([Y_bar_spacing / 2, 0, 0])
                    rotate([0,180,0])
                        bearing_mount_holes()
                            cube([10,10, 100], center = true);

                for(end = [-1, 1])
                    translate([-Y_bar_spacing / 2, end * (Y_carriage_depth / 2 - Y_bearing_inset), 0])
                        rotate([0,180,0])
                            bearing_mount_holes()
                                cube([10,10, 100], center = true);

                for(end = [[Y_belt_anchor_m, 0], [Y_belt_anchor_i, 180]])
                    translate([Y_belt_line - X_origin, end[0], 0])
                        rotate([0, 180, end[1]])
                            hull()
                                y_belt_anchor_holes()
                                    cube([10, 10, 100],center =true);
            }
            translate([0, 0, sheet_thickness(Cardboard) / 2])
                taped_area(FoilTape, 50, width, Y_carriage_depth, 5);
        }
        translate([0, Y_carriage_depth / 2, 0])
            cube([ribbon_clamp_length(bed_ways, cap_screw), 70, 100], center = true);
    }
}

module y_axis_assembly(show_bed) {
    carriage_bottom = Y_carriage_height - sheet_thickness(Y_carriage) / 2;
    carriage_top = Y_carriage_height + sheet_thickness(Y_carriage) / 2;

    translate([X_origin, 0, 0]) {

        assembly("y_axis_assembly");
        y_rails();

        translate([Y_belt_line - X_origin, Y_motor_end, y_motor_height()]) rotate([90,0,-90]) {
            color(belt_color)
            render() difference() {
                twisted_belt(Y_belt,
                             Y_motor_end - Y_idler_end,
                             pulley_inner_radius - ball_bearing_diameter(Y_idler_bearing) / 2,
                             ball_bearing_diameter(Y_idler_bearing) / 2,
                             0, 0, pulley_inner_radius, Y_belt_gap);
                translate([-(Y_belt_anchor_i + Y_belt_anchor_m) / 2 + Y_motor_end - Y, pulley_inner_radius + belt_thickness(Y_belt)/2, 0])
                    cube([Y_belt_gap, belt_thickness(Y_belt) * 2, belt_width(Y_belt) * 2], center = true);
            }

            translate([0, 0, -Y_belt_motor_offset])
                y_motor_assembly();
        }
        translate([Y_belt_line - X_origin, Y_idler_end, 0])
            y_idler_assembly();

        end("y_axis_assembly");
        //
        // Y carriage
        //
        translate([0, Y, 0]) {
            assembly("y_carriage_assembly");

            translate([Y_bar_spacing / 2, 0, Y_bar_height])
                rotate([0,180,0])
                    y_bearing_assembly(Y_bearing_holder_height, true);

            for(end = [-1, 1])
                translate([-Y_bar_spacing / 2, end * (Y_carriage_depth / 2 - Y_bearing_inset), Y_bar_height])
                    rotate([0,180,0])
                        y_bearing_assembly(Y_bearing_holder_height);

            for(end = [[Y_belt_anchor_m, 0, false], [Y_belt_anchor_i, 180, true]])
                translate([Y_belt_line - X_origin, end[0], carriage_bottom])
                    rotate([0, 180, end[1]])
                        y_belt_anchor_assembly(Y_belt_clamp_height, end[2]);

            translate([0, cable_clamp_y, carriage_top])
                rotate([180, 0, 0])
                    color(ribbon_clamp_color) render() ribbon_clamp(bed_ways, cap_screw);

            translate([0, cable_clamp_y, carriage_bottom])
                rotate([180, 0, 0])
                    ribbon_clamp_assembly(bed_ways, cap_screw, 25, sheet_thickness(Y_carriage) + ribbon_clamp_thickness(), false, true);

            translate([0, 0, Y_carriage_height + sheet_thickness(Y_carriage) / 2]) {
                if(show_bed)
                    bed_assembly();
                translate([0, 0, sheet_thickness(Cardboard) / 2])
                    y_heatshield();
            }


            translate([0, 0, Y_carriage_height + eta * 2])
                if(show_bed)
                    y_carriage();
                else
                    %y_carriage();

            end("y_carriage_assembly");
        }
    }
}

module y_axis_screw_holes() {
    translate([X_origin, 0, 0]) {
        y_rail_holes();

        translate([Y_belt_line - X_origin, Y_idler_end, 0])
            y_idler_screw_hole()
                base_screw_hole();

        translate([Y_belt_line - X_origin, Y_motor_end, y_motor_height()])
            rotate([90,0,-90])
                translate([0, 0, -Y_belt_motor_offset])
                    y_motor_bracket_holes()
                        base_screw_hole();
    }
}
//
// List of cable clips
//
left_stay_x = max(-base_width / 2 + left_w / 2,
                  idler_end - z_bar_offset() + z_motor_bracket_hole_offset() + washer_diameter(M4_washer) / 2 + 1) + sheet_thickness(frame) / 2;

right_stay_x = max(base_width / 2 - right_w / 2,
                  motor_end + z_bar_offset() + z_motor_bracket_hole_offset() + washer_diameter(M4_washer) / 2 + 1) + sheet_thickness(frame) / 2 ;


z_gantry_wire_height = height - base_clearance - fixing_block_width() -fixing_block_height() -
                                               base_clearance - cable_clip_extent(base_clip_screw, endstop_wires);

cable_clips = [ // cable1, cable2 , position, vertical, rotation

    // near to the Y limit switch
    [endstop_wires, motor_wires,
        [base_width / 2 - right_w - cable_clip_extent(base_clip_screw, motor_wires), -Y_bar_length2 / 2 + 20, 0], false, 0],
    // at the foot of the gantry
    [endstop_wires, motor_wires,
        [base_width / 2 - right_w - cable_clip_extent(base_clip_screw, motor_wires), gantry_setback + 20, 0], false, 0],
    // bed wires
    [bed_wires, thermistor_wires,
        [20, base_depth / 2 -2 * base_clearance - fixing_block_width() - cable_clip_extent(base_clip_screw, bed_wires), 0], false, -90],
    // Z axis left
    [endstop_wires, fan_motor_wires,
        [left_stay_x + 15, gantry_setback + sheet_thickness(frame), z_gantry_wire_height], true, 90],

    // Z axis right
    [endstop_wires, fan_motor_wires,
        [right_stay_x - 15, gantry_setback + sheet_thickness(frame), z_gantry_wire_height], true, 90],

];

module place_cable_clips(holes = false) {
    for(clip = cable_clips) {
        translate(clip[2])
            rotate([clip[3] ? -90 : 0, 0, 0]) rotate([0, 0, clip[4]])
                if(holes)
                    cylinder(r = clip[3] ? (frame_nuts ? screw_clearance_radius(frame_clip_screw) : screw_pilot_hole(frame_clip_screw)) :
                                            screw_pilot_hole(base_clip_screw), h = 100, center = true);
                else
                    if(clip[3])
                        cable_clip_assembly(frame_clip_screw, frame_clip_screw_length, clip[0], clip[1]);
                    else
                        cable_clip_assembly(base_clip_screw, base_clip_screw_length, clip[0], clip[1]);
    }
}

//
// Frame
//
module fixing_blocks(upper = false) {
    w = fixing_block_width();
    h = fixing_block_height();
    t = sheet_thickness(frame);

    if(upper) {     // all screws into frame
        translate([left_stay_x + t / 2, gantry_setback + t, stay_height - base_clearance - h - w / 2]) // top
            rotate([0,-90,-90])
                child();

        translate([right_stay_x - t / 2, gantry_setback + t, stay_height - base_clearance - h - w / 2]) // top
            rotate([0,90, 90])
                child();

        translate([left_stay_x + t / 2, gantry_setback + t, base_clearance + h + w / 2])              // front
            rotate([0,-90,-90])
                child();

        translate([right_stay_x - t / 2, gantry_setback + t, base_clearance + h + w / 2])              // front
            rotate([0,90, 90])
                child();
    }
    else {  // one screw in the base
        for(x = [-base_width/2 + base_clearance + w /2,
                  base_width/2 - base_clearance - w /2,
                 -base_width/2 - base_clearance - w /2 + left_w,
                  base_width/2 + base_clearance + w /2 - right_w])
            translate([x, gantry_setback + t, 0])
                child();

        translate([left_stay_x + t / 2, gantry_setback + t + stay_depth - base_clearance - w / 2, 0]) // back
            rotate([0, 0,-90])
                child();

        translate([right_stay_x - t / 2, gantry_setback + t + stay_depth - base_clearance - w / 2, 0]) // back
            rotate([0,0, 90])
                child();
    }
}

module fixing_block_holes() {
    fixing_blocks()
        group() {
            fixing_block_v_hole(0)
                base_screw_hole();
            fixing_block_h_holes(0)
                frame_screw_hole();
        }

    fixing_blocks(true)
        group() {
            fixing_block_v_hole(0)
                frame_screw_hole();
            fixing_block_h_holes(0)
                frame_screw_hole();
        }
}

module frame_base() {
    difference() {
        translate([0,0, -sheet_thickness(base) / 2])
            sheet(base, base_width, base_depth, [base_corners, base_corners, base_corners, base_corners]);            // base

        fixing_block_holes();
        y_axis_screw_holes();

        translate([motor_end + z_bar_offset(), 0, 0])               // in case motor has second shaft
            cylinder(r = 4, h = 100, center = true);

        translate([idler_end - z_bar_offset(), 0, 0])
            cylinder(r = 4, h = 100, center = true);


        translate([X_origin, cable_clamp_y,0])
            ribbon_clamp_holes(bed_ways, base_screw)
                base_screw_hole();

        place_cable_clips(true);
    }
}


module frame_gantry() {
    difference() {
        translate([0, gantry_setback + sheet_thickness(frame) / 2, height / 2])
            rotate([90,0,0])
                if(single_piece_frame)
                    difference() {
                        sheet(frame, base_width, height, [frame_corners, frame_corners, 0, 0]);   // vertical plane
                        translate([X_origin, -gantry_thickness, 0])
                            rounded_rectangle([window_width,  height, sheet_thickness(frame) + 1], r = 5, center = true);
                    }
                else {
                    translate([-base_width / 2 + left_w / 2, 0, 0])
                        sheet(frame, left_w, height, [frame_corners, 0, 0, 0]);   // left side

                    translate([ base_width / 2 - right_w / 2, 0, 0])
                        sheet(frame, right_w, height, [0, frame_corners, 0, 0]);  // right side

                    translate([0, height / 2 - gantry_thickness / 2, -sheet_thickness(frame)])
                        sheet(frame, base_width, gantry_thickness, [frame_corners, frame_corners, 0, 0]); // top
                }

        fixing_block_holes();

        //
        // Z bar clamps
        //
        for(end = [idler_end, motor_end])
            translate([end, gantry_setback, height - base_clearance - bar_clamp_depth / 2])
                rotate([0, 90, 90])
                    bar_clamp_holes(Z_bar_dia)
                        frame_screw_hole();

        //
        // Z motor bracket holes
        //
        for(side = [idler_end - z_bar_offset(), motor_end + z_bar_offset()])
            translate([side, 0, Z_motor_length])
                z_motor_bracket_holes(gantry_setback)
                    frame_screw_hole();

        //
        // Z limit switch holes
        //
        translate([idler_end -z_bar_offset(), gantry_setback, Z0 - x_end_thickness() / 2])
            z_limit_screw_positions()
                frame_screw_hole();
        //
        // X ribbon clamp
        //
        translate([motor_end - x_motor_offset(), gantry_setback, height - base_clearance - ribbon_clamp_width(frame_screw)])
            ribbon_clamp_holes(x_end_ways, frame_screw)
                rotate([90, 0, 0])
                    frame_screw_hole();
        //
        // Wiring holes
        //
        translate([idler_end - bar_rail_offset(Z_bar_dia) + 0.5 * bar_clamp_tab,
                    gantry_setback, height - base_clearance - bar_clamp_depth - endstop_wires_hole_radius - base_clearance])
            rotate([90, 0, 0])
                wire_hole(endstop_wires_hole_radius);  // Z top endstop

        translate([-base_width / 2 + base_clearance + fixing_block_width() + base_clearance + motor_wires_hole_radius,
                    gantry_setback, motor_wires_hole_radius + hole_edge_clearance])
            rotate([90, 0, 0])
                wire_hole(motor_wires_hole_radius);    // Z lhs motor

        translate([max(motor_end + bar_rail_offset(Z_bar_dia),
                       base_width / 2 - right_w + fixing_block_width() + 2 * base_clearance + motor_wires_hole_radius),
                    gantry_setback, motor_wires_hole_radius + hole_edge_clearance])
            rotate([90, 0, 0])
                wire_hole(motor_wires_hole_radius);    // Z rhs motor

        translate([idler_end - bar_rail_offset(Z_bar_dia),
                    gantry_setback, Z_motor_length + z_motor_bracket_height() + endstop_wires_hole_radius])
            rotate([90, 0, 0])
                wire_hole(endstop_wires_hole_radius);  // bottom limit switch

        place_cable_clips(true);
    }
}

fan_y = gantry_setback + sheet_thickness(frame) + fixing_block_height() + fan_width(case_fan) / 2 + base_clearance;
fan_z = Y_carriage_height + fan_width(case_fan) / 2;

sanguinololu_z = 10;
sanguinololu_y = base_depth / 2 - 50 - sanguinololu_width(); // inset by 50 to leave room for USB plug

psu_z = height - psu_length(psu) / 2 - base_clearance;
psu_y = gantry_setback + sheet_thickness(frame) + fixing_block_height() + psu_width(psu) / 2;

module frame_stay(left, bodge = 0) {
    x = left ? left_stay_x : right_stay_x;

    difference() {
        translate([x, gantry_setback + sheet_thickness(frame) + stay_depth / 2, stay_height / 2])
            rotate([90,0,90])
                sheet(frame, stay_depth, stay_height, [0, frame_corners, 0, 0]);

        fixing_block_holes();

        if(left)
            translate([x + (sheet_thickness(frame) + fan_depth(case_fan)) / 2, fan_y, fan_z])
                rotate([0,90,0])
                    scale([1 + bodge, 1 + bodge, 1]) fan_holes(case_fan);       // scale prevents OpenCSG z buffer artifacts

        else {
            //
            // Electronics mounting holes
            //
            translate([x, sanguinololu_y, sanguinololu_z])
                rotate([90, 0, 90])
                    sanguinololu_screw_positions()
                        cylinder(r = M3_tap_radius, h = 100, center = true);

            translate([x, psu_y, psu_z])
                rotate([0, -90, 180])
                    psu_screw_positions(psu)
                        cylinder(r = psu_screw_hole_radius(psu), h = 100, center = true);

            //
            // Wiring holes
            //
            translate([x, gantry_setback + sheet_thickness(frame) + fixing_block_height() + motor_wires_hole_radius,
                          hole_edge_clearance + motor_wires_hole_radius]) {
                rotate([0, 90, 0])
                    wire_hole(motor_wires_hole_radius); // Z rhs motor at bottom

                translate([0, motor_wires_hole_radius + hole_edge_clearance + motor_wires_hole_radius, 0]) {
                    rotate([0, 90, 0])
                        wire_hole(motor_wires_hole_radius); // Y motor wires at bottom

                    translate([0, motor_wires_hole_radius + hole_edge_clearance + endstop_wires_hole_radius,
                                endstop_wires_hole_radius - motor_wires_hole_radius])
                        rotate([0, 90, 0])
                            wire_hole(endstop_wires_hole_radius); // Y endstop wires at bottom
                }
            }

            translate([x, gantry_setback + sheet_thickness(frame) + stay_depth - 2 * base_clearance - fixing_block_width() - bed_wires_hole_radius,
                          hole_edge_clearance + bed_wires_hole_radius]) {
                rotate([0, 90, 0])
                    wire_hole(bed_wires_hole_radius);     // Bed wires at bottom

                translate([0, -bed_wires_hole_radius - hole_edge_clearance - thermistor_wires_hole_radius,
                           thermistor_wires_hole_radius - bed_wires_hole_radius])
                    rotate([0, 90, 0])
                        wire_hole(thermistor_wires_hole_radius); // Bed thermistor wires
            }
        }
        translate([x, gantry_setback + sheet_thickness(frame) + endstop_wires_hole_radius + hole_edge_clearance, z_gantry_wire_height]) {
            translate([0, 0, cable_clip_offset(frame_clip_screw, endstop_wires)])
                rotate([0, 90, 0])
                    wire_hole(endstop_wires_hole_radius);           // Z endstop wires

            translate([0, fan_motor_wires_hole_radius - endstop_wires_hole_radius,
                      -cable_clip_offset(frame_clip_screw, fan_motor_wires)])
                rotate([0, 90, 0])
                    wire_hole(fan_motor_wires_hole_radius);         // Z  motor wires
        }
    }
}

module bed_fan_assembly() {
    assembly("bed_fan_assembly");
    translate([left_stay_x, fan_y, fan_z])
        rotate([0, -90, 0]) {
            translate([0, 0, -(sheet_thickness(frame) + fan_depth(case_fan)) / 2])
                fan_assembly(case_fan, sheet_thickness(frame) + fan_guard_thickness());

            translate([0, 0, sheet_thickness(frame) / 2])
                color(fan_guard_color) render() fan_guard(case_fan);
        }
    end("bed_fan_assembly");
}

module electronics_assembly() {
    thickness = sheet_thickness(frame) + washer_thickness(M3_washer) * 2;
    psu_screw = screw_longer_than(thickness + 2);
    if(psu_screw > thickness + 5)
        echo("psu_screw too long");

    assembly("electronics_assembly");
    translate([right_stay_x + sheet_thickness(frame) / 2, sanguinololu_y, sanguinololu_z])
        rotate([90, 0, 90]) {
            sanguinololu_screw_positions()
                pcb_spacer_assembly();

            translate([0, 0, pcb_spacer_height()])
                sanguinololu();
        }

    translate([right_stay_x + sheet_thickness(frame) / 2, psu_y, psu_z])
        rotate([0, -90, 180]) {
            psu_screw_positions(psu) group() {
                translate([0, 0, -sheet_thickness(frame)])
                    rotate([180, 0, 0])
                        screw_and_washer(psu_screw_type(psu), psu_screw, true);
            }
            psu(psu);
        }
    end("electronics_assembly");
}

module frame_assembly(show_gantry = true) {
    assembly("frame_assembly");

    ribbon_clamp_z = height - base_clearance - ribbon_clamp_width(frame_screw);

    translate([motor_end - x_motor_offset(), gantry_setback, ribbon_clamp_z])
        rotate([90, 0, 0]) {
            if(frame_nuts)
                ribbon_clamp_assembly(x_end_ways, frame_screw, frame_screw_length, sheet_thickness(frame), false, true);
            else
                ribbon_clamp_assembly(x_end_ways, frame_screw, frame_screw_length);

        translate([0, ribbon_clamp_width(frame_screw) / 2, 0])
            rotate([90, 0, 90])
                cable_strip(ribbon_clamp_slot(x_end_ways), gantry_setback - x_end_ribbon_clamp_y(),
                        (Z_travel + (ribbon_clamp_z - (Z_travel + Z0 + x_end_ribbon_clamp_z()))) * 2,
                        Z + Z0 + x_end_ribbon_clamp_z() - ribbon_clamp_z, 50);
        }

    translate([X_origin, cable_clamp_y,0]) {
        ribbon_clamp_assembly(bed_ways, base_screw, base_screw_length);

        translate([0, ribbon_clamp_width(base_screw), 0])
            rotate([90, 0, 90])
                cable_strip(ribbon_clamp_slot(bed_ways), Y_carriage_height - sheet_thickness(Y_carriage) / 2, Y_travel, Y);
    }

    place_cable_clips();

    frame_base();

    if(show_gantry) {

        fixing_blocks()
            fixing_block_assembly();

        fixing_blocks(true)
            fixing_block_assembly(true);

        frame_stay(true, eta);
        frame_stay(false);
        frame_gantry();
    }

    end("frame_assembly");
}

module machine_assembly() {
    assembly("machine_assembly");

    show_bed = true;

    translate([0,0, sheet_thickness(base)]) {
        bed_fan_assembly();
        electronics_assembly();

        x_axis_assembly(true);
        z_axis_assembly();
        y_axis_assembly(show_bed);
        //
        // Draw the possibly transparent bits last
        //
        frame_assembly(true);
    }
    end("machine_assembly");
}


machine_assembly();
//y_heatshield();
//frame_assembly();

module frame_base_dxf() projection(cut = true) translate([0,0, sheet_thickness(base) / 2]) frame_base();

module frame_left_dxf() projection(cut = true) translate([0, -gantry_setback - sheet_thickness(frame), left_stay_x]) rotate([0, 90, 0]) frame_stay(true);

module frame_right_dxf() projection(cut = true) translate([0, -gantry_setback - sheet_thickness(frame), right_stay_x]) rotate([0, 90, 0]) frame_stay(false);;

module frame_gantry_and_y_carriage_dxf() projection(cut = true) {
    translate([0,0, gantry_setback + sheet_thickness(frame) / 2]) rotate([-90, 0, 0]) frame_gantry();
    translate([X_origin, height - gantry_thickness - Y_carriage_depth / 2 -1, 0]) y_carriage();
}

module frame_gantry_dxf() projection(cut = true)
    translate([0,0, gantry_setback + sheet_thickness(frame) / 2]) rotate([-90, 0, 0]) frame_gantry();

module y_carriage_dxf() projection(cut = true) y_carriage();

module y_heatshield_dxf() projection(cut = true) y_heatshield();




echo("Width: ", base_width, " Depth: ", base_depth, " Height: ", height + sheet_thickness(base));

echo(left_w, window_width, right_w);

echo("X bar: ",  X_bar_length, " Y Bar 1: ", Y_bar_length, " Y Bar 2: ", Y_bar_length2, " Z Bar: ", Z_bar_length);
