//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Reusable color definitions
//

use_actual_colors = false;

// Named colors
white                           = [1, 1, 1];
black                           = [0, 0, 0];
red                             = [1, 0, 0];
dark_red                        = [0.7, 0, 0];
green                           = [0, 1, 0];
yellow                          = [1, 1, 0];
blue                            = [0, 0, 1];
fuchsia                         = [1, 0, 1];
orange                          = [1, 0.7, 0];
grey20                          = [0.2, 0.2, 0.2];
grey50                          = [0.5, 0.5, 0.5];
grey70                          = [0.7, 0.7, 0.7];
grey80                          = [0.8, 0.8, 0.8];
grey90                          = [0.9, 0.9, 0.9];

printed_plastic_color           = black;

function plastic_color(color) = use_actual_colors ? printed_plastic_color : color;

// Material colors
MDF_color                       = [0.4, 0.4, 0.2, 1    ];
acrylic_clear                   = [1,   1,   1,   0.5  ];
acrylic_blue_2424               = [0,   0,   1,   0.75  ];
acrylic_color                   = acrylic_clear;
glass_clear                     = [1,   1,   1,   0.25 ];
glass_color                     = glass_clear;
dibond_color                    = grey70;

// Object colors
rod_color                        = grey80;
studding_color                   = grey50;
tubing_color                     = [0.8, 0.8, 0.8, 0.75 ];
nut_color                        = grey70;
soft_washer_color                = grey20;
hard_washer_color                = grey80;
star_washer_color                = [0.8, 0.8, 0.4];
screw_cap_color                  = grey20;
screw_grub_color                 = grey20;
screw_hex_color                  = grey80;
screw_pan_color                  = [0.8, 0.8, 0.4];
screw_cs_color                   = [0.8, 0.8, 0.4];
spring_color                     = grey20;
pillar_color                     = grey90;
pillar_liner_color               = yellow;
bearing_color                    = grey70;
psu_color                        = grey80;
fan_color                        = grey20;
microswitch_color                = black;
microswitch_button_color         = orange;
microswitch_contact_color        = yellow;
sanguinololu_color               = red;
stepper_body_color               = black;
stepper_cap_color                = grey50;
small_ziptie_color               = white;
bed_color                        = dark_red;
d_pillar_color                   = grey90;
d_plug_shell_color               = grey80;
d_plug_insulator_color           = grey20;
filament_viz_color               = [0.6, 0.5, 0.2];
extruder_nozzle_color            = yellow;
cable_strip_color                = use_actual_colors ? grey70 : fuchsia;
belt_color                       = use_actual_colors ? grey20 : yellow;
bulldog_color                    = use_actual_colors ? black : yellow;

// Assembly colors
clamp_color                      = plastic_color(green);
clip_color                       = plastic_color(red);
d_shell_color                    = plastic_color(green);
d_shell_lid_color                = plastic_color(red);
d_motor_bracket_color            = plastic_color(green);
d_motor_bracket_lid_color        = plastic_color(red);
fixing_block_color               = plastic_color(green);
ribbon_clamp_color               = plastic_color(red);
fan_guard_color                  = plastic_color(green);
pcb_spacer_color                 = plastic_color(green);
pulley_color                     = plastic_color(red);
ribbon_clamp_color               = plastic_color(red);
wades_block_color                = plastic_color(yellow);
wades_big_gear_color             = plastic_color(green);
wades_small_gear_color           = plastic_color(red);
wades_idler_block_color          = plastic_color(green);
wades_gear_spacer_color          = plastic_color(red);
x_carriage_color                 = plastic_color(red);
x_belt_clamp_color               = plastic_color(green);
x_end_bracket_color              = plastic_color(green);
y_bearing_mount_color            = plastic_color(red);
y_belt_anchor_color              = plastic_color(green);
y_belt_clip_color                = plastic_color(red);
y_idler_bracket_color            = plastic_color(green);
y_motor_bracket_color            = plastic_color(green);
z_coupling_color                 = plastic_color(red);
z_limit_switch_bracket_color     = plastic_color(green);
z_motor_bracket_color            = plastic_color(green);
