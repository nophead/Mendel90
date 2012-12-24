//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
include <conf/config.scad>

module pulley_stl() {
    stl("pulley");
    import(pulley_type(pulley_type));
}

module pulley_assembly() {
    type = pulley_type;

    translate(pulley_offset(type))
        if(pulley_od(type))
            metal_pulley(type);
        else
            color(pulley_color) render() pulley_stl();

    translate([0, pulley_bore(type) / 2 + pulley_screw_length(type), pulley_screw_z(type) + pulley_offset(type)[2]])
        rotate([-90, 0, 0])
            screw(pulley_screw(type), pulley_screw_length(type));

    if(pulley_nut_y(type))
        translate([0, pulley_nut_y(type), pulley_screw_z(type) + pulley_offset(type)[2]])
            rotate([90, 0, 0])
                nut(screw_nut(pulley_screw(type)));

}

if(1)
    pulley_assembly();
else
    pulley_stl();
