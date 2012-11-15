//
// Mendel90
//
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
include <../conf/config.scad>

heater_width = 12;
heater_length = 19;
heater_height = 8;

resistor_x = heater_length / 2 - 4.5;

thermistor_x = heater_length / 2 - 8.5;
thermistor_z = -heater_height / 2 + 6;

nozzle_x = heater_length / 2 - 13.5;
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

shield_thickness = 4;
shield_corner_rad = 3;
shield_height = 8;

module heat_shield() {
    length = heater_length + 2 * shield_thickness;
    width  = heater_width  + 2 * shield_thickness;

    %render() difference() {
        hull() {
            for(x =     [-length / 2 + shield_corner_rad, length / 2 - shield_corner_rad])
                for(y = [ -width / 2 + shield_corner_rad,  width / 2 - shield_corner_rad]) {
                    translate([x, y, -heater_height / 2])
                        cylinder(r = shield_corner_rad, h = 1);

                    translate([x, y, heater_height / 2 + shield_thickness - shield_corner_rad])
                        sphere(r = shield_corner_rad);
               }

            translate([nozzle_x, 0, heater_height / 2 + shield_height])
                cylinder(r = insulator_dia / 2 + 2, h = eta);
        }
        translate([0, 0, -0.5])
            cube([heater_length, heater_width, heater_height + 1], center = true);

        translate([nozzle_x, 0, heater_height / 2])
            cylinder(r = insulator_dia / 2, h = heater_height + shield_height + 1, center = true);
    }
}

mould_wall = 2;
mould_base = layer_height * 6;
shield_volume = 5000;                   // cubic mm
silicone = shield_volume * 1.2;         // some spare
hardner = silicone / 10;
total = (hardner + silicone) * 1.5;

module ladle(volume) {
    // v = pi r^2 * h, h = 2 r
    // v = pi r^3 * 2
    r = pow(volume / (2 * PI), 1/3);
    h = 2 * r;

    wall = 2 * filament_width;
    base = 3 * layer_height;
    handle = 3;

    union() {
        difference() {
            cylinder(r = r + wall, h = h + base);
            translate([0, 0, base + eta])
                cylinder(r = r, h = 2 * h);
        }
        translate([r + handle + eta, 0, 0])
            cylinder(r = handle, h = h + 20);
    }
}

module mould_core_stl() {
    length = heater_length + 2 * shield_thickness;
    width  = heater_width  + 2 * shield_thickness;
    clearance = 0.15;

    color("red") union() {
        translate([0, 0, mould_base / 4])
            cube([length + 2 * mould_wall, width + 2 * mould_wall, mould_base / 2], center = true);

        hull()
            for(x = [-length / 2 + shield_corner_rad + clearance, length / 2 - shield_corner_rad - clearance])
            for(y = [ -width / 2 + shield_corner_rad + clearance,  width / 2 - shield_corner_rad - clearance]) {
                translate([x, y, mould_base / 2 + eta])
                    cylinder(r = shield_corner_rad, h = mould_base, center = true);
           }

        translate([thermistor_x, 0, (mould_base + heater_height / 2 + thermistor_z) / 2])
            cube([filament_width * 2, width - clearance * 2 - eta, mould_base + heater_height / 2 + thermistor_z], center = true);

        translate([thermistor_x, 0, mould_base + heater_height / 2 + thermistor_z])
            rotate([90, 180, 0])
                teardrop(r = 1.5 / 2, h = width - clearance * 2 - eta, center = true, truncate = false);

        translate([resistor_x, 0, (mould_base + heater_height / 2) / 2])
            cube([filament_width * 2, width - clearance * 2 - eta, mould_base + heater_height / 2], center = true);

        translate([resistor_x, 0, mould_base + heater_height / 2])
            rotate([90, 180, 0])
                teardrop(r = 2.5 / 2, h = width - clearance * 2 - eta, center = true, truncate = false);

        translate([0, 0, (mould_base + heater_height) / 2 + eta])
            cube([heater_length, heater_width, heater_height + mould_base], center = true);

        translate([nozzle_x, 0,(mould_base + heater_height + shield_height) / 2 + eta])
            cylinder(r = insulator_dia / 2 - eta, h = mould_base + heater_height + shield_height, center = true);

    }
}

mould_height = mould_base / 2 + heater_height + shield_height + mould_wall;

module mould_stl() {
    length = heater_length + 2 * (shield_thickness + mould_wall);
    width  = heater_width  + 2 * (shield_thickness + mould_wall);

    color("green") difference() {
        translate([0, 0, mould_height / 2])
            cube([length, width, mould_height], center = true);

        translate([0, 0, mould_height + 2 * eta])
            rotate([180, 0, 0])
                translate([0, 0, heater_height / 2])
                    hull()
                        heat_shield();
        translate([nozzle_x, 0, 0])
            cylinder(r = insulator_dia / 2 + 2, h = 100, center = true);
    }
}



module m90_hot_end(type) {
    resistor = RWM04106R80J;
    thermistor = Honewell;
    insulator_length = hot_end_insulator_length(type);
    inset = hot_end_inset(type);
    barrel_length = hot_end_total_length(type) - insulator_length;
    cone_length = 2;
    cone_end = 1;

    assembly("mendel90_hot_end");

    translate([0, 0, inset - insulator_length]) {
        color(hot_end_insulator_colour(type)) render()
            difference() {
                cylinder(r = hot_end_insulator_diameter(type) / 2, h = insulator_length);
                cylinder(r = 3.2 / 2, h = insulator_length * 2 + 1, center = true);
            }

        color("gold")  render()
            translate([0, 0, -barrel_length + cone_length + eta]) {
                cylinder(r = 3, h = barrel_length - cone_length);
                translate([0, 0, -cone_length + eta])
                    cylinder(r1 = cone_end / 2, r = 3, h = cone_length);
            }
        rotate([0, 0, 90])
            translate([-nozzle_x, 0, -heater_height / 2 - washer_thickness(M6_washer) - nut_thickness(M6_half_nut) - 1]) {
                explode([0, 0, -40])
                    heater_block(resistor, thermistor);

                translate([resistor_x, 0, 0])
                    rotate([90, 0, 0])
                        explode([0, -40, 15])
                            resistor(resistor);

                translate([thermistor_x, 0, thermistor_z])
                    rotate([90, 0, 0])
                        explode([0, -40, 15])
                            resistor(thermistor);

                explode([0, 0, -30])
                    translate([nozzle_x, 0, heater_height / 2]) {
                        star_washer(M6_washer)
                            nut(M6_half_nut, brass = true);
                    }

                explode([0, 0, 30])
                    heat_shield();
        }
    }

    end("mendel90_hot_end");
}

//translate([0,0, heater_height / 2 + mould_base])
    m90_hot_end(m90_hot_end_12mm);

if(0) {
    mould_core_stl();

    translate([0, heater_width + 2 * mould_wall + 2 * shield_thickness + 1, 0])
        mould_stl();
}

*translate([0, 0, mould_height + mould_base / 2])
    rotate([180, 0, 0])
        mould_stl();

if(0) {
    ladle(silicone);
    translate([18,12,0]) rotate([0,0,180]) ladle(hardner);
    translate([0,25,0]) ladle(total);
}
