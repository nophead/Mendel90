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
use <fan-guard.scad>
use <wade.scad>
use <cable_clip.scad>
use <pcb_spacer.scad>
use <ATX_PSU_brackets.scad>
use <spool_holder.scad>
use <tube_cap.scad>
use <d-motor_bracket.scad>
include <positions.scad>

X = 0 * X_travel / 2; // - limit_switch_offset;
Y = 0 * Y_travel / 2; // - limit_switch_offset;
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
        translate([0, x_belt_offset(), Z + Z0])
            rotate([90, 0, 0]) render()
                union() {
                    difference() {
                        twisted_belt(X_belt, idler_end + x_idler_offset(), 0, ball_bearing_diameter(X_idler_bearing) / 2,
                            motor_end - x_motor_offset(), 0, pulley_ir(pulley_type), X_belt_gap - x_belt_loop_length());

                        translate([-X + X_origin - nozzle_x_offset() + (x_carriage_belt_gap() - X_belt_gap) / 2,
                                pulley_inner_radius + belt_thickness(X_belt) / 2, 0])
                            cube([X_belt_gap, belt_thickness(X_belt) * 3, belt_width(X_belt) * 2], center = true);
                    }
                }

    end("x_axis_assembly");
}
//
// X motor with wiring
//
module x_motor_assembly() {
    assembly("x_motor_assembly");
    z_cable_extra = 100;
    z_cable_travel = (Z_travel + (ribbon_clamp_z - (Z_travel + Z0 + x_end_ribbon_clamp_z()))) * 2;

    pmax = [-X_travel / 2 + X_origin - motor_end, 0, x_carriage_offset()] + extruder_connector_offset();

    mirror([1,0,0])
        x_end_assembly(true);

    if(!exploded)
        translate([-x_motor_offset(),
                   gantry_setback - sheet_thickness(frame) / 2 + ribbon_clamp_slot_depth() - cable_strip_thickness,
                   ribbon_clamp_z - (Z + Z0) + ribbon_clamp_width(frame_screw) / 2])
            rotate([0, -90, 180])
                cable_strip(
                    x_end_ways,
                    z_cable_strip_depth,
                    z_cable_travel,
                    Z + Z0 + x_end_ribbon_clamp_z() - ribbon_clamp_z,
                    z_cable_extra
                );

    elliptical_cable_strip(
        extruder_ways,
        x_end_extruder_ribbon_clamp_offset(),
        [-X + X_origin - motor_end, 0, x_carriage_offset()] + extruder_connector_offset(),
        pmax
    );

    translate([-X + X_origin - motor_end + cable_strip_thickness, - ribbon_clamp_width(M3_cap_screw), x_carriage_offset()] + extruder_connector_offset())
        rotate([-90, 180, 0])
            d_shell_assembly(NEMA17);

    ribbon_cable(x_end_ways,
        10                      // Width of D type
        + 12                    // To back of shell
        + elliptical_cable_strip_length(x_end_extruder_ribbon_clamp_offset(), pmax)
        + 68                    // Across the X motor bracket
        + cable_strip_length(z_cable_strip_depth, z_cable_travel, z_cable_extra)
        + 5                     // Through the slot
        + 180                   // Down back of gantry
        + 90                    // Across to Melzi
        + 5);                   // Strip

    end("x_motor_assembly");
}
//
// Z axis
//
Z_motor_length = NEMA_length(Z_motor);
Z_bar_length = height - Z_motor_length - base_clearance;

module z_end(motor_end) {
    Z_screw_length = Z0 + Z_travel + x_end_height() + axis_end_clearance
        - (Z_motor_length + NEMA_shaft_length(Z_motor) + z_coupling_gap());

    if(!motor_end && bottom_limit_switch)
        translate([-z_bar_offset(), gantry_setback, Z0 - x_end_thickness() / 2])
            z_limit_switch_assembly();

