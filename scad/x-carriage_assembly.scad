//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// X carriage, carries the extruder
//
include <x-carriage.scad>

module x_carriage_assembly(show_extruder = true, show_fan = true) {
    if(show_extruder) {
        rotate([0, 180, 0])
             extruder_assembly();

        for(end = [-1, 1])
            translate([extruder_mount_pitch / 2 * end, 0, nut_trap_thickness])
                rotate([0, 0, 45])
                    wingnut(M4_wingnut);
    }
    //
    // Fan assembly
    //
    if(show_fan)
        translate([0, 0, -hot_end_bodge(hot_end)])
            x_carriage_fan_assembly();

    assembly("x_carriage_assembly");
    color(x_carriage_color) render() x_carriage_stl();
    //
    // Fan bracket screws
    //
    for(side = [-1, 1])
        translate([fan_x + side * front_nut_pitch, -width / 2 - fan_bracket_thickness, front_nut_z]) {
            rotate([90, 0, 0])
                screw_and_washer(M3_cap_screw, 16);

            translate([0, fan_bracket_thickness + wall, 0])
                rotate([-90, 0, 0])
                    nut(M3_nut, true);
        }
    //
    // Bearings
    //
    for(end = [-1, 0, 1])
        translate([base_offset + bar_x * end, end ? -bar_y : bar_y, bar_offset]) {
            linear_bearing(X_bearings);
            translate([end * (zip_x - bar_x), 0, 0])
                rotate([0, -90, end ? 180 : 0])
                    scale([bearing_radius(X_bearings) / bearing_ziptie_radius(X_bearings), 1])
                        ziptie(small_ziptie, bearing_ziptie_radius(X_bearings));
        }
    //
    // Idler end belt clamp
    //
    translate([length / 2 + base_offset, -width / 2, x_carriage_offset() - ball_bearing_diameter(X_idler_bearing) / 2]) {
        mirror([1,0,0])
            color(x_belt_clamp_color) render() x_belt_clamp_stl();
        translate([-lug_width / 2, lug_screw, clamp_thickness])
            nut(M3_nut, true);
    }

    translate([length / 2 + base_offset - lug_width / 2, -width / 2 + lug_screw, 0])
        rotate([180, 0, 0])
            screw_and_washer(M3_cap_screw, 20);
    //
    // Motor end belt clamp
    //
    translate([-length / 2 + base_offset, -width / 2, x_carriage_offset() - pulley_inner_radius])
        translate([lug_width / 2, lug_screw, clamp_thickness])
            nut(M3_nut, true);

    translate([-length / 2 + base_offset, -width / 2, -(clamp_thickness + belt_thickness(X_belt))]) {
        color(x_belt_clamp_color) render() x_belt_grip_stl();
        translate([lug_width / 2, lug_screw, 0])
            rotate([180, 0, 0])
                screw_and_washer(M3_cap_screw, 25);
    }

    translate([-length / 2 + base_offset - tension_screw_pos, -width / 2 + slot_y, (x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt)) /2]) {
        rotate([0, -90, 0])
            screw(M3_cap_screw, tension_screw_length);    // tensioning screw

        translate([tension_screw_length + wall, belt_tensioner_height / 2, 0])
            rotate([90, 180, 0])
                color(x_belt_clamp_color) render() x_belt_tensioner_stl();

        translate([tension_screw_length + wall, 0, 0])
            rotate([90, 180, 0])
                belt_loop();
    }

    translate([-length / 2 + base_offset + lug_width - M3_nut_trap_depth, -width / 2 + slot_y, (x_carriage_offset() - pulley_inner_radius - belt_thickness(X_belt)) /2])
        rotate([90, 0, 90])
            nut(M3_nut, false);   // tensioning nut

    end("x_carriage_assembly");
}

if(0)
    if(0)  {
        intersection() {
            x_carriage_fan_duct_stl();
            *translate([0, 0, -10])
                cube(200);
        }
    }
    else
        if(0)
            x_carriage_fan_ducts_stl();
        else
            x_carriage_parts_stl();
else
    x_carriage_assembly(true, true);
