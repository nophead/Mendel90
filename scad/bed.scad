//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Bed with glass and support pillars
//
include <conf/config.scad>

module bed_assembly() {

    assembly("bed_assembly");

    for(x = [-bed_holes / 2, bed_holes /2]) {
        translate([x, bed_holes / 2, 0])
            washer(M3_washer);

        for(y = [-bed_holes / 2, bed_holes /2])
            translate([x, y, washer_thickness(M3_washer)]) {
                hex_pillar(bed_pillars);

                translate([0,0, pillar_height(bed_pillars) + pcb_thickness]) {
                    //star_washer(M3_washer);
                    //translate([0,0, washer_thickness(M3_washer)])
                        screw(M3_cap_screw, 10);
                }
            }
    }

    translate([0, 0, washer_thickness(M3_washer)]) {
        vitamin(str("BED", bed_width, bed_depth,": PCB bed ", bed_width, " x ", bed_depth));
        translate([0,0, pillar_height(bed_pillars) + pcb_thickness / 2])
            color([0.7,0,0]) cube([bed_width, bed_depth, pcb_thickness], center = true);

        translate([0,0, pillar_height(bed_pillars) + pcb_thickness + sheet_thickness(glass) / 2 + eta * 3])
            sheet(glass, bed_width, bed_depth - 12);

        for(x = [-1, 1])
            for(y = [-1,1])
                translate([bed_width / 2 * x,
                           ((bed_depth - bulldog_length(small_bulldog)) / 2 - washer_diameter(M3_washer)) * y,
                           pillar_height(bed_pillars) + (pcb_thickness + sheet_thickness(glass))/ 2])
                    rotate([0, 0, 90 + x * 90])
                        bulldog(small_bulldog, pcb_thickness + sheet_thickness(glass));
    }

    end("bed_assembly");
}

bed_assembly();
