//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Reusable color definitions
//

// OpenSCAD v2011.12 and later support named colors
// http://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#color
//
// The available color names are taken from the World Wide Web consortium's SVG color list.
// http://www.w3.org/TR/css3-color/#svg-color

// Some additional named colors
grey20                          = [0.2, 0.2, 0.2];
grey50                          = [0.5, 0.5, 0.5];
grey70                          = [0.7, 0.7, 0.7];
grey80                          = [0.8, 0.8, 0.8];
grey90                          = [0.9, 0.9, 0.9];
brass                           = "gold";

// use_realistic_colors is defined in config.scad
function plastic_part_color(color) = use_realistic_colors ? printed_plastic_color : color;

// Object colors
rod_color                        = grey80;
studding_color                   = grey50;
tubing_color                     = [0.8, 0.8, 0.8, 0.75 ];
nut_color                        = grey70;
brass_nut_color                  = brass;
soft_washer_color                = grey20;
hard_washer_color                = grey80;
star_washer_color                = brass;
screw_cap_color                  = grey20;
screw_grub_color                 = grey20;
screw_hex_color                  = grey80;
screw_pan_color                  = brass;
screw_cs_color                   = brass;
spring_color                     = grey20;
pillar_color                     = grey90;
pillar_liner_color               = "yellow";
bearing_color                    = grey70;
psu_color                        = grey80;
fan_color                        = grey20;
microswitch_color                = "black";
microswitch_button_color         = "orange";
microswitch_contact_color        = "yellow";
sanguinololu_color               = "red";
stepper_body_color               = "black";
stepper_cap_color                = grey50;
small_ziptie_color               = "white";
bed_color                        = "firebrick";
d_pillar_color                   = grey90;
d_plug_shell_color               = grey80;
d_plug_insulator_color           = grey20;
extruder_insulator_color         = "goldenrod";
extruder_nozzle_color            = "yellow";
cable_strip_color                = use_realistic_colors ? cable_strip_real_color : "green";
belt_color                       = use_realistic_colors ? belt_real_color : "yellow";
bulldog_color                    = use_realistic_colors ? bulldog_real_color : "yellow";

// Assembly colors
clamp_color                      = plastic_part_color("lime");
clip_color                       = plastic_part_color("red");
d_shell_color                    = plastic_part_color("lime");
d_shell_lid_color                = plastic_part_color("red");
d_motor_bracket_color            = plastic_part_color("lime");
d_motor_bracket_lid_color        = plastic_part_color("red");
fixing_block_color               = plastic_part_color("lime");
ribbon_clamp_color               = plastic_part_color("red");
fan_guard_color                  = plastic_part_color("lime");
pcb_spacer_color                 = plastic_part_color("lime");
pulley_color                     = plastic_part_color("red");
ribbon_clamp_color               = plastic_part_color("red");
wades_block_color                = plastic_part_color("yellow");
wades_big_gear_color             = plastic_part_color("lime");
wades_small_gear_color           = plastic_part_color("red");
wades_idler_block_color          = plastic_part_color("lime");
wades_gear_spacer_color          = plastic_part_color("red");
wades_clamp_color                = plastic_part_color("red");
x_carriage_color                 = plastic_part_color("red");
x_belt_clamp_color               = plastic_part_color("lime");
x_end_bracket_color              = plastic_part_color("lime");
y_bearing_mount_color            = plastic_part_color("red");
y_belt_anchor_color              = plastic_part_color("lime");
y_belt_clip_color                = plastic_part_color("red");
y_idler_bracket_color            = plastic_part_color("lime");
y_motor_bracket_color            = plastic_part_color("lime");
z_coupling_color                 = plastic_part_color("red");
z_limit_switch_bracket_color     = plastic_part_color("lime");
z_motor_bracket_color            = plastic_part_color("lime");