    translate([-z_bar_offset(), 0, Z_motor_length]) {

        z_motor_assembly(gantry_setback, motor_end);

        translate([0, 0, NEMA_shaft_length(Z_motor) + z_coupling_gap() + Z_screw_length / 2]) {
            studding(d = Z_screw_dia, l = Z_screw_length);

            translate([0, 0, -Z_screw_length / 2 + z_coupling_length() / 2 - 1])
                render() z_screw_pointer_stl();
        }

        //
        // lead nut
        //
        translate([0, 0, Z + Z0 + x_end_z_nut_z() + nut_thickness(Z_nut) - Z_motor_length])
            rotate([180, 0, 0])
                nut(Z_nut, brass = true);

        translate([z_bar_offset(), 0, Z_bar_length / 2])
            rod(Z_bar_dia, Z_bar_length);

        translate([z_bar_offset(), gantry_setback, Z_bar_length - bar_clamp_depth / 2]) {
            rotate([90,motor_end ? 90 : - 90, 0])
                z_bar_clamp_assembly(Z_bar_dia, gantry_setback, bar_clamp_depth, !motor_end);
        }
    }
}

module z_axis_assembly() {
    assembly("z_axis_assembly");

    translate([motor_end, 0, 0])
        mirror([1,0,0])
            z_end(true);

    translate([idler_end, 0, 0])
        z_end(false);

    translate([motor_end, 0, Z + Z0])
        x_motor_assembly();

    translate([idler_end, 0, Z + Z0])
        x_end_assembly(false);

    end("z_axis_assembly");
}

//
// Y axis
//
Y_bar_length =  base_depth - 2 * base_clearance;

Y_bar_length2 = Y_travel + limit_switch_offset + bearing_mount_length(Y_bearings) + 2 * bar_clamp_depth + axis_end_clearance + bar_clamp_switch_y_offset();

Y_bar_spacing = Y_carriage_width - bearing_mount_width(Y_bearings);
Y_bearing_inset = bearing_mount_length(Y_bearings) / 2 + bar_clamp_depth + axis_end_clearance;

Y_belt_motor_offset = 13 + belt_width(Y_belt) / 2;

Y_belt_line = X_origin - ribbon_clamp_slot(bed_ways) / 2 - y_belt_anchor_width() / 2 - 5;

Y_motor_end = -base_depth / 2 + y_motor_bracket_width() / 2 + base_clearance;
Y_idler_end =  base_depth / 2 - y_idler_offset() - base_clearance - y_idler_travel();
Y_belt_anchor_m = Y_motor_end + NEMA_width(Y_motor) / 2 + Y_travel / 2;
Y_belt_anchor_i = Y_idler_end - y_idler_clearance() - Y_travel / 2;
Y_belt_end = y_belt_anchor_depth() / 2 + 15;
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

Y2_rail_offset = (bar_clamp_switch_y_offset() - axis_end_clearance) / 2;

module y_rails() {
    translate([-Y_bar_spacing / 2, 0, 0])
        rail(Y_bar_length, Y_bar_height);

    rotate([0,0,180])
        translate([-Y_bar_spacing / 2, Y2_rail_offset, 0])
            rail(Y_bar_length2, Y_bar_height, true);
}

module rail_holes(length) {
    for(end = [-1, 1])
        translate([0, end * (length / 2 - bar_clamp_depth / 2), 0])
            rotate([0, 0, 90])
                bar_clamp_holes(Y_bar_dia, true)
                    base_screw_hole();
}

module y_rail_holes() {
    translate([-Y_bar_spacing / 2, 0, 0])
        rail_holes(Y_bar_length);

    rotate([0,0,180])
        translate([-Y_bar_spacing / 2, Y2_rail_offset, 0])
             rail_holes(Y_bar_length2);
}

module y_carriage() {
    difference() {
        sheet(Y_carriage, Y_carriage_width, Y_carriage_depth, [3,3,3,3]);

        translate([0, ribbon_clamp_y, 0])
            rotate([180, 0, 0])
                ribbon_clamp_holes(bed_ways, cap_screw)
                    cylinder(r = screw_clearance_radius(cap_screw), h = 100, center = true);

        translate([0, Y_carriage_depth / 2, 0])
            cube([ribbon_clamp_slot(bed_ways) + 2, ribbon_clamp_width(cap_screw), sheet_thickness(Y_carriage) + 1], center = true);

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

        for(x = [-bed_holes[0] / 2, bed_holes[0] / 2])
            for(y = [-bed_holes[1] / 2, bed_holes[1] / 2])
                translate([x, y, 0])
                    cylinder(r = 2.5/2, h = 100, center = true);
    }
}

