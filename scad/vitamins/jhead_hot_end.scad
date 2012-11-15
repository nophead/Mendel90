//
// Mendel90
//
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
include <../conf/config.scad>

heater_width = 12.76;
heater_length = 15.88;
heater_height = 8.22;

resistor_x = heater_length / 2 - 4.5;

thermistor_y = heater_width / 2 - 0.5 - 2.5 / 2;
thermistor_z = -heater_height / 2 + 6;

nozzle_x = -heater_length / 2 + 5;
barrel_tap_dia = 5;

barrel_dia = 6;
insulator_dia = 12;

function jhead_groove_dia() = 12;


module heater_block(resistor, thermistor) {
    color("gold") render() difference() {
        cube([heater_length, heater_width, heater_height], center = true);

        translate([-heater_length / 2, thermistor_y, thermistor_z])                     // hole for thermistor
            rotate([0, 90, 0])
                cylinder(r = resistor_hole(thermistor) / 2, h = 2 * resistor_length(thermistor), center = true);

        translate([resistor_x, 0, 0])                                                   // hole for resistor
            rotate([90, 0, 0])
                cylinder(r = resistor_hole(resistor) / 2, h = heater_width + 1, center = true);

        translate([nozzle_x, 0, 0])
            cylinder(r = barrel_tap_dia / 2, h = heater_height+ 1, center = true);
    }
}



module jhead_hot_end(type) {
    resistor = RIE1212UB5C5R6;
    thermistor = Epcos;
    insulator_length = hot_end_insulator_length(type);
    inset = hot_end_inset(type);
    barrel_length = hot_end_total_length(type) - insulator_length;
    cone_length = 3;
    cone_end = 1;

    vitamin(hot_end_part(type));

    translate([0, 0, inset - insulator_length]) {
        color(hot_end_insulator_colour(type)) render()
            difference() {
                cylinder(r = hot_end_insulator_diameter(type) / 2, h = insulator_length);
                cylinder(r = 3.2 / 2, h = insulator_length * 2 + 1, center = true);
                translate([0, 0, insulator_length - jhead_groove_offset() - jhead_groove() / 2])
                    tube(ir = jhead_groove_dia() / 2, or = 17 / 2, h = jhead_groove());
            }

        color("gold")  render() union() {
            translate([0, 0, -barrel_length + cone_length + eta]) {
                cylinder(r = 9.5/2, h = barrel_length - cone_length);
                translate([0, 0, -cone_length + eta])
                    cylinder(r1 = cone_end / 2, r = 9.5/2, h = cone_length);
            }
        }
    }

    translate([0, 0, -5])
        ziptie(small_ziptie, hot_end_insulator_diameter(type) / 2 + 1);

    rotate([0, 0, 90])
        translate([-nozzle_x, 0, -hot_end_length(type) + cone_length  + 1 + heater_height / 2]) {
            heater_block(resistor, thermistor);

            translate([resistor_x, 0, 0])
                rotate([90, 0, 0])
                    explode([0, 0, 15])
                        sleeved_resistor(resistor, PTFE20, bare = - 10, on_bom = false);

            translate([-heater_length / 2 + resistor_length(thermistor) / 2, thermistor_y, thermistor_z])
                rotate([90, 0, -90])
                    explode([0, 0, 10])
                        sleeved_resistor(thermistor, PTFE07, on_bom = false);

    }
}

jhead_hot_end(JHeadMk4);
