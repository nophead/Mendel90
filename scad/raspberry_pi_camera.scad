//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Bracket to mount RPI camera
//
include <conf/config.scad>
include <positions.scad>
use <light_strip_clip.scad>
use <frame_edge_clamp.scad>

left = left_stay_x + sheet_thickness(frame) / 2;
right = right_stay_x - sheet_thickness(frame) / 2;

light  = light_strip ? light_strip : (right - left) > 300 ? RIGID5050_290 : RIGID5050_208;
light2 = light == RIGID5050_290 ? RIGID5050_208 : false;

wall = 2;
clearance = 0.2;

pi_cam_width = 24;
pi_cam_length = 25;
pi_cam_thickness = 1;
pi_cam_hole_pitch = pi_cam_length - 4;

pi_cam_hole_r = 2.1 / 2;
pi_cam_turret = 8;
pi_cam_connector_length = 23;
pi_cam_connector_depth = 6;
pi_cam_connector_height = 2.65;

pi_cam_led_pos = [pi_cam_length / 2 - 4.5, pi_cam_width / 2 - 5, pi_cam_thickness];
pi_cam_led_clearance = [3, 2, 0.8 * 2];

pi_cam_res_pos = [pi_cam_length / 2 - 5.5, pi_cam_width / 2 - 3, pi_cam_thickness];
pi_cam_res_clearance = [3.5, 2, 0.8 * 2];

pi_cam_back_clearance = 1.6;
pi_cam_back_overlap = 1;

pi_cam_back_wall = min_wall;
pi_cam_back_depth = max(pi_cam_connector_height + wall, pi_cam_back_clearance + wall + M2_nut_trap_depth);
pi_cam_back_length = pi_cam_hole_pitch + 2 * (nut_flat_radius(M2_nut) + min_wall);
pi_cam_back_width = pi_cam_width + (pi_cam_back_length - pi_cam_length) / 2;
pi_cam_centreline = -pi_cam_width / 2 + 9.5;

pi_cam_front_clearance = 1.6;
pi_cam_front_wall = 2;
pi_cam_front_depth = pi_cam_back_depth + pi_cam_thickness + pi_cam_front_clearance + wall;
pi_cam_front_length = pi_cam_back_length + 2 * (pi_cam_front_wall + clearance);
pi_cam_front_width = pi_cam_back_width + 2 * (pi_cam_front_wall + clearance);

X_build = min(X_travel, bed_holes[0] - screw_head_radius(M3_cap_screw) * 2); // sturdy travel exceeds the bed so max object is smaller
Y_build = min(Y_travel, bed_holes[1] - screw_head_radius(M3_cap_screw) * 2);

y_limit = Y0 + (Y_travel + Y_build) / 2 + 1;

pivot_screw_length = 16;
end_cap_nut_boss_r = nut_trap_radius(M3_nut, horizontal = false) + 3 * filament_width;
end_cap_nut_boss = pivot_screw_length - washer_thickness(M3_washer) - frame_edge_clamp_thickness() - 2;

pivot_offset = frame_edge_clamp_hinge() + washer_diameter(M3_washer) / 2;
pivot_y = base_depth / 2 + pivot_offset;

light2_z_top = light_strip_clip_length(light) / 2 + (light2 ? light_strip_clip_length(light2) - wall : 0);
light2_distance = sqrt(sqr(Z_travel) + sqr(y_limit - Y0));
max_light_angle = atan2(Z_travel, y_limit - Y0) - asin(light2_z_top  / light2_distance);
max_pivot_z = bed_height + tan(max_light_angle) * (pivot_y - Y0);
pivot_z = 240;

pivot_light2_distance = sqrt(sqr(bed_height + Z_travel - max_pivot_z) + sqr(y_limit - pivot_y));
pivot_max_distance = sqrt(sqr(max_pivot_z - bed_height) + sqr(pivot_y - Y0));