module y_heatshield() {
    layers = pillar_height(bed_pillars) / sheet_thickness(Cardboard);
    width =  Y_carriage_width - 2 * bar_clamp_tab;
    for(i = [0 : layers - 1])
        translate([0, 0, (sheet_thickness(Cardboard) + exploded * 50) * i]) {
            assign(k = ((i % 2) ? 0.9 : 1), c = sheet_colour(Cardboard))
                color([c[0] * k, c[1] * k, c[2] * k, c[3]])
                    difference() {
                        sheet(Cardboard, width, Y_carriage_depth);

                        if(i == 0) {
                            translate([Y_bar_spacing / 2, 0, 0])
                                rotate([0,180,0])
                                    bearing_mount_holes()
                                        cube([10,10, 100], center = true);

                            for(end = [-1, 1])
                                translate([-Y_bar_spacing / 2, end * (Y_carriage_depth / 2 - Y_bearing_inset), 0])
                                    rotate([0,180,0])
                                        bearing_mount_holes()
                                            cube([10, 10, 100], center = true);

                            for(end = [[Y_belt_anchor_m, 0], [Y_belt_anchor_i, 180]])
                                translate([Y_belt_line - X_origin, end[0], 0])
                                    rotate([0, 180, end[1]])
                                        hull()
                                            y_belt_anchor_holes()
                                                cube([10, 10, 100],center =true);
                        }

                        if(i == layers - 1)
                            translate([0, Y_carriage_depth / 2, 0])
                                cube([15, 180, 100], center = true);

                        translate([0, Y_carriage_depth / 2, 0])
                            cube([ribbon_clamp_length(bed_ways, cap_screw) + 5, 70, 100], center = true);
                    }
                }
}


module y_carriage_assembly(solid = true) {
    carriage_bottom = Y_carriage_height - sheet_thickness(Y_carriage) / 2;
    carriage_top = Y_carriage_height + sheet_thickness(Y_carriage) / 2;

    assembly("y_carriage_assembly");

    translate([Y_bar_spacing / 2, 0, Y_bar_height])
        rotate([0,180,0])
            y_bearing_assembly(Y_bearing_holder_height);

    for(end = [-1, 1])
        translate([-Y_bar_spacing / 2, end * (Y_carriage_depth / 2 - Y_bearing_inset), Y_bar_height])
            rotate([0,180,0])
                y_bearing_assembly(Y_bearing_holder_height);

    for(end = [[Y_belt_anchor_m, 0, false], [Y_belt_anchor_i, 180, true]])
        translate([Y_belt_line - X_origin, end[0], carriage_bottom])
            rotate([0, 180, end[1]])
                y_belt_anchor_assembly(Y_belt_clamp_height, end[2]);

    translate([0, ribbon_clamp_y, carriage_top + ribbon_clamp_thickness()])
        rotate([180, 0, 0])
            color(ribbon_clamp_color) render() ribbon_clamp(bed_ways, cap_screw, nutty = true);

    translate([0, ribbon_clamp_y, carriage_bottom])
        rotate([180, 0, 0])
            ribbon_clamp_assembly(bed_ways, cap_screw, 20, sheet_thickness(Y_carriage) + ribbon_clamp_thickness(true), false, false);


    translate([0, 0, Y_carriage_height + eta * 2])
        if(solid)
            y_carriage();
        else
            %color([0.5,0.5,0.5,0.5]) y_carriage();

    end("y_carriage_assembly");
}

module print_bed_assembly(show_bed = true, show_heatshield = true) {
    assembly("print_bed_assembly");
    //
    // Y carriage
    //
    translate([X_origin, Y + Y0, 0]) {

        translate([0, 0, Y_carriage_height + sheet_thickness(Y_carriage) / 2]) {
            if(show_bed) {
                bed_assembly(Y);
                if(show_heatshield)
                    translate([0, 0, sheet_thickness(Cardboard) / 2])
                        y_heatshield();
            }
        }

        translate([0, -(Y + Y0) + ribbon_clamp_y + ribbon_clamp_width(base_screw) / 2, ribbon_clamp_slot_depth() - cable_strip_thickness])
            rotate([90, 0, 90])
                cable_strip(
                    bed_ways,
                    y_cable_strip_depth,
                    Y_travel,
                    Y
                );

        y_carriage_assembly(show_bed);

    }
    end("print_bed_assembly");
}

