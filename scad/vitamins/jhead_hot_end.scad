//
// Mendel90
//
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
include <../conf/config.scad>

MK4_heater = [ 12.76, 15.88, 8.22, (15.88 / 2 - 4.5), (12.76 / 2 - 0.5 - 2.5 / 2),  (-15.88 / 2 + 5), 9.5];
MK5_heater = [ 12.76, 12.76, 8.22, (12.76 / 2 - 3.75), (12.76 / 2 - 0.5 - 2.5 / 2), (-12.76 / 2 + 4), 7.5];

function heater_width(type)  = type[0];
function heater_length(type) = type[1];
function heater_height(type) = type[2];
function resistor_x(type)    = type[3];
function thermistor_y(type)  = type[4];
function nozzle_x(type)      = type[5];
function nozzle_cone(type)   = type[6];

barrel_tap_dia = 5;

barrel_dia = 6;
insulator_dia = 12;

function jhead_groove_dia() = 12;

module heater_block(type, resistor, thermistor) {
    color("gold") render(convexity = 10) difference() {
        cube([heater_length(type), heater_width(type), heater_height(type)], center = true);

        translate([-heater_length(type) / 2, thermistor_y(type), 0])                     // hole for thermistor
            rotate([0, 90, 0])
                cylinder(r = resistor_hole(thermistor) / 2, h = 2 * resistor_length(thermistor), center = true);

        translate([resistor_x(type), 0, 0])                                                   // hole for resistor
            rotate([90, 0, 0])
                cylinder(r = resistor_hole(resistor) / 2, h = heater_width(type) + 1, center = true);

        translate([nozzle_x(type), 0, 0])
            cylinder(r = barrel_tap_dia / 2, h = heater_height(type) + 1, center = true);
    }
}



module jhead_hot_end(type, exploded = exploded) {
    resistor = RIE1212UB5C5R6;
    thermistor = Epcos;
    heater = type == JHeadMk5 ? MK5_heater : MK4_heater;

    insulator_length = hot_end_insulator_length(type);
    inset = hot_end_inset(type);
    barrel_length = hot_end_total_length(type) - insulator_length;
    cone_length = 3;
    cone_end = 1;
    cone_start = nozzle_cone(heater);
    bundle = 3.2;
    tape_width = 25;
    tape_overlap = 10;
    tape_thickness = 0.8;

    vitamin(hot_end_part(type));
    vitamin("ST25110: 110mm x 25mm self amalgamating silicone tape");

    color("red")
            if(exploded)
                translate([0, max(hot_end_insulator_diameter(type) / 2, heater_length(heater) / 2 - nozzle_x(heater)),
                            -tape_width + tape_overlap + inset - insulator_length])
                    cube([110, tape_thickness, tape_width]);
            else
                hull() {
                    translate([0, 0, + inset - insulator_length])
                        cylinder(r = hot_end_insulator_diameter(type) / 2 + 2 * tape_thickness, h = tape_overlap);

                    translate([0, -nozzle_x(heater), -hot_end_length(type) + cone_length  + 1 + heater_height(heater) / 2 + eta])
                        cube([heater_width(heater) + 4 * tape_thickness,
                              heater_length(heater) + 4 * tape_thickness, heater_height(heater)], center = true);
                }

    translate([0, 0, inset - insulator_length]) {
        color(hot_end_insulator_colour(type)) render(convexity = 10)
            difference() {
                cylinder(r = hot_end_insulator_diameter(type) / 2, h = insulator_length);
                cylinder(r = 3.2 / 2, h = insulator_length * 2 + 1, center = true);
                translate([0, 0, insulator_length - jhead_groove_offset() - jhead_groove() / 2])
                    tube(ir = jhead_groove_dia() / 2, or = 17 / 2, h = jhead_groove());
            }

        color("gold")  render(convexity = 10) union() {
            translate([0, 0, -barrel_length + cone_length + eta]) {
                cylinder(r = cone_start / 2, h = barrel_length - cone_length);
                translate([0, 0, -cone_length + eta])
                    cylinder(r1 = cone_end / 2, r = cone_start / 2, h = cone_length);
            }
        }
    }

    rotate([0, 0, 10]) {
        scale([1, (bundle + hot_end_insulator_diameter(type)) / hot_end_insulator_diameter(type)])
                translate([0, -bundle / 2, -7])
            rotate([0, 0, -110])
                    ziptie(small_ziptie, hot_end_insulator_diameter(type) / 2);

        translate([0, -hot_end_insulator_diameter(type) / 2 - bundle / 2, 20])
            scale([0.7, bundle / 6.4])
                difference() {
                    tubing(HSHRNK64, 60);
                    if(!exploded)
                        translate([0, 0, 20])
                            cube([10, 10, 60], center = true);
                }

    }
    wire("Red PTFE", 16, 170);
    wire("Red PTFE", 16, 170);

    rotate([0, 0, 90])
        translate([-nozzle_x(heater), 0, -hot_end_length(type) + cone_length  + 1 + heater_height(heater) / 2]) {
            heater_block(heater, resistor, thermistor);

            intersection() {
                group() {
                    translate([resistor_x(heater), -exploded * 15, 0])
                        rotate([90, 0, 0])
                             sleeved_resistor(resistor, PTFE20, bare = - 10, on_bom = false, exploded = exploded);

                    translate([-heater_length(heater) / 2 + resistor_length(thermistor) / 2 - exploded * 10, thermistor_y(heater), 0])
                        rotate([90, 0, -90])
                             sleeved_resistor(thermistor, PTFE07, on_bom = false, heatshrink = HSHRNK16, exploded = exploded);
                }
                if(!exploded)
                    cube(1, true);             // hide the wires when not exploded
            }
    }
}

jhead_hot_end(JHeadMk5);
