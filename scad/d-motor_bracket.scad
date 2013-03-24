//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Bracket to mount 9 way D type to back of motor
//
include <conf/config.scad>
use <ribbon_clamp.scad>

connector = DCONN15;
pcb = true;
idc = true;

thickness = 2.4;
lid_thickness = 2.4;

wall = 2;
front_thickness = wall + No2_pilot_radius + washer_diameter(M2p5_washer) / 2 + 1;
slot_width = d_slot_length(connector);
slot_height = 11;
face_height = 13;
flange_clearance = 0.2;
flange_width = d_flange_length(connector) + 2 * flange_clearance;
flange_height = d_flange_width(connector) + flange_clearance;
flange_thickness = d_flange_thickness(connector) + flange_clearance;


overlap = 5;                            // how much it overlaps the side of the motor
//length = overlap + thickness + (pcb ? 14 : 20);
length = overlap + thickness + 20;
height = slot_height / 2 + face_height / 2 + thickness;
d_width = flange_width + 2 * wall;
nut_slot = nut_thickness(M3_nut) + 0.3;
lug_depth = nut_slot + 3 * wall;
lug_width = 2 * nut_flat_radius(M3_nut) + wall;
lug_height = thickness + slot_height / 2 + M3_nut_radius;
screw_x = length - wall - No2_pilot_radius;
screw_y = (d_width + slot_width) / 4;
pitch = d_width + 2 * nut_flat_radius(M3_nut);

cable_guide_width = 20;
cable_guide_thickness = 4;
cable_screw = M3_cap_screw;

shell_front = front_thickness;
shell_length = shell_front + 12 + ribbon_clamp_width(cable_screw);
shell_screw_x = shell_length - wall - No2_pilot_radius;

pcb_width = 24.13;
pcb_length = 33.02;
pcb_offset = 3 * 1.27;


nut_x = length + flange_thickness + wall -lug_depth + wall;

function d_motor_bracket_offset(motor) = NEMA_holes(motor)[0] + screw_head_radius(M3_cap_screw) + d_width / 2 + lug_width;

//
// Lid to retain connector and nuts
//
module d_motor_bracket_lid_stl(motor = NEMA17, nuts = true) {
    if(nuts)
        stl("d_motor_bracket_lid");
    else
        stl("d_shell_lid");

    lid_width = front_thickness + flange_thickness + wall;
    nut_cover_width = d_width + 2 * lug_width;
    nut_cover_height = height + lid_thickness - lug_height - flange_clearance;
    nut_cover_depth = lug_depth;

    difference() {
        union() {
            if(nuts) {
                translate([length - front_thickness + lid_width - nut_cover_depth / 2, 0, 0])
                    rounded_rectangle([nut_cover_depth, nut_cover_width, nut_cover_height], 2, center = false);
                for(side = [-1, 1])
                    translate([screw_x,  side * screw_y, 0])
                        cylinder(r = washer_diameter(M2p5_washer) / 2 + 2, h = lid_thickness);
            }
            else
                translate([length - front_thickness + lid_width / 2, 0, 0])
                    rounded_rectangle([lid_width, d_width, lid_thickness], 2, center = false);
        }

        if(nuts)
            translate([length - nut_cover_depth, -d_width / 2 - flange_clearance, lid_thickness - eta])
                cube([nut_cover_depth * 2, d_width + 2 * flange_clearance, 10]);

        for(side = [-1, 1])
            translate([screw_x,  side * screw_y, 0])
                rotate([0, 0, -side * 360 / 20])
                    poly_cylinder(r = No2_clearance_radius, h = 100, center = true);
    }
}

module d_shell_lid_stl() d_motor_bracket_lid_stl(motor = NEMA17, nuts = false);
//
// Attaches to the motor
//
module d_motor_bracket_stl(motor = NEMA17) {
    stl("d_motor_bracket");