module y_axis_assembly(show_bed = true, show_heatshield = true, show_carriage = true) {
    assembly("y_axis_assembly");

    translate([X_origin, 0, 0])
        y_rails();

    translate([Y_belt_line, Y_motor_end, y_motor_height()]) rotate([90,0,-90]) {
        color(belt_color)
        render() difference() {
            twisted_belt(Y_belt,
                         Y_motor_end - Y_idler_end,
                         pulley_inner_radius - ball_bearing_diameter(Y_idler_bearing) / 2,
                         ball_bearing_diameter(Y_idler_bearing) / 2,
                         0, 0, pulley_ir(pulley_type), Y_belt_gap);
            translate([-(Y_belt_anchor_i + Y_belt_anchor_m) / 2 + Y_motor_end - Y0 - Y, pulley_inner_radius + belt_thickness(Y_belt)/2, 0])
                cube([Y_belt_gap, belt_thickness(Y_belt) * 2, belt_width(Y_belt) * 2], center = true);
        }

        translate([0, 0, -Y_belt_motor_offset])
            y_motor_assembly();
    }
    translate([Y_belt_line, Y_idler_end, 0])
        y_idler_assembly();

    if(show_carriage)
        print_bed_assembly(show_bed, show_heatshield);

    end("y_axis_assembly");
}

