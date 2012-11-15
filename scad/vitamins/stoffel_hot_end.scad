//
// Mendel90
//
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
include <../conf/config.scad>

heater_width = 15;
heater_length = 15;
heater_height = 8;

resistor_x = heater_length / 2 - 4.5;

thermistor_x = heater_length / 2 - 8.5;
thermistor_z = -heater_height / 2 + 6;

nozzle_x = -heater_length / 2 + 4.5;
barrel_tap_dia = 5;

barrel_dia = 6;
insulator_dia = 12;


module heater_block(resistor, thermistor) {
    vitamin(str("HEATBLK: aluminium heater block ", heater_length, "mm x ", heater_width, "mm x ", heater_height, "mm"));
    color([0.7, 0.7, 0.7]) render() difference() {
        cube([heater_length, heater_width, heater_height], center = true);

        translate([thermistor_x, 0, thermistor_z])                                      // hole for thermistor
            rotate([90, 0, 0])
                cylinder(r = resistor_hole(thermistor) / 2, h = heater_width + 1, center = true);

        translate([resistor_x, 0, 0])                                                   // hole for resistor
            rotate([90, 0, 0])
                cylinder(r = resistor_hole(resistor) / 2, h = heater_width + 1, center = true);

        translate([nozzle_x, 0, 0])
            cylinder(r = barrel_tap_dia / 2, h = heater_height+ 1, center = true);
    }
}



module stoffel_hot_end(type) {
    resistor = RWM04106R80J;
    thermistor = Honewell;
    insulator_length = hot_end_insulator_length(type);
    inset = hot_end_inset(type);
    barrel_length = hot_end_total_length(type) - insulator_length;
    cone_length = 2;
    cone_end = 1;

    vitamin(hot_end_part(type));

    translate([0, 0, inset - insulator_length]) {
        color(hot_end_insulator_colour(type)) render()
            difference() {
                cylinder(r = hot_end_insulator_diameter(type) / 2, h = insulator_length);
                cylinder(r = 3.2 / 2, h = insulator_length * 2 + 1, center = true);
                translate([0, 0, insulator_length - 4.6 - 1.75 / 2])
                    tube(ir = 13.66 / 2, or = 17 / 2, h = 1.75);
            }

        color("gold")  render() union() {
            translate([0, 0, -20])
                cylinder(r = 10.8 / 2, h = 20);

            translate([0, 0, -barrel_length + cone_length + eta]) {
                cylinder(r = 3, h = barrel_length - cone_length);
                translate([0, 0, -cone_length + eta])
                    cylinder(r1 = cone_end / 2, r = 3, h = cone_length);
            }
        }
    }
    rotate([0, 0, 90])
        translate([-nozzle_x, 0, -hot_end_length(type) + 10 -heater_height / 2]) {
            heater_block(resistor, thermistor);

            explode([0, -15, 0])
                translate([resistor_x, 0, 0])
                    rotate([90, 0, 0])
                        resistor(resistor);

            explode([0, -15, 0])
                translate([thermistor_x, 0, thermistor_z])
                    rotate([90, 0, 0])
                        thermistor(thermistor);

    }
}