light_x = (left + right) / 2;
light_y = pivot_y - end_cap_nut_boss_r;
light_angle = atan2(pivot_z - bed_height, pivot_y - Y0);

hinge_screw = M2_cap_screw;
hinge_nut = screw_nut(hinge_screw);
hinge_screw_length = 12;

hinge_r = nut_trap_radius(hinge_nut) + 3 * filament_width;
hinge_h = max(wall + nut_trap_depth(hinge_nut), light_strip_clip_depth(light) / 2);
cam_hinge_h = light_strip_clip_depth(light) - hinge_h;

light_hinge_offset = hinge_r + 0.5;
light_hinge_z_offset = light_strip_clip_length(light) / 2 + light_hinge_offset * cos(light_angle);
light_hinge_y_offset = light_strip_clip_width(light) + light_hinge_offset * sin(light_angle);

hinge_y = light_y + wall - light_hinge_y_offset;
hinge_z = pivot_z - light_hinge_z_offset;

cam_hinge_z_offset = pi_cam_front_width / 2 + hinge_r - pi_cam_width / 2 + pi_cam_back_width / 2 - pi_cam_centreline + 0.5;
cam_hinge_y_offset = hinge_r;

cam_x = X_origin;
cam_y = hinge_y - cam_hinge_y_offset;
cam_z = hinge_z - cam_hinge_z_offset;

light2_z_offset = light2_z_top - light_strip_clip_length(light2) / 2;
light2_x_offset = cam_x - light_x;
dy = sqrt(sqr(pivot_light2_distance) - sqr(light2_z_top));
light2_y_offset = -(pivot_y - light_y) + wall - light_strip_clip_width(light2) + (light2_distance < pivot_max_distance ? dy : -dy);

clamp_length = 20;

hypot = sqrt(sqr(pivot_z - bed_height) + sqr(pivot_y - Y0));
adj = hypot - (pivot_y - hinge_y);
alpha = atan2(light_hinge_z_offset, adj);
hypot2 = sqrt(sqr(adj) + sqr(light_hinge_z_offset));
beta = asin(cam_hinge_z_offset / hypot2);
cam_angle = light_angle - alpha - beta;

module pi_cam_holes(mid_only = false) {
    ypos = [pi_cam_centreline, pi_cam_width / 2 - 2];
    for(y = mid_only ? [ ypos[0] ] : ypos)
        for(x = [-pi_cam_length / 2 + 2, pi_cam_length / 2 - 2])
            translate([x, y, 0])
                 children();
}

module raspberry_pi_camera() {
    vitamin("RPICAM: Raspberry PI camera");
    color("green") render() difference() {
        translate([0, 0, pi_cam_thickness / 2])
            cube([pi_cam_length, pi_cam_width, pi_cam_thickness], center = true);

        pi_cam_holes()
            cylinder(r = pi_cam_hole_r, h = 100);
    }

    color("DarkSlateGray") render() union() {
        translate([0, -pi_cam_width / 2 + 9.5, 1.5 + pi_cam_thickness ])
            cube([pi_cam_turret, pi_cam_turret, 3], center = true);

        translate([0, pi_cam_centreline, pi_cam_thickness])
            cylinder(r = 7.5 / 2, h = 4);

        translate([0, pi_cam_centreline, pi_cam_thickness])
            cylinder(r = 5.5 / 2, h = 5);
    }

    color("Khaki")
        render() translate([- pi_cam_connector_length / 2, -pi_cam_width / 2, - pi_cam_connector_height])
            cube([pi_cam_connector_length, pi_cam_connector_depth, pi_cam_connector_height]);

    color("red")
        render() translate(pi_cam_led_pos) cube(center = true);

    if(show_rays)
        translate([0, pi_cam_centreline, pi_cam_thickness])
            %cylinder(r = 1, h = 100);
}