module y_axis_screw_holes() {
    translate([X_origin, 0, 0]) {
        y_rail_holes();

        translate([Y_belt_line - X_origin, Y_idler_end, 0])
            y_idler_screw_hole();

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

z_gantry_wire_height = height - base_clearance - fixing_block_width() -fixing_block_height() -
                                               base_clearance - cable_clip_extent(base_screw, endstop_wires);

bed_wires_y = Y0 + Y_bar_length2 / 2 - Y2_rail_offset + cable_clip_extent(base_screw, thermistor_wires);

Y_cable_clip_x = base_width / 2 - right_w - cable_clip_extent(base_screw, motor_wires);
Y_front_cable_clip_y = -Y_bar_length2 / 2 + 20;
Y_back_cable_clip_y = gantry_Y + sheet_thickness(frame) + fixing_block_height() - 5;

cable_clips = [ // cable1, cable2 , position, vertical, rotation

    // near to the Y limit switch
    [endstop_wires, motor_wires,
        [Y_cable_clip_x, Y_front_cable_clip_y, 0], false, 0],
    // at the foot of the gantry
    [endstop_wires, motor_wires,
        [Y_cable_clip_x, Y_back_cable_clip_y, 0], false, 0],
    // bed wires
    [bed_wires, thermistor_wires,
        [20, bed_wires_y, 0], false, -90],
    // Z axis left
    [endstop_wires, fan_motor_wires,
        [left_stay_x + 15, gantry_Y + sheet_thickness(frame), z_gantry_wire_height], true, 90],

    // Z axis right
    [endstop_wires, fan_motor_wires,
        [right_stay_x - 15, gantry_Y + sheet_thickness(frame), z_gantry_wire_height], true, 90],

];

module place_cable_clips(holes = false) {
    for(clip = cable_clips) {
        translate(clip[2])
            rotate([clip[3] ? -90 : 0, 0, 0]) rotate([0, 0, clip[4]])
                if(holes)
                    cable_clip_hole(clip[3], clip[0], clip[1]);
                else
                    cable_clip_assembly(clip[3], clip[0], clip[1]);
    }
}

//
// Frame
//
window_corner_rad = 5;

module fixing_blocks(holes = false) {
    w = fixing_block_width();
    h = fixing_block_height();
    t = sheet_thickness(frame);

    assign($upper = true) {     // all screws into frame
        translate([left_stay_x + t / 2, gantry_Y + t, stay_height - base_clearance - h - w / 2]) // top
            rotate([0,-90,-90])
                child();

        translate([right_stay_x - t / 2, gantry_Y + t, stay_height - base_clearance - h - w / 2]) // top
            rotate([0,90, 90])
                child();

        translate([left_stay_x + t / 2, gantry_Y + t, base_clearance + h + w / 2])              // front
            rotate([0,-90,-90])
                child();

        translate([right_stay_x - t / 2, gantry_Y + t, base_clearance + h + w / 2])              // front
            rotate([0,90, 90])
                child();
    }
    assign($upper = false) {  // one screw in the base
        assign($rear = true) {
            translate([left_stay_x + t / 2, base_depth / 2 - base_clearance - w / 2, 0]) // back
                rotate([0, 0,-90])
                    child();

            translate([right_stay_x - t / 2, base_depth / 2 - base_clearance - w / 2, 0]) // back
                rotate([0, 0, 90])
                    child();
        }

        assign($rear = false) {
            for(x = [-base_width/2 + base_clearance + w /2,
                      base_width/2 - base_clearance - w /2,
                     -base_width/2 - base_clearance - w /2 + left_w,
                      right_stay_x + sheet_thickness(frame) / 2 + w / 2 + base_clearance])
                translate([x, gantry_Y + t, 0])
                    child();


            // extra holes for bars
            if(holes && base_nuts) {
                translate([left_stay_x + t / 2, -base_depth / 2 + base_clearance + w / 2, 0]) // front
                    rotate([0, 0,-90])
                        child();

                translate([right_stay_x - t / 2, -base_depth / 2 + base_clearance + w / 2, 0]) // front
                    rotate([0,0, 90])
                        child();
            }

        }
    }
}

module fixing_block_holes() {
    fixing_blocks(holes = true)
        group() {
            fixing_block_v_hole(0)
                if($upper)
                    frame_screw_hole();
                else
                    base_screw_hole();

            fixing_block_h_holes(0)
                frame_screw_hole();
        }
}

Y_motor_stay_hole_y = gantry_Y + sheet_thickness(frame) + fixing_block_height() + motor_wires_hole_radius;

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


        translate([X_origin, ribbon_clamp_y,0])
            ribbon_clamp_holes(bed_ways, base_screw)
                base_screw_hole();

        if(atx_psu(psu))
            translate([right_stay_x + sheet_thickness(frame) / 2, psu_y, psu_z])
                rotate([0, -90, 180])
                    atx_screw_positions(psu, true)
                        base_screw_hole();

        place_cable_clips(true);
        //
        // Holes for wires to run underneath
        //
        if(base_nuts) {
            // Y motor
            translate([Y_belt_line + Y_belt_motor_offset + NEMA_length(Y_motor) - 5, Y_motor_end, 0])
                wire_hole(motor_wires_hole_radius);

            translate([Y_cable_clip_x + cable_clip_offset(base_screw, motor_wires), Y_motor_stay_hole_y, 0])
                wire_hole(motor_wires_hole_radius);

            // Y limit
            translate([X_origin + Y_bar_spacing / 2 + bar_rail_offset(Y_bar_dia) - bar_clamp_tab / 2,
                       Y_front_cable_clip_y - 5, 0])
                wire_hole(endstop_wires_hole_radius);

            translate([Y_cable_clip_x - cable_clip_offset(base_screw, endstop_wires),
                    Y_motor_stay_hole_y + motor_wires_hole_radius + hole_edge_clearance + endstop_wires_hole_radius, 0])
                wire_hole(endstop_wires_hole_radius);
        }
    }
}


