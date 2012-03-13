//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Microswitch used for endstops
//

function microswitch_thickness() = 6.4;
function microswitch_length() = 19.8;

function microswitch_first_hole_x_offset() = -2;

function microswitch_button_x_offset() = -(5.1 - microswitch_first_hole_x_offset()) + microswitch_length() / 2;
function microswitch_hole_y_offset() = -8.4;

module microswitch_hole_positions()
{
    for(x = [microswitch_first_hole_x_offset(), 7.5])
         translate([x, microswitch_hole_y_offset(), microswitch_thickness() / 2])
              child();
}

module microswitch_holes(r = No2_pilot_radius, h = 7.5)
{
    translate([0, 0, -microswitch_thickness() - h / 2])
        microswitch_hole_positions()
            teardrop_plus(r = r, h = h + 1, center = true);
}

module microswitch_contact_space() {
    depth = 15;
    translate([-microswitch_first_hole_x_offset() + 0.75,  -depth / 2 - 3, 0])
        cube([microswitch_length() - 2, depth, microswitch_thickness() - 2], center = true);
}

module microswitch() {
    vitamin("SMMICRO: Microswitch");
    translate([-(5.1 + 9.5 - 7.5), -(8.4 + 2.5), -3.2 + (exploded ? 5 : 0)]) {   // put operating point of button at the origin
        color(microswitch_color) render() difference() {              // main body
            cube([19.8, 10.2, 6.4]);
            translate([10, 9.5, -1])
                cube([19.8, 10.2, 8]);                      // lower half of top
            translate([5.1, 2.5, -1])
                cylinder(r = 2.35 / 2, h = 8);              // mounting holes
            translate([5.1 + 9.5, 2.5, -1])
                cylinder(r = 2.35 / 2, h = 8);
        }
        color(microswitch_button_color) render()                           // orange button
            translate([5.1 + 9.5 - 7.5,8.4 + 2.5 - 0.5,1.6])
                linear_extrude(height = 3.2)
                    hull() {
                        circle(r = 1);
                        translate([0,-4])
                            circle(r = 1);
                    }
        color(microswitch_contact_color)  render()                            // yellow contacts
            for(x = [1.6, 1.6 + 8.8, 1.6 + 8.8 + 7.3])
                translate([x, 2.5 - 6.4, 1.6])
                    difference() {
                        cube([0.5, 7, 3.2]);
                        translate([0, 1.6, 1.6])
                            rotate([0,90,0])
                                cylinder(r = 0.8, h = 5, center = true);
                    }
    }
}
