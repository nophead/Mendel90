//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
pulley_inner_radius = (14.4 / 2) - belt_thickness(T5x6); // measured from outer diameter

T5x10_metal_pulley  = ["T5",                          10, 15, 12.85 / 2,            11.6, 7.9, 7, 5, 19.3, 1.7, 3, 10.7, [0,     0, -2], 0];
T5x8_plastic_pulley = ["../imported_stls/pulley.stl",  8,  0, pulley_inner_radius,    0,   0, 0, 5,    0,   0, 6,    4, [-10, -10,  0], 6];

function pulley_type(type)             = type[0];
function pulley_teeth(type)            = type[1];
function pulley_od(type)               = type[2];
function pulley_ir(type)               = type[3];
function pulley_width(type)            = type[4];
function pulley_hub_dia(type)          = type[5];
function pulley_hub_length(type)       = type[6];
function pulley_bore(type)             = type[7];
function pulley_flange_dia(type)       = type[8];
function pulley_flange_thickness(type) = type[9];
function pulley_screw_length(type)     = type[10];
function pulley_screw_z(type)          = type[11];
function pulley_offset(type)           = type[12];
function pulley_nut_y(type)            = type[13];

module metal_pulley(type) {
    teeth = pulley_teeth(type);

    vitamin(str("PUL", pulley_type(type), teeth, ": ", pulley_type(type), " pulley ", teeth, " teeth"));

    ft = pulley_flange_thickness(type);
    tw = pulley_od(type) * PI / (teeth * 2);

    color("silver") render() {
        difference() {
            union() {
                cylinder(r = pulley_hub_dia(type) / 2, h = pulley_hub_length(type));
                for(z = [pulley_hub_length(type), pulley_hub_length(type) + ft + pulley_width(type)])
                    translate([0, 0, z])
                        cylinder(r = pulley_flange_dia(type) / 2, h = ft);
                translate([0, 0, pulley_hub_length(type) + ft])
                    cylinder(r = pulley_od(type) / 2, h =  pulley_width(type));
            }
            cylinder(r = pulley_bore(type) / 2, h = 100, center = true);
            for(i = [0 : teeth - 1])
                rotate([0, 0, i * 360 / teeth])
                    translate([-tw / 2, pulley_ir(type), pulley_hub_length(type) + ft])
                        cube([tw, 10, pulley_width(type)]);

            translate([0, 0, pulley_screw_z(type)])
                rotate([-90, 0, 0])
                    cylinder(r = 3/2, h = 100);
        }
    }
}
