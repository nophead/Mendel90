//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// D-connectors
//

DCONN9  = [30.81, [18,    16.92], 24.99, [9.26, 8.38], 12.55, 10.72, 6.693, 1.12,  9];
DCONN15 = [39.14, [26.25, 25.25], 33.32, [9.26, 8.38], 12.55, 10.72, 6.693, 1.12, 15];
DCONN25 = [53.04, [40,    38.96], 47.04, [9.26, 8.38], 12.55, 10.72, 6.693, 1.12, 25];

function  d_flange_length(type)    = type[0];
function  d_hole_pitch(type)       = type[2];
function  d_flange_width(type)     = type[4];
function  d_flange_thickness(type) = type[7];
function  d_mate_distance(type)    = 8.5;
function  d_pcb_offset(type)     = type[5] - type[6] + 2;

function  d_slot_length(type) = type[1][0] + 3;  // slot to clear the back

module d_pillar(type) {
    vitamin("DP0000: D-type connect pillar");
    rad = 5.37 / 2;
    height = 4.5;
    screw = 2.5;
    screw_length = 8;
    color(d_pillar_color) render() translate([0,0, d_flange_thickness(type)]) difference() {
        union() {
            cylinder(r = rad, h = height, $fn = 6);
            translate([0,0, - screw_length + eta])
                cylinder(r = screw / 2, h = screw_length);
        }
        translate([0,0,1])
            cylinder(r = screw / 2, h = height);
    }

}


module d_plug(type, socket = false, pcb = false, idc = false) {
    hole_r = 3.05 / 2;
    dwall = 0.5;

    flange_length    = d_flange_length(type);
    d_length         = socket ? type[1][1] : type[1][0];
    hole_pitch       = d_hole_pitch(type);
    d_width          = socket ? type[3][1] : type[3][0];
    flange_width     = d_flange_width(type);
    d_height         = type[6];
    back_height      = type[5] - d_height;
    pins             = type[8];


    if(socket)
        if(idc)
            vitamin(str("DTYPESI", pins, ": ", pins," way D IDC socket"));
        else
            vitamin(str("DTYPES", pins, ": ", pins," way D socket"));
    else
        if(pcb)
            vitamin(str("DTYPEPP", pins, ": ", pins," way D PCB mount plug"));
        else
            vitamin(str("DTYPEP", pins, ": ", pins," way D plug"));


    module D(length, width, rad) {
        d = width / 2 - rad;
        offset = d * sin(10);

        hull() {
            translate([-length / 2 + rad - offset, width / 2 - rad])
                circle(r = rad, center = true);
            translate([-length / 2 + rad + offset, -width / 2 + rad])
                circle(r = rad, center = true);

            translate([length / 2 - rad + offset, width / 2 - rad])
                circle(r = rad, center = true);
            translate([length / 2 - rad - offset, -width / 2 + rad])
                circle(r = rad, center = true);
        }
    }

    //
    // Shell
    //
    color(d_plug_shell_color) render() difference() {
        union() {
            rounded_rectangle([flange_length, flange_width, d_flange_thickness(type)], 2, center = false);
            linear_extrude(height = d_height, convexity = 5)
                difference() {
                    D(d_length, d_width, 2.5);
                    D(d_length - 2 * dwall, d_width - 2 * dwall, 2.5 - dwall);
                }
            if(!idc)
                rotate([0,180,0])
                    linear_extrude(height = back_height, convexity = 5)
                        D(type[1][0] + 2 * dwall, type[3][0] + 2 * dwall, 2.5 + dwall);
        }

        for(end = [-1, 1])
            translate([end * hole_pitch / 2, 0, 0])
                cylinder(r = hole_r, h = 10, center = true);
    }
    //
    // Insulator
    //
    color(d_plug_insulator_color) render() {
        translate([0,0, d_flange_thickness(type) + eta])
            rotate([0, 180, 0])
                linear_extrude(height = back_height + 1 + d_flange_thickness(type), convexity = 5)
                    D(d_length - dwall, d_width - dwall, 2.5 - dwall/2);

        if(socket)
            linear_extrude(height = d_height - eta, convexity = 5)
                difference() {
                    D(d_length - dwall, d_width - dwall, 2.5 - dwall/2);
                    for(i = [1 : pins])
                        translate([(i - (pins + 1) / 2) * 2.77 / 2, (i % 2 - 0.5) * 2.84, 0])
                            circle(r = 0.7);
                }
        if(idc) {
            translate([0, 0, -2.4 / 2])
                cube([((pins + 1) / 2) * 2.77 + 6, flange_width, 2.4], center = true);

            translate([0, 0, -14.4 / 2])
                cube([pins * 1.27 + 7.29, flange_width, 14.4], center = true);
        }
    }
    //
    // Pins
    //
    render() for(i = [1 : pins])
        translate([(i - (pins + 1) / 2) * 2.77 / 2, (i % 2 - 0.5) * 2.84, 0]) {
            union() {
                if(!socket)
                    translate([0,0, - 0.5])
                        cylinder(r = 0.5, h = d_height);
                if(pcb)                                 // pcb pin
                    rotate([180, 0, 0]) {
                        cylinder(r = 0.75 / 2, h = back_height + 1 + 4.5);
                        cylinder(r = 0.75, h = back_height + 1 + 1);
                    }
                else                                    // solder bucket
                    if(!idc)
                        rotate([180, 0, 0])
                            difference() {
                                cylinder(r = 1,   h = 8);
                                cylinder(r = 0.45, h = 9);
                                translate([0, (i % 2 - 0.5) * -4, 8])
                                    rotate([45, 0, 0])
                                        cube(3, center = true);
                            }
             }
        }
}

module d_socket(connector, pcb = false, idc = false) d_plug(connector, true, pcb = pcb, idc = idc);

//d_plug(DCONN9);
//d_pillar();