module rpi_camera_focus_ring_stl() {
    rad = 15 / 2;
    hole_r1 = 2.5 / 2;
    hole_r2 = 5 / 2;
    thickness = 3;
    flutes = 8;
    angle = 180 / flutes;
    x = rad / (sin(angle / 2) + cos(angle / 2));
    r = x * sin(angle / 2);

    difference() {
        linear_extrude(height = thickness, convexity = 5)
            difference() {
                union() {
                    circle(x);
                    for(i = [0 : flutes - 1])
                        rotate([0, 0, 2 * angle * i])
                            translate([x, 0])
                                circle(r);
                }
                for(i = [0 : flutes - 1])
                    rotate([0, 0, 2 * angle * i + angle])
                        translate([x, 0])
                            circle(r);
            }
        hull() {
            poly_cylinder(r = hole_r1, h = 0.1, center = true);

            translate([0, 0, thickness])
                poly_cylinder(r = hole_r2, h = 0.1, center = true);
        }
    }
}

module rpi_camera_back_stl() {
    lug_width = 6.4;
    lug_rad = 8;
    lug_height = 20;
    lug_hole_r = 6.4 / 2;

    stl("rpi_camera_back");
    translate([0, 0, pi_cam_back_depth]) rotate([0, 180, 0]) difference() {
        translate([0, -pi_cam_width / 2 + pi_cam_back_width / 2, pi_cam_back_depth / 2])
            cube([pi_cam_back_length, pi_cam_back_width, pi_cam_back_depth], center = true);

        translate([0, -pi_cam_back_overlap, 0])
            cube([pi_cam_length - 2 * pi_cam_back_overlap, pi_cam_width, 2 * pi_cam_back_clearance], center = true);

        translate([0, -pi_cam_width / 2, 0])
            cube([pi_cam_connector_length + 2 * clearance, 2 * pi_cam_connector_depth + 1, 2 * round_to_layer(pi_cam_connector_height + clearance)], center = true);

        pi_cam_holes(mid_only = true) group() {
            translate([0, 0, pi_cam_back_depth])
                rotate([180, 0, 90])
                    nut_trap(M2_clearance_radius, nut_radius(M2_nut), M2_nut_trap_depth, supported = true);

        }
    }
}

module rpi_camera_front_stl() {
    shelf = pi_cam_front_depth - pi_cam_back_depth;
    connector_slot = pi_cam_connector_height + 2 * layer_height;
    rad = pi_cam_front_wall;
    led_hole_r = 1.25;


    sensor_length = pi_cam_width / 2 - pi_cam_back_overlap - pi_cam_centreline;

