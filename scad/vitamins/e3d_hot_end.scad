//
// Mendel90
//

include <../conf/config.scad>

groove_dia = 12;
groove_h = 6;

rad_dia = 22; // Diam of the part with ailettes
rad_nb_ailettes = 11;
rad_len = 26;

nozzle_h = 5;

module e3d_nozzle(type) {
    color("gold")
    difference() {
        union() {
            cylinder(r1=1.3/2, r2=3/2, h=2);
            translate([0, 0, 2]) cylinder(r = 8/2, h=nozzle_h-2, $fn=6);
        }
        translate([0, 0, -eta]) cylinder(d=0.5, h=nozzle_h+ 2*eta);
    }
}

resistor_len = 22;
resistor_dia = 6;

heater_width  = 16;
heater_length = 20;
heater_height = 11.5;

heater_x = 4.5;
heater_y = heater_width / 2;

fan_x_offset = rad_dia/2 + 4;

module e3d_resistor(type) {
    translate([11-heater_x, -3-heater_y, heater_height/2+nozzle_h]) {
        color("grey") rotate([-90, 0, 0]) cylinder(d=resistor_dia, h=resistor_len);
        color("red") translate([-3.5/2, resistor_len  + 3.5/2  +1, 0]) {
            cylinder(d=3.5, h=36);
            translate([3.5, 0, 0]) cylinder(d=3.5, h=36);
        }


    }
}

module heater_block(type) {
    translate([0, 0, -hot_end_length(type)])  {
        translate([0, 0, nozzle_h]) difference() {
            color("lightgrey") union() {
                // Heat break
                cylinder(d=4, h=heater_height + 10);
                translate([-heater_x, -heater_y, 0])  {
                    cube([heater_length, heater_width, heater_height]);
                }
            }
            cylinder(d=3, h=heater_height + 10 + eta); // Filament hole
        }

        e3d_resistor(type);
        e3d_nozzle(type);
    }
}



module e3d_rad(type) {
    h_ailettes = rad_len / (2*rad_nb_ailettes -1);

    difference() {
        cylinder(r=rad_dia/2, h=rad_len);

        translate([0, 0, -eta]) cylinder(r=hot_end_insulator_diameter(type)/2-eta, h=rad_len+2*eta);

        for ( i = [0:rad_nb_ailettes-2] ) {
            translate([0, 0, (2*i +1) * h_ailettes])
            cylinder(r=rad_dia, h=h_ailettes);
        }
    }
}

module e3d_fan_duct(type) {
    color("DeepSkyBlue")
    difference() {
        hull() {
            translate([-8, -23/2, 0]) cube([eta, 23, 26]);
            translate([fan_x_offset, -30/2, 0]) cube([eta, 30, 30]);
        }
        cylinder(h=70, d=rad_dia+0.1, center=true); // For rad
        translate([0, 0, 15])  rotate([0, 90, 0]) cylinder(d=rad_dia, h=50);
    }
}

module e3d_fan(type) {
    e3d_fan_duct(type);
    translate([fan_x_offset+5, 0, 15]) rotate([0, 90, 0]) color("darkgrey") fan(fan30x10);
}

module e3d_hot_end(type) {
    insulator_length = hot_end_insulator_length(type);
    inset = hot_end_inset(type);
    bundle = 3.2;
    tape_thickness = 0.8;

    vitamin(hot_end_part(type));
    vitamin("ST25110: 110mm x 25mm self amalgamating silicone tape");

    translate([0, 0, inset - insulator_length]) {
        color(hot_end_insulator_colour(type)) render(convexity = 10) {
            difference() {
                cylinder(r = hot_end_insulator_diameter(type) / 2, h = insulator_length);
                cylinder(r = 3.2 / 2, h = insulator_length * 2 + 1, center = true);  // Filament hole
                translate([0, 0, insulator_length - hot_end_inset(type) - groove_h / 2])
                    tube(ir = groove_dia / 2, or = hot_end_insulator_diameter(type) / 2 + eta, h = groove_h);
            }
            e3d_rad(e3d_china);
        }
    }


    // Wire and ziptie
    rotate([0, 0, 10]) {
        scale([1, (bundle + hot_end_insulator_diameter(type)) / hot_end_insulator_diameter(type)])
                translate([0, -bundle / 2, -7])
            rotate([0, 0, -110])
                    ziptie(small_ziptie, hot_end_insulator_diameter(type) / 2);

        translate([0, -hot_end_insulator_diameter(type) / 2 - bundle / 2, 20])
            scale([0.7, bundle / 6.4])
                difference() {
                    tubing(HSHRNK64, 60);
                    translate([0, 0, 20])
                    cube([10, 10, 60], center = true);
                }

    }

    rotate([0, 0, 90]) heater_block(type);

    translate([0, 0, inset - insulator_length]) e3d_fan();

}

e3d_hot_end(e3d_china);
