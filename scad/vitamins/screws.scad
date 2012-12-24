//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Screws
//
hs_cap = 0;
hs_pan = 1;
hs_cs  = 2;     // counter sunk
hs_hex = 3;
hs_grub= 4;     // pulley set screw

M2p5_pan_screw = ["PS025", "M2.5 pan screw",     hs_pan, 2.5, 4.7, 1.7, M2p5_washer, false,  M2p5_tap_radius,  M2p5_clearance_radius];

M2p5_cap_screw = ["CS025", "M2.5 cap screw",     hs_cap, 2.5, 4.7, 2.0, M2p5_washer, false,  M2p5_tap_radius,  M2p5_clearance_radius];

M3_cap_screw   = ["CS030", "M3 cap screw",       hs_cap,   3, 5.5, 2.5,   M3_washer, M3_nut, M3_tap_radius,    M3_clearance_radius];
M3_pan_screw   = ["PS030", "M3 pan screw",       hs_pan,   3, 5.4, 2.0,   M3_washer, M3_nut, M3_tap_radius,    M3_clearance_radius];
M3_hex_screw   = ["HX030", "M3 hex screw",       hs_hex,   3, 6.4, 2.125, M3_washer, M3_nut, M3_tap_radius,    M3_clearance_radius];
M3_grub_screw  = ["GB030", "M3 grub screw",      hs_grub,  3, 1.6, 2.5,   M3_washer, M3_nut, M3_tap_radius,    M3_clearance_radius];

M4_grub_screw  = ["GB040", "M4 grub screw",      hs_grub,  4, 2.4, 2.5,   M4_washer, M4_nut, M4_tap_radius,    M4_clearance_radius];
M4_cap_screw   = ["CS040", "M4 cap screw",       hs_cap,   4, 7.0, 3.0,   M4_washer, M4_nut, M4_tap_radius,    M4_clearance_radius];
M4_hex_screw   = ["HX040", "M4 hex screw",       hs_hex,   4, 8.1, 2.925, M4_washer, M4_nut, M4_tap_radius,    M4_clearance_radius];
M4_pan_screw   = ["PS040", "M4 pan screw",       hs_pan,   4, 7.8, 3.3,   M4_washer, M4_nut, M4_tap_radius,    M4_clearance_radius];
M5_cap_screw   = ["CS050", "M5 cap screw",       hs_cap,   5, 8.5, 4,     M5_washer, M5_nut, M5_tap_radius,    M5_clearance_radius];
M8_cap_screw   = ["CS080", "M8 cap screw",       hs_cap,   8, 13,  6.0,   M8_washer, M8_nut, M8_tap_radius,    M8_clearance_radius];
M8_hex_screw   = ["HX080", "M8 hex screw",       hs_hex,   8, 15,  5.65,  M8_washer, M8_nut, M8_tap_radius,    M8_clearance_radius];

No2_screw      = ["PSW02", "No2 pan wood screw", hs_pan, 2.2, 4.2, 1.7, M2p5_washer, false,  No2_pilot_radius, No2_clearance_radius];
No4_screw      = ["PSW04", "No4 pan wood screw", hs_pan, 3.0, 5.5, 2.0, M3p5_washer, false,  No4_pilot_radius, No4_clearance_radius];
No6_screw      = ["PSW06", "No6 pan wood screw", hs_pan, 3.5, 6.7, 2.2,   M4_washer, false,  No6_pilot_radius, No6_clearance_radius];
No6_cs_screw   = ["PSW06", "No6 cs  wood screw", hs_cs,  3.5, 7.0, 0,     M4_washer, false,  No6_pilot_radius, No6_clearance_radius];
No632_pan_screw =["PS063", "6-32 pan screw",     hs_pan, 3.5, 6.9, 2.5,   M4_washer, false,  No6_pilot_radius, No6_clearance_radius];

function screw_washer(type) = type[6];
function screw_nut(type)    = type[7];
function screw_pilot_hole(type)     = type[8];
function screw_clearance_radius(type) = type[9];
function screw_radius(type) = type[3] / 2;
function screw_head_radius(type) = type[4] / 2;
function screw_nut_radius(type) = screw_nut(type) ? nut_radius(screw_nut(type)) : 0;
function screw_boss_diameter(type) = max(washer_diameter(screw_washer(type)) + 1, 2 * (screw_nut_radius(type) + 3 * filament_width));