    difference() {
        union() {
            hull()
                for(x = [-1, 1], y = [-1, 1])
                    translate([x * (pi_cam_front_length / 2 - rad), y * (pi_cam_front_width / 2 - rad) - pi_cam_width / 2 + pi_cam_back_width / 2, 0])
                        hull() {    // 3D truncated teardrop gives radiused edges without exceeding 45 degree overhang
                            translate([0, 0, pi_cam_front_depth - 1])
                                cylinder(r = rad, h = 1 + 2 * layer_height);

                            translate([0, 0, rad])
                                sphere(rad);

                            cylinder(r = rad * (sqrt(2) - 1), h = eta);
                        }

            translate([-light_strip_clip_depth(light) / 2 + hinge_h, cam_hinge_z_offset + pi_cam_centreline, cam_hinge_y_offset])
                hull() {
                    rotate([-90, 0, -90])
                        teardrop(r = hinge_r, h = cam_hinge_h);

                    translate([0, -hinge_r - 10, - hinge_r])
                        cube([cam_hinge_h, hinge_r + 10, 2 * hinge_r]);
                }
        }
        translate([0, cam_hinge_z_offset + pi_cam_centreline, cam_hinge_y_offset])
            rotate([90, 0, 90])
                teardrop_plus(r = screw_clearance_radius(hinge_screw), h = 100, center = true);

        translate([0, -pi_cam_width / 2 + pi_cam_back_width / 2, pi_cam_front_depth / 2 + shelf - layer_height])   // recess for the back
            cube([pi_cam_back_length + 2 * clearance, pi_cam_back_width + 2 * clearance, pi_cam_front_depth], center = true);

        translate([0, 0, pi_cam_front_depth / 2 + shelf - pi_cam_thickness])                        // recess for PCB
            cube([pi_cam_length + 2 * clearance, pi_cam_width + 2 * clearance, pi_cam_front_depth], center = true);

        rotate([0, 180, 0]) translate(pi_cam_led_pos - [0, 0, shelf])                               // clearance for LED
            cube(pi_cam_led_clearance, center = true);

        rotate([0, 180, 0]) translate(pi_cam_res_pos - [0, 0, shelf])                               // clearance for resistor
            cube(pi_cam_res_clearance, center = true);

        translate([0, pi_cam_centreline + sensor_length / 2, shelf - pi_cam_thickness])             // clearance for sensor connector
            cube([pi_cam_turret + 2 * clearance, sensor_length, 2 * pi_cam_front_clearance], center = true);

        translate([0, -pi_cam_width / 2, shelf + connector_slot / 2 - layer_height])                // slot for connector
            cube([pi_cam_connector_length + 2 * clearance, pi_cam_connector_depth * 2, connector_slot], center = true);

        pi_cam_holes(mid_only = true)                                                               // screw holes
            translate([0, 0, pi_cam_back_clearance + layer_height])
                rotate([0, 0, 90])
                    poly_cylinder(r = M2_clearance_radius, h = 100, center = true);

        translate([0, pi_cam_centreline, 0])
            cube(pi_cam_turret + 2 * clearance, center = true);                                     // hole for lens

        rotate([0, 180, 0]) translate(pi_cam_led_pos) cylinder(r = led_hole_r, h = 100, center = true);   // hole for led
    }
}

module pivot_lug() {
    linear_extrude(height = frame_edge_clamp_thickness(), convexity = 2)
        difference() {
            hull() {
                translate([-clamp_length / 2, -frame_edge_clamp_hinge()])
                    square([clamp_length, eta]);

                translate([0, -pivot_offset])
                    circle(washer_diameter(M3_washer)/ 2 + 1);
            }
            translate([0, -pivot_offset])
                poly_circle(M3_clearance_radius);
        }
}

module light_strip_end_cap_stl() {
    base_thickness = (right - left - 2 * frame_edge_clamp_thickness() - 1 - light_strip_length(light)) / 2;

    difference() {
        union() {
            linear_extrude(height = base_thickness, convexity = 2)
                hull() {
                    translate([-light_strip_clip_length(light) / 2, end_cap_nut_boss_r - wall])
                        square([light_strip_clip_length(light), light_strip_clip_width(light)]);

                    circle(end_cap_nut_boss_r);
                }

            cylinder(r = end_cap_nut_boss_r, h = end_cap_nut_boss);

            translate([0, end_cap_nut_boss_r - wall, base_thickness - eta])
                light_strip_clip(light);
        }
        translate([0, 0, end_cap_nut_boss])
            nut_trap(M3_clearance_radius, M3_nut_radius, M3_nut_trap_depth);

        translate([-(light_strip_clip_gap(light) - eta) / 2, end_cap_nut_boss_r + eta, -1])  // extend the slot for wires
            cube([light_strip_clip_gap(light) - 2 * eta, 100, 100]);

        translate([50, end_cap_nut_boss_r - wall - eta, end_cap_nut_boss + eta])    // truncate back to level of screw boss when is short
            rotate([0, 0, 180])
                cube([100, 100, 100]);
    }
}