    m_width = NEMA_width(motor) + 2 * thickness;
    offset = d_motor_bracket_offset(motor) + (m_width - d_width) / 2;
    mouth = pitch + 2 * M3_clearance_radius + layer_height / 2;

    difference() {
        union() {
            linear_extrude(height = thickness, convexity = 5)       // base
                polygon(points = [ [0,                        0],
                                   [overlap,                  0],
                                   [overlap,             offset],
                                   [length - eta,        offset],
                                   [length - eta,        offset + d_width],
                                   [overlap,             offset + d_width],
                                   [overlap,             m_width],
                                   [0,                   m_width],
                                 ]);

            translate([overlap , 0, eta])                               // motor wall
                cube([thickness, d_width + offset, height]);

            for(y = [0, m_width - thickness])                           // buttresses
                translate([overlap + eta, y, thickness - eta])
                    rotate([90, 0, 180])
                        right_triangle(width = overlap, height = height - thickness, h = thickness, center = false);


            difference() {
                union() {
                    // connector wall
                    translate([length - front_thickness, offset, eta])
                        cube([front_thickness + flange_thickness + wall, d_width, height]);

                    // nut lugs
                    translate([length + flange_thickness + wall - lug_depth / 2, offset + d_width / 2, eta])
                        rounded_rectangle([lug_depth, d_width + 2 * lug_width, lug_height], r = 2, center = false);

                    // d side walls
                    for(y = [0, d_width - thickness])
                        translate([overlap, y + offset, eta])
                            cube([length - overlap, thickness, height]);
                }

                translate([length, offset + (d_width - flange_width) / 2, thickness + slot_height / 2 - flange_height / 2])
                    cube([flange_thickness, flange_width, 20]);                         // slot for flange

                translate([10, d_width / 2 - slot_width / 2 + offset, thickness + eta * 2])  //slot for connector body
                    cube([30, slot_width, 20]);


                for(side = [-1, 1]) {
                    translate([nut_x + nut_slot / 2, d_width / 2 - side * pitch / 2 + offset, thickness + slot_height / 2]) //connector screws
                        rotate([90, 0, 90]) {
                            rotate([0,0,30])
                                nut_trap(1, M3_nut_radius, nut_slot / 2, true);

                            translate([0, 5, 0])
                                cube([nut_flat_radius(M3_nut) * 2, 10, nut_slot], center = true);

                            teardrop_plus(r = M3_clearance_radius, h = 100, center = true);
                        }

                    translate([screw_x, d_width / 2 - side * screw_y + offset, height + lid_thickness])         // lid screws holes
                        rotate([0,0,180])
                            poly_cylinder(r = No2_pilot_radius, h = 12 * 2, center = true);
                }

            }


        }
        for(y = NEMA_holes(motor))                                                          // motor screws
            for(z = NEMA_holes(motor))
                translate([overlap - 1, m_width / 2 + y, NEMA_width(motor) / 2 + thickness + z])
                    rotate([90,0,90])
                        teardrop_plus(r = M3_clearance_radius, h = thickness + 2, center = false);
    }
}
//
// Attaches connector to ribbon cable and plastic strip
//
function d_motor_connector_offset(motor) = [
    NEMA_width(motor) / 2 + thickness - cable_guide_thickness + ribbon_clamp_slot_depth(),
    -NEMA_length(motor) + overlap - length - d_mate_distance(connector) - shell_length + ribbon_clamp_width(cable_screw),
    d_motor_bracket_offset(motor)
];

module d_shell_stl() {
    stl("d_shell");

    mouth = pitch + 2 * screw_clearance_radius(cable_screw) + layer_height / 2;
    rad = ribbon_clamp_width(cable_screw) / 2;
    clamp_pitch = ribbon_clamp_pitch(extruder_ways, cable_screw);

