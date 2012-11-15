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
    //
    // Screws pillars and washers
    //
    for(x = [-bed_holes / 2, bed_holes /2]) {
        translate([x, bed_holes / 2, 0])
            washer(M3_washer);

        translate([x, -bed_holes / 2 - 5.5, 0])
            washer(M3_washer);

        for(y = [-bed_holes / 2, bed_holes /2])
            translate([x, y, washer_thickness(M3_washer)]) {
                hex_pillar(bed_pillars);

                translate([0,0, pillar_height(bed_pillars) + pcb_thickness])
                    screw(M3_cap_screw, 10);
            }
    }

    //
    // Mark the origin
    //
    translate([0, 0, pillar_height(bed_pillars) + pcb_thickness + sheet_thickness(bed_glass)])
        color("green")
            render()
                sphere();


    //
    // PCB, glass and clips
    //
    translate([0, 0, washer_thickness(M3_washer)]) {
        vitamin(str("BED", bed_width, bed_depth,": PCB bed ", bed_width, "mm x ", bed_depth, "mm"));
        translate([0,0, pillar_height(bed_pillars) + pcb_thickness / 2])
            color(bed_color) cube([bed_width, bed_depth, pcb_thickness], center = true);

        translate([0,0, pillar_height(bed_pillars) + pcb_thickness + sheet_thickness(bed_glass) / 2 + eta * 3])
            sheet(bed_glass, bed_width, bed_depth - 12);

        for(x = [-1, 1])
            for(y = [-1,1])
                translate([bed_width / 2 * x,
                           ((bed_depth - bulldog_length(small_bulldog)) / 2 - washer_diameter(M3_washer)) * y,
                           pillar_height(bed_pillars) + (pcb_thickness + sheet_thickness(bed_glass))/ 2])
                    rotate([0, 0, 90 + x * 90])
                        bulldog(small_bulldog, pcb_thickness + sheet_thickness(bed_glass));
    }


    translate([0, 40, pillar_height(bed_pillars) - 1])
        rotate([-90, 0, 0])
            sleeved_resistor(Epcos, PTFE07);
    end("bed_assembly");
}

bed_assembly();
