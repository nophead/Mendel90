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
include <positions.scad>

module bed_assembly(y = 0) {

    //
    // Screws pillars and washers
    //
    for(x = [-bed_holes[0] / 2, bed_holes[0] / 2]) {
        translate([x, bed_holes[1] / 2, 0])
            washer(M3_washer);

        translate([x, -bed_holes[1] / 2 - washer_diameter(M3_washer) / 2 - 3 / 2, 0])
            washer(M3_washer);

        for(y = [-bed_holes[1] / 2, bed_holes[1] /2])
            translate([x, y, washer_thickness(M3_washer)]) {
                hex_pillar(bed_pillars);

                translate([0,0, pillar_height(bed_pillars) + pcb_thickness])
                    screw(M3_cap_screw, 10);
            }
    }

    //
    // Mark the origin
    //
    *translate([0, 0, pillar_height(bed_pillars) + pcb_thickness + sheet_thickness(bed_glass)])
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
            sleeved_resistor(EpcosBlue, PTFE07, heatshrink = HSHRNK16);

    for(i = [-1, 1]) {
        translate([i * 10, bed_depth / 2 - y + 17.5, -(Y_carriage_height + sheet_thickness(Y_carriage) / 2) + 3.4])
            rotate([90, 0, 0])
                tubing(HSHRNK64, 30);

        translate([i * 3, bed_depth / 2 - y + 10, -(Y_carriage_height + sheet_thickness(Y_carriage) / 2) + 1.4])
            rotate([90, 0, 0])
                tubing(HSHRNK24);
    }
    wire("Red", 32, 600 + 20);
    wire("Black", 32, 615 + 20);
    ribbon_cable(bed_ways,
        10 +            // strip
        70 +            // loop under bed
        5  +            // loop to other side of carriage
        cable_strip_length(y_cable_strip_depth, Y_travel)
        + 25            // tail for connection to wire
    );

}

bed_assembly();