module rpi_camera_bracket_stl(include_support = true) {
    difference() {
        union() {
            light_strip_clip(light);

            translate([light_hinge_z_offset, light_hinge_y_offset, 0]) union() {
                cylinder(r = hinge_r, h = hinge_h);

                rotate([0, 0, 180 + light_angle])
                    translate([0, - wall / 2, 0])
                        cube([light_hinge_offset + wall, wall, hinge_h]);
            }
        }
        translate([light_hinge_z_offset, light_hinge_y_offset, 0])
            nut_trap(screw_clearance_radius(hinge_screw), nut_radius(hinge_nut), nut_trap_depth(hinge_nut), supported = include_support);
    }
}

module light_strip_piggy_back_clip() {
        union() {
            light_strip_clip(light);

            translate([light2_z_offset, light2_y_offset, 0]) {
                difference() {
                    translate([-light_strip_clip_length(light2) / 2, 0, 0])
                        cube([light_strip_clip_length(light2), light_strip_clip_width(light2), wall]);

                    translate([-(light_strip_clip_gap(light2) - eta) / 2, wall, -1])  // extend the slot for wires
                        cube([light_strip_clip_gap(light2) - 2 * eta, 100, 100]);
                }
                translate([0, 0, wall - eta])
                    light_strip_clip(light2);
            }

            translate([light_strip_clip_length(light) / 2, 0, 0])
                rotate([0, 0, 180])
                    cube([wall, -light2_y_offset, light_strip_clip_depth(light2)]);
        }
}

module light_strip_piggy_back_clips_stl() {

    offset = -(light_strip_clip_length(light) / 2 + light_strip_clip_length(light2) - wall);
    translate([offset, -light_strip_clip_width(light) - 1, 0])
        light_strip_piggy_back_clip();

    translate([offset, light_strip_clip_width(light) + 1, 0])
        rotate([180, 0, 0])
            mirror([0, 0, 1])
                light_strip_piggy_back_clip();
}

module raspberry_pi_camera_assembly() {
    assembly("raspberry_pi_camera_assembly");

    stl("rpi_camera_case");
    translate([0, pivot_y, pivot_z]) {
        rotate([light_angle, 0, 0])
            translate([0, hinge_y - pivot_y, hinge_z - pivot_z])
                rotate([cam_angle - light_angle, 0, 0])
                    translate([cam_x, cam_y - hinge_y, cam_z - hinge_z - pi_cam_centreline]) rotate([90, 0, 0]) {
                        color("lime") render()
                            translate([0, 0, - pi_cam_front_depth - 40 * exploded])
                                rpi_camera_back_stl();

                        color("red") render()
                            rotate([0, 180, 0])
                                rpi_camera_front_stl();

                        translate([0, 0, pi_cam_back_depth - pi_cam_front_depth - 23 * exploded])
                            raspberry_pi_camera();

                        pi_cam_holes(mid_only = true) group() {
                            screw_and_washer(M2_cap_screw, 12);

                            translate([0, 0, -pi_cam_front_depth + M2_nut_trap_depth - 40 * exploded])
                                rotate([0, 180, 90])
                                    nut(M2_nut, true);
                        }

                        translate([0, pi_cam_centreline, 1.5 + 10 * exploded])
                            color("lime") render()
                                rpi_camera_focus_ring_stl();
                    }
    }

    stl("light_and_camera_brackets");
    stl("rear_light_brackets");

    translate([0, pivot_y, pivot_z])
        rotate([light_angle, 0, 0]) {
            translate([light_x, light_y - pivot_y, 0]) {
                rotate([90, 0, 0]) {
                    light_strip(light);

                    if(light2) {
                        translate([light2_x_offset, light2_z_offset, light2_y_offset])
                            light_strip(light2);

                        for(side = [-1, 1])
                            translate([light2_x_offset + side * (light_strip_length(light2) / 2 + wall), 0, -wall])
                                rotate([90, 0, 90])
                                    mirror([0, 0, side > 0 ? 1 : 0])
                                        color("lime") render()
                                            light_strip_piggy_back_clip();
                    }
                }

                translate([cam_x - light_x + light_strip_clip_depth(light) / 2, wall, 0])
                    rotate([180, 90, 0]) {
                        color("lime") render()
                            rpi_camera_bracket_stl(false);

                        translate([light_hinge_z_offset, light_hinge_y_offset, 0]) {
                            translate([0, 0, hinge_h + cam_hinge_h])
                                screw_and_washer(hinge_screw, hinge_screw_length);

                            translate([0, 0, nut_trap_depth(hinge_nut)])
                                rotate([180, 0, 0])
                                    nut(hinge_nut, true);
                        }
                    }
            }
        }