module frame_gantry() {
    difference() {
        translate([0, gantry_Y + sheet_thickness(frame) / 2, height / 2])
            rotate([90,0,0])
                if(single_piece_frame)
                    difference() {
                        sheet(frame, base_width, height, [frame_corners, frame_corners, 0, 0]);   // vertical plane
                        translate([X_origin, -gantry_thickness, 0])
                            rounded_rectangle([window_width,  height, sheet_thickness(frame) + 1], r = window_corner_rad, center = true);
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
            translate([end, gantry_Y, height - base_clearance - bar_clamp_depth / 2])
                rotate([0, 90, 90])
                    bar_clamp_holes(Z_bar_dia, false)
                        frame_screw_hole();

        //
        // Z motor bracket holes
        //
        for(side = [idler_end - z_bar_offset(), motor_end + z_bar_offset()])
            translate([side, 0, Z_motor_length])
                z_motor_bracket_holes(gantry_setback);

        //
        // Z limit switch holes
        //
        translate([idler_end -z_bar_offset(), gantry_Y, Z0 - x_end_thickness() / 2])
            z_limit_screw_positions()
                frame_screw_hole();
        //
        // X ribbon clamp
        //
        translate([motor_end - x_motor_offset(), gantry_Y, ribbon_clamp_z]) {
            ribbon_clamp_holes(x_end_ways, frame_screw)
                rotate([90, 0, 0])
                    frame_screw_hole();

            if(cnc_sheets)
                translate([0, 0, ribbon_clamp_width(frame_screw) / 2 + 5])
                    rotate([90, 0, 0])
                        slot(r = 2.5 / 2, l = ribbon_clamp_slot(x_end_ways), h = 100, center = true);

        }
        //
        // PSU bracket hole
        //
        if(atx_psu(psu))
            translate([right_stay_x + sheet_thickness(frame) / 2, psu_y, psu_z])
                rotate([0, -90, 180])
                    atx_screw_positions(psu, false)
                        frame_screw_hole();
        //
        // Wiring holes
        //
        translate([idler_end - bar_rail_offset(Z_bar_dia) + 0.5 * bar_clamp_tab,
                    gantry_Y, height - base_clearance - bar_clamp_depth - endstop_wires_hole_radius - base_clearance])
            rotate([90, 0, 0])
                wire_hole(endstop_wires_hole_radius);  // Z top endstop

        translate([-base_width / 2 + base_clearance + fixing_block_width() + base_clearance + motor_wires_hole_radius, gantry_Y, 0])
            rotate([90, 0, 0])
                wire_hole_or_slot(motor_wires_hole_radius);    // Z lhs motor

        translate([max(motor_end + bar_rail_offset(Z_bar_dia),
                       base_width / 2 - right_w + fixing_block_width() + 2 * base_clearance + motor_wires_hole_radius),
                    gantry_Y, fixing_block_height() + motor_wires_hole_radius + base_clearance])
            rotate([90, 0, 0])
                wire_hole(motor_wires_hole_radius);    // Z rhs motor

        translate([idler_end - bar_rail_offset(Z_bar_dia),
                    gantry_Y, Z_motor_length + z_motor_bracket_height() + endstop_wires_hole_radius])
            rotate([90, 0, 0])
                wire_hole(endstop_wires_hole_radius);  // bottom limit switch

        place_cable_clips(true);
    }
}

module frame_stay(left, bodge = 0) {
    x = left ? left_stay_x : right_stay_x;