    front = shell_front + flange_thickness + wall;
    union() {
        difference() {
            union() {
               // screw lugs
               translate([shell_length + flange_thickness + wall - front / 2, d_width / 2, eta])
                    rounded_rectangle([front, d_width + 2 * lug_width,
                                       thickness + slot_height / 2 + washer_diameter(M3_washer) / 2 + 1], r = 2, center = false);

               translate([shell_length + flange_thickness + wall - front / 2, d_width / 2, eta])        // connector wall
                    rounded_rectangle([front, d_width, height], r = 2, center = false);

               linear_extrude(height = cable_guide_thickness, convexity = 5)
                    hull() {
                        for(side = [-1,1])
                            translate([rad, d_width / 2 + side * clamp_pitch / 2])
                                circle(r = rad, center = true);

                        translate([shell_length - shell_front, 0])
                            square([1, d_width]);
                    }
            }

            translate([shell_length,(d_width - flange_width) / 2, thickness + slot_height / 2 - flange_height / 2])
                cube([flange_thickness, flange_width, 20]);                                                 // slot for flange

            translate([rad * 2, d_width / 2 - slot_width / 2 , thickness - eta])                            //slot for connector body
                cube([30, slot_width, 20]);

            if(idc)
                translate([rad * 2, d_width / 2 - slot_width / 2 , thickness + slot_height / 2 - flange_height / 2])
                    cube([shell_length - rad * 2 + eta, slot_width, flange_height]);                        //slot for idc connector body

            for(side = [-1, 1]) {
                translate([nut_x + nut_slot / 2, d_width / 2 - side * pitch / 2, thickness + slot_height / 2]) //connector screws
                    rotate([90, 0, 90])
                        teardrop_plus(r = M3_clearance_radius, h = 100, center = true);

                translate([shell_screw_x, d_width / 2 - side * screw_y, height + lid_thickness])         // lid screws holes
                    rotate([0,0,180])
                        poly_cylinder(r = No2_pilot_radius, h = 12 * 2, center = true);
            }
            //
            // cable slot
            //
            translate([ribbon_clamp_width(cable_screw) / 2, d_width / 2, cable_guide_thickness - ribbon_clamp_slot_depth() + 5])
                cube([ribbon_clamp_width(cable_screw) + 1, ribbon_clamp_slot(extruder_ways), 10], center = true);
            //
            // clamp screw holes
            //
            translate([rad, d_width / 2, cable_guide_thickness / 2])
                rotate([0, 0, 90])
                    ribbon_clamp_holes(extruder_ways, cable_screw)
                        poly_cylinder(r = screw_clearance_radius(cable_screw), h = 100, center = true);
        }
    }
}

module d_shell_assembly(motor) {
    translate([slot_height / 2, 0, shell_length])
        rotate([0, 0, 90])
            explode([0, -15, 0])
                d_socket(connector, idc = idc);

    translate([-thickness, d_width / 2, 0])
        rotate([0, -90, 180])  {
            color(d_shell_color) render() d_shell_stl();
            translate([0, d_width / 2, height + lid_thickness])
                explode([0, 0, 20])
                    translate([shell_length - length, 0, 0])
                        color(d_shell_lid_color) render() rotate([180, 0, 0]) d_shell_lid_stl(motor);

            for(side = [-1, 1]) {
                translate([shell_length - shell_front, d_width / 2 - side * pitch / 2, thickness + slot_height / 2]) //connector screws
                    rotate([90, 0, -90]) {
                        screw_and_washer(M3_cap_screw, 20);
                        translate([0, 0, -(shell_front + flange_thickness + wall) - 0.8])
                            explode([0, 0, -10])
                                O_ring(2.5, 1.6, 3);
                    }

                translate([shell_screw_x,  d_width / 2 - side * screw_y, height + lid_thickness])
                     explode([0, 0, 20])
                         screw_and_washer(No2_screw, 13);
            }
            translate([ribbon_clamp_width(M3_cap_screw) / 2, d_width / 2, cable_guide_thickness])
                rotate([0, 0, 90])
                    ribbon_clamp_assembly(extruder_ways, cable_screw, 16, cable_guide_thickness, vertical = false, washer = true, nutty = true, slotted = false);
        }
}