     for(side = [-1, 1])
        translate([side < 0 ? left : right, base_depth / 2, pivot_z])
            explode([20 * side, 0, 0])
                rotate([0, side * 90, 180]) {
                    frame_edge_clamp_assembly(length = clamp_length, kids = true)
                        pivot_lug();

                    translate([0, -pivot_offset, 0]) {
                        rotate([180, 0, 0])
                            screw_and_washer(M3_cap_screw, pivot_screw_length);

                        translate([0, 0, frame_edge_clamp_thickness() + end_cap_nut_boss - M3_nut_trap_depth])
                            rotate([0, 0, -side * light_angle])
                                nut(M3_nut, true);
                    }

                    translate([0, -pivot_offset, frame_edge_clamp_thickness()])
                        rotate([0, 0, -side * light_angle])
                            color("lime") render()
                                light_strip_end_cap_stl();
                }

    if(show_rays) {
        %hull() {                           // light ray, should point at centre of Y axis.
            translate([0, pivot_y, pivot_z])
                rotate([light_angle, 0, 0])
                    translate([0, hinge_y - pivot_y, hinge_z - pivot_z])
                        rotate([cam_angle - light_angle, 0, 0])
                            translate([cam_x, cam_y - hinge_y, cam_z - hinge_z])
                                sphere();

            translate([X_origin, Y0, bed_height])
                sphere();
        }

        %hull() {                           // light ray, should point at centre of Y axis.
            translate([0, pivot_y, pivot_z])
                rotate([light_angle, 0, 0])
                    translate([X_origin, -(pivot_y - light_y) - light_strip_thickness(light), 0])
                        sphere();

            translate([X_origin, Y0, bed_height])
                sphere();
        }

        translate([X_origin, Y0 + Y_travel / 2, bed_height + Z_travel / 2])
            %cube([X_build, Y_build, Z_travel], center = true);               // work volume at max Y travel
    }

    end("raspberry_pi_camera_assembly");
}

module rear_light_brackets_stl() {
    for(side = [-1, 1]) {
        translate([side * (clamp_length / 2 + 1), 0, 0]) {
            translate([0, -frame_edge_clamp_width()  + frame_edge_clamp_hinge() - 2, 0])
                frame_edge_clamp_front_stl(length = clamp_length)
                    pivot_lug();

            translate([0, frame_edge_clamp_hinge(), 0])
                frame_edge_clamp_back_stl(length = clamp_length);
        }
    }
}

module light_and_camera_brackets_stl() {
    for(side = [-1, 1])
        translate([side * (light_strip_clip_length(light) / 2 + 1), end_cap_nut_boss_r + 2, 0])
            light_strip_end_cap_stl();

    rotate([0, 0, 180])
        rpi_camera_bracket_stl();

    if(light2)
        translate([0, light_strip_clip_width(light) + 2 * end_cap_nut_boss_r - wall + 4, 0])
            rotate([0, 0, -90])
                light_strip_piggy_back_clips_stl();
}

module rpi_camera_case_stl() {
    rpi_camera_front_stl();

    translate([pi_cam_front_length, 0, 0])
        rpi_camera_back_stl();

    translate([0, -pi_cam_front_width / 2 - 9, 0])
        rpi_camera_focus_ring_stl();
}

if(1)
    raspberry_pi_camera_assembly();
else if(1)
    light_and_camera_brackets_stl();
else if(0)
    rpi_camera_case_stl();
else
    rear_light_brackets_stl();