    difference() {
        translate([x, gantry_Y + sheet_thickness(frame) + stay_depth / 2, stay_height / 2])
            rotate([90,0,90])
                sheet(frame, stay_depth, stay_height, [0, frame_corners, 0, 0]);

        fixing_block_holes();

        spool_holder_holes();

        if(left)
            translate([x + (sheet_thickness(frame) + fan_depth(case_fan)) / 2, fan_y, fan_z])
                rotate([0,90,0])
                    scale([1 + bodge, 1 + bodge, 1]) fan_holes(case_fan);       // scale prevents OpenCSG z buffer artifacts

        else {
            //
            // Electronics mounting holes
            //
            translate([x, controller_y, controller_z])
                rotate([90, 0, 90])
                    controller_screw_positions(controller)
                        cylinder(r = frame_nuts ? M3_clearance_radius : M3_tap_radius, h = 100, center = true);

            translate([x, psu_y, psu_z])
                if(atx_psu(psu))
                    rotate([0, -90, 180]) {
                        atx_screw_positions(psu)
                            frame_screw_hole();

                        atx_resistor_holes(psu);
                    }
                else
                    rotate([0, 90, 0])
                        psu_screw_positions(psu)
                            cylinder(r = psu_screw_hole_radius(psu), h = 100, center = true);

            //
            // Wiring holes
            //
            translate([x, Y_motor_stay_hole_y, 0]) {
                rotate([90, 0, 90])
                    wire_hole_or_slot(motor_wires_hole_radius); // Y motor wires at bottom

                translate([0, motor_wires_hole_radius + hole_edge_clearance + endstop_wires_hole_radius, 0])
                    rotate([90, 0, 90])
                        wire_hole_or_slot(endstop_wires_hole_radius); // Y endstop wires at bottom
            }

            translate([x, bed_wires_y + cable_clip_offset(base_screw, bed_wires), 0])
                rotate([90, 0, 90])
                    wire_hole_or_slot(bed_wires_hole_radius);     // Bed wires at bottom

            translate([x, bed_wires_y - cable_clip_offset(base_screw, thermistor_wires),0])
                rotate([90, 0, 90])
                    wire_hole_or_slot(thermistor_wires_hole_radius); // Bed thermistor wires
        }
        translate([x, gantry_Y + sheet_thickness(frame), z_gantry_wire_height]) {
            translate([0, 0, cable_clip_offset(frame_screw, endstop_wires)])
                rotate([0, 90, 0])
                    wire_hole_or_slot(endstop_wires_hole_radius);           // Z endstop wires

            translate([0, 0, -cable_clip_offset(frame_screw, fan_motor_wires)])
                rotate([0, 90, 0])
                    wire_hole_or_slot(fan_motor_wires_hole_radius);         // Z  motor wires
        }
    }
}

module bed_fan_assembly(show_fan = false) {
    assembly("bed_fan_assembly");
    translate([left_stay_x, fan_y, fan_z])
        rotate([0, -90, 0]) {
            translate([0, 0, -(sheet_thickness(frame) + fan_depth(case_fan)) / 2])
                fan_assembly(case_fan, sheet_thickness(frame) + fan_guard_thickness(), include_fan || show_fan);

            translate([0, 0, sheet_thickness(frame) / 2])
                color(fan_guard_color) render() fan_guard(case_fan);
        }
    end("bed_fan_assembly");
}

module electronics_assembly() {
    assembly("electronics_assembly");
    translate([right_stay_x + sheet_thickness(frame) / 2, controller_y, controller_z])
        rotate([90, 0, 90]) {
            controller_screw_positions(controller)
                pcb_spacer_assembly();

            translate([0, 0, pcb_spacer_height()])
                controller(controller);
        }

    end("electronics_assembly");
}

module psu_assembly() {
    thickness = sheet_thickness(frame) + washer_thickness(M3_washer) * 2;
    psu_screw = screw_longer_than(thickness + 2);
    if(psu_screw > thickness + 5 && psu_screw_from_back(psu))
        echo("psu_screw too long");

    assembly("psu_assembly");

    translate([right_stay_x + sheet_thickness(frame) / 2, psu_y, psu_z])
        rotate([0, 90, 0]) {
            psu_screw_positions(psu) group() {
                if(psu_screw_from_back(psu))
                    translate([0, 0, -sheet_thickness(frame)])
                        rotate([180, 0, 0])
                            screw_and_washer(psu_screw_type(psu), psu_screw, true);
                else
                    screw_and_washer(frame_screw, frame_screw_length, true);
            }
            if(atx_psu(psu))
                rotate([0, 0, 180])
                    atx_bracket_assembly();
            else
                if(psu_width(psu))              // not external PSU
                    translate([-psu_length(psu) / 2, psu_width(psu) / 2, 0])
                        mains_inlet_assembly();

            if(exploded)
                %color([0.5,0.5,0.5,0.5]) psu(psu);
            else
                psu(psu);
        }
    end("psu_assembly");
}

module frame_assembly(show_gantry = true) {
    assembly("frame_assembly");

    translate([motor_end - x_motor_offset(), gantry_Y, ribbon_clamp_z])
        rotate([90, 0, 0]) {
            if(frame_nuts)
                ribbon_clamp_assembly(x_end_ways, frame_screw, frame_screw_length, sheet_thickness(frame), false, true, nutty = true);
            else
                ribbon_clamp_assembly(x_end_ways, frame_screw, frame_screw_length);
        }

    translate([X_origin, ribbon_clamp_y,0]) {
        if(base_nuts)
            ribbon_clamp_assembly(bed_ways, base_screw, base_screw_length, sheet_thickness(base), false, true, nutty = true);
        else
            ribbon_clamp_assembly(bed_ways, base_screw, base_screw_length);

    }

    place_cable_clips();