function screw_longer_than(x) = x <= 10 ? 10 :
                                x <= 12 ? 12 :
                                x <= 16 ? 16 :
                                ceil(x / 5) * 5;

function screw_shorter_than(x) = x > 20 ? floor(x / 5) * 5 :
                                 x > 16 ? 16 :
                                 x > 12 ? 12 :
                                 10;

function screw_head_height(type) = type[2] == hs_cap ? type[4] :
                                   type[2] == hs_cs  ? type[4] / 2 : type[5];


module screw(type, length, hob_point = 0) {
    if(hob_point)
        vitamin(str(type[0], length,": ",type[1], " x ", length, "mm, hobbed at ", hob_point));
    else
        vitamin(str(type[0], length,": ",type[1], " x ", length, "mm"));

    head_type = type[2];
    rad = screw_radius(type) - eta;
    head_rad = screw_head_radius(type);
    if(exploded)
        cylinder(r = 0.2, h = 16);
    translate([0, 0, exploded ? length + 10 : 0]) {
        if(head_type == hs_cap) {
            assign(head_height = rad * 2,
                   socket_rad = type[5] / cos(30) / 2,
                   socket_depth = 2 * rad / 3)
            color(screw_cap_color) render() difference() {
                union() {
                    cylinder(r = head_rad, h = head_height);
                    translate([0,0, - length + eta])
                        cylinder(r = rad, h = length);
                }
                translate([0,0, head_height])
                    cylinder(r = socket_rad, h = socket_depth  * 2, $fn = 6, center = true);
            }
        }
        if(head_type == hs_grub) {
            assign(socket_rad = type[4] / 2,
                   socket_depth = type[5])
            color(screw_grub_color) render() difference() {
                translate([0, 0, -length])
                    cylinder(r = rad, h = length);

                cylinder(r = socket_rad, h = socket_depth  * 2, $fn = 6, center = true);
            }
        }
        if(head_type == hs_hex) {
            assign(head_height =type[5])
            color(screw_hex_color) render() union() {
                cylinder(r = head_rad, h = head_height, $fn = 6);
                translate([0,0, - length + eta])
                    cylinder(r = rad, h = length);
            }
        }
        if(head_type == hs_pan) {
            assign(head_height = type[5],
                   socket_rad = 0.6 * head_rad,
                   socket_depth = 0.5 * type[5])
            color(screw_pan_color) render() difference() {
                union() {
                    rounded_cylinder(r = head_rad, h = head_height, r2 = head_height / 2);
                    translate([0,0, - length + eta])
                        cylinder(r = rad, h = length);
                }
                translate([0,0,head_height]) {
                    cube([2 * socket_rad, 1, 2 * socket_depth], center = true);
                    cube([1, 2 * socket_rad, 2 * socket_depth], center = true);
                }
            }
        }
        if(head_type == hs_cs) {
            assign(head_height = head_rad,
                   socket_rad = 0.6 * head_rad,
                   socket_depth = 0.3 * head_rad,
                   socket_width = 1)
            color(screw_cs_color) render() difference() {
                union() {
                    translate([0,0, -head_height])
                        cylinder(h = head_height, r1 = 0, r2 = head_rad);
                    translate([0,0, - length - eta])
                        cylinder(r = rad, h = length);
                }
                translate([0,0,0]) {
                    cube([2 * socket_rad, socket_width, 2 * socket_depth], center = true);
                    cube([socket_width, 2 * socket_rad, 2 * socket_depth], center = true);
                }
            }
        }
    }
}


module screw_and_washer(type, length, spring = false) {
    washer = screw_washer(type);
    translate([0, 0, exploded ? 6 : 0])
        washer(washer);
    translate([0,0, washer_thickness(washer)]) {
        if(spring) {
            translate([0, 0, exploded ? 8 : 0])
                star_washer(washer);
            translate([0,0, washer_thickness(washer)])
                screw(type, length);
        }
        else
            screw(type, length);
    }
}