module d_motor_bracket_assembly(motor) {
    rotate([0, 90, 0])
        translate([NEMA_length(NEMA17) - overlap, -NEMA_width(NEMA17) / 2 - thickness, -NEMA_width(NEMA17) / 2 - thickness]) {
            color(d_motor_bracket_color) render() d_motor_bracket_stl(NEMA17);
            translate([0, NEMA_width(NEMA17) / 2 + d_motor_bracket_offset(NEMA17) + thickness, height + lid_thickness])
                translate([length, 0, 0])
                    explode([0, 0, 40])
                        translate([-length, 0, 0])
                            color(d_motor_bracket_lid_color) render() rotate([180, 0, 0]) d_motor_bracket_lid_stl(motor);
        }

    translate([-NEMA_width(motor) / 2 + slot_height / 2,  d_motor_bracket_offset(motor), -NEMA_length(motor) + overlap]) {
        translate([0, 0, -length])
            rotate([180, 0, -90])
                explode([0, -15, 0]) group() {
                    if(pcb)
                        assembly("extruder_connection_pcb_assembly");
                    d_plug(connector, pcb = pcb);
                    if(pcb) {
                        translate([0, -pcb_length / 2 + pcb_offset, -d_pcb_offset(connector) - pcb_thickness / 2]) {
                            vitamin("PCB0000: Extruder connection PCB");
                            color("green") cube([pcb_width, pcb_length, pcb_thickness], center = true);

                            translate([2.5 * 1.27, -pcb_length / 2 + 8.89 - 2.54, pcb_thickness / 2])
                                terminal_254(4);

                            translate([2.5 * 1.27, -pcb_length / 2 + 8.89 + 2.75 * 2.54, pcb_thickness / 2])
                                molex_254(3);

                            translate([-3.5 * 1.27, -pcb_length / 2 + 8.89 - 1.5 * 2.54, pcb_thickness / 2])
                                rotate([0, 0, 180])
                                    molex_254(2);

                            translate([-3.5 * 1.27, -pcb_length / 2 + 8.89 + 2 * 2.54, pcb_thickness / 2])
                                rotate([0, 0, 180])
                                    terminal_254(4);
                         }
                        end("extruder_connection_pcb_assembly");
                    }
                }

        for(side = [-1, 1]) {
            translate([0, pitch / 2 * side, -nut_x])
                rotate([180, 0, 0])
                    explode([10,0,0])
                        nut(M3_nut);

            translate([height - slot_height / 2 - thickness + lid_thickness, side * screw_y, - screw_x])
                rotate([0, 90, 0])
                    explode([0, 0, 40])
                        screw_and_washer(No2_screw, 13);
        }
    }

    for(y = NEMA_holes(motor))                                                          // motor screws
        for(x = NEMA_holes(motor))
            if(x < 0)
                translate([x, y, -NEMA_length(motor) - thickness])
                    rotate([180, 0, 0])
                        screw_and_washer(M3_cap_screw, 45);
}

module d_motor_brackets_stl() {
    d_motor_bracket_stl(NEMA17);
    translate([12, 40, 0])
        d_motor_bracket_lid_stl(NEMA17);

    translate([23, 40, 0])
        d_shell_lid_stl(NEMA17);

    translate([-33, 8, 0])
        d_shell_stl(NEMA17);

    translate([26, 5, 0]) {
        ribbon_clamp_stl(extruder_ways, cable_screw, nutty = true, slotted = false);
        *color("grey")
            ribbon_clamp_support(extruder_ways, cable_screw);
    }
}

if(01) {
    NEMA(NEMA17);
    d_motor_bracket_assembly(NEMA17);
    translate([-NEMA_width(NEMA17) / 2,
               d_motor_bracket_offset(NEMA17),
               -NEMA_length(NEMA17) -length - d_mate_distance(connector)  - shell_length + overlap + (exploded ? - 20 : 0)])
        d_shell_assembly(NEMA17);

}
else
    d_motor_brackets_stl();