    frame_base();
    if(base_nuts) {
        for(side = [ left_stay_x + fixing_block_height() / 2 + sheet_thickness(frame) / 2,
                    right_stay_x - fixing_block_height() / 2 - sheet_thickness(frame) / 2])
            explode([0, 0, -15])
            translate([side, 0,  -sheet_thickness(base)])
                tube_assembly();
    }

    if(show_gantry) {

        fixing_blocks()
            fixing_block_assembly($upper, $rear);

        frame_stay(true, eta);
        frame_stay(false);
        frame_gantry();
    }

    end("frame_assembly");
}


module machine_assembly(show_bed = true, show_heatshield = true, show_spool = true) {
    assembly("machine_assembly");

    translate([0,0, sheet_thickness(base)]) {
        bed_fan_assembly();
        electronics_assembly();
        psu_assembly();

        if(show_spool)
            spool_assembly(left_stay_x, right_stay_x);

        translate([0, Y0, 0]) {
            x_axis_assembly(true);
            z_axis_assembly();
        }

        y_axis_assembly(show_bed, show_heatshield);
        //
        // Draw the possibly transparent bits last
        //
        frame_assembly(true);
    }
    end("machine_assembly");
}



machine_assembly(true);
//y_heatshield();
//frame_assembly(show_spool = false);
//y_axis_assembly(true);

//z_axis_assembly();
//x_axis_assembly(false);



module frame_all() projection(cut = true) {
    translate([0,0, gantry_Y + sheet_thickness(frame) / 2]) rotate([-90, 0, 0]) frame_gantry();
    translate([X_origin, height - gantry_thickness - Y_carriage_depth / 2 -1, 0]) y_carriage();
    translate([0, -base_depth / 2 - 2, sheet_thickness(base) / 2]) frame_base();

    translate([-base_width / 2 - 2 + gantry_Y + sheet_thickness(frame), 0, left_stay_x])  rotate([0, 90, 90]) frame_stay(true);
    translate([ base_width / 2 + 2 + stay_depth + gantry_Y + sheet_thickness(frame), 0, right_stay_x]) rotate([0, 90, 90]) frame_stay(false);
}

module frame_base_dxf() projection(cut = true) translate([0,0, sheet_thickness(base) / 2]) frame_base();

module frame_left_dxf() projection(cut = true) translate([0, -gantry_Y - sheet_thickness(frame), left_stay_x]) rotate([0, 90, 0]) frame_stay(true);

module frame_right_dxf() projection(cut = true) mirror([0,1,0]) translate([0,-gantry_Y - sheet_thickness(frame), right_stay_x]) rotate([0, 90, 0]) frame_stay(false);

module y_carriage_dxf() projection(cut = true) y_carriage();

module y_heatshield_dxf() projection(cut = true) y_heatshield();

module frame_gantry_dxf(drill = !cnc_sheets) {
    corner_rad = window_corner_rad;
    projection(cut = true) translate([0,0, gantry_Y + sheet_thickness(frame) / 2]) rotate([-90, 0, 0]) frame_gantry();
    if(drill)
        for(side = [-1, 1])
            translate([X_origin + side * (window_width / 2 - corner_rad), height - gantry_thickness - corner_rad])
                circle(corner_rad - eta);
}

module frame_gantry_and_y_carriage_dxf() {
    top = height - gantry_thickness;
    bottom = Y_carriage_depth;
    gap = cnc_tool_dia * 2 + 1;
    h = floor(top - bottom - 2 * gap);
    w = floor(window_width - 2 * gap);
    frame_gantry_dxf(false);
    translate([X_origin, Y_carriage_depth / 2]) y_carriage_dxf();
    if(h > 20)
        *translate([X_origin, (top + bottom) / 2])
            square([w, h], center = true);                        // make the offcut a rectangle

}

module frame_stays_dxf() {
    frame_left_dxf();
    translate([0, -4])
        frame_right_dxf();
}

total_height = height + sheet_thickness(base) + (base_nuts ? tube_height(AL_square_tube) : 0);
spool_height = total_height - height + spool_z + spool_diameter(spool) / 2;

echo("Width: ", base_width, " Depth: ", base_depth, " Height: ", total_height, " Spool Height:", spool_height);

echo("X bar: ",  X_bar_length, " Y Bar 1: ", Y_bar_length, " Y Bar 2: ", Y_bar_length2, " Z Bar: ", Z_bar_length);
