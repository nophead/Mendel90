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
use <frame_edge_clamp.scad>

light = light_strip ? light_strip : SPS125;

show_rays = false;

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

function round_to_layer(z) = ceil(z / layer_height) * layer_height;

pi_cam_front_clearance = 1.6;
pi_cam_front_wall = 2;
pi_cam_front_depth = pi_cam_back_depth + pi_cam_thickness + pi_cam_front_clearance + wall;
pi_cam_front_length = pi_cam_back_length + 2 * (pi_cam_front_wall + clearance);
pi_cam_front_width = pi_cam_back_width + 2 * (pi_cam_front_wall + clearance);

bar_dia = 12;
bar_gap = 2;
bar_wall = 3;

X_build = min(X_travel, bed_holes[0] - screw_head_radius(M3_cap_screw) * 2); // sturdy travel exceeds the bed so max object is smaller
Y_build = min(Y_travel, bed_holes[1] - screw_head_radius(M3_cap_screw) * 2);

y_limit = Y0 + (Y_travel + Y_build) / 2 + 1;
bar_z = 240;
bar_y = y_limit + bar_dia / 2 + wall + 2;

cam_offset = pi_cam_front_width / 2 - pi_cam_width / 2 + pi_cam_back_width / 2 - pi_cam_centreline + bar_dia / 2;
cam_x = X_origin;
cam_y = bar_y - bar_dia / 2 - pi_cam_front_wall;
cam_z = bar_z - cam_offset;

hypot = sqrt(sqr(bar_z - bed_height) + sqr(bar_y - Y0));
angle = atan2(bar_z - bed_height, bar_y - Y0) - asin(cam_offset / hypot);

left = left_stay_x + sheet_thickness(frame) / 2;
right = right_stay_x - sheet_thickness(frame) / 2;

bar_length = right - left - 2;
bar_overlap = 2 * (cam_x -(right + left) / 2);
clamp_length = bar_dia - frame_edge_clamp_pitch(0) + 2 * nut_flat_radius(M3_nut) + clearance * 2;

band_width = 2 * (nut_trap_radius(M3_nut) + wall);
band_tab_h = 2 * (nut_trap_flat_radius(M3_nut) + wall);
band_ir = bar_dia / 2;
band_or = band_ir + pi_cam_front_wall;
band_y = pi_cam_front_width / 2 - pi_cam_width / 2 + pi_cam_back_width / 2 - pi_cam_front_wall + band_or + eta;

band_tab_t = M3_nut_trap_depth + wall;
band_slit = 1;
band_tab_d = max(2 * band_tab_t + band_slit, 16 - washer_thickness(M3_washer) - nut_thickness(M3_nut, true) + M3_nut_trap_depth - 0.5);
band_tab_height = band_tab_h + sqrt(sqr(band_or) - sqr(band_tab_d / 2));

light_x = (left + right) / 2;
light_z = bar_z + bar_dia / 2 + light_strip_width(light) / 2 + pi_cam_front_wall + clearance;
bar_z_offset = light_z - bar_z;

light_angle = atan2(bar_z - bed_height, bar_y - Y0) + asin(bar_z_offset / hypot);

light_incursion = max(0, y_limit + sin(light_angle) * (bar_z_offset + light_strip_width(light) / 2) - bar_y);

bar_y_offset = (light_strip_thickness(light) + light_incursion) / cos(light_angle);
light_y = bar_y + bar_y_offset;

light_band_tab_h = 2 * (nut_trap_radius(M3_nut) + wall);
light_band_tab_height = light_band_tab_h + sqrt(sqr(band_or) - sqr(band_tab_d / 2));

module pi_cam_holes(mid_only = false) {
    ypos = [pi_cam_centreline, pi_cam_width / 2 - 2];
    for(y = mid_only ? [ ypos[0] ] : ypos)
        for(x = [-pi_cam_length / 2 + 2, pi_cam_length / 2 - 2])
            translate([x, y, 0])
                 child();
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

    stl("rpi_camera_focus_ring");

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
        union() {
            translate([0, -pi_cam_width / 2 + pi_cam_back_width / 2, pi_cam_back_depth / 2])
                cube([pi_cam_back_length, pi_cam_back_width, pi_cam_back_depth], center = true);

            *translate([0, pi_cam_centreline, pi_cam_back_depth + lug_height - lug_rad])
                rotate([0, 90, 90])
                    cylinder(r = lug_rad, h = lug_width, center = true);

            *translate([ - lug_rad, pi_cam_centreline - lug_width / 2, 0])
                cube([lug_rad * 2, lug_width, lug_height - lug_rad + pi_cam_back_depth]);
        }

        translate([0, -pi_cam_back_overlap, 0])
            cube([pi_cam_length - 2 * pi_cam_back_overlap, pi_cam_width, 2 * pi_cam_back_clearance], center = true);

        translate([0, -pi_cam_width / 2, 0])
            cube([pi_cam_connector_length + 2 * clearance, 2 * pi_cam_connector_depth + 1, 2 * round_to_layer(pi_cam_connector_height + clearance)], center = true);

        pi_cam_holes(mid_only = true) group() {
            translate([0, 0, pi_cam_back_depth])
                rotate([180, 0, 90])
                    nut_trap(M2_clearance_radius, nut_radius(M2_nut), M2_nut_trap_depth, supported = true);

            *translate([0, 0, pi_cam_back_clearance + layer_height])
                rotate([0, 0, 90])
                    poly_cylinder(r = M2_clearance_radius, h = 100);
        }

        *translate([0, pi_cam_centreline, pi_cam_back_depth + lug_height - lug_rad])
            rotate([90, 0, 0])
                teardrop_plus(r = lug_hole_r, h = lug_width + 1, center = true);
    }
}

module rpi_camera_front_stl() {
    stl("rpi_camera_front");

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
            //
            // bar clamp
            //
            hull() {
                translate([0, band_y, band_or])
                    rotate([-90, 0, 90])
                        teardrop(r = band_or, h = band_width, center = true);                       // clamp band to go round bar

                translate([-band_width / 2, pi_cam_front_length / 2 - rad, 0])
                    cube([band_width, 1, 1]);
            }

            translate([0, band_y, band_or + band_tab_height / 2])
                cube([band_width, band_tab_d, band_tab_height], center = true);                     // tab for screw
        }
        translate([0, band_y, band_or])
            rotate([90, 0, 90])
                teardrop(r = band_ir, h = band_width + 1, center = true);

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
        //
        // bar clamp
        //
        translate([-50, band_y - band_slit / 2, band_or + band_ir + 5 * layer_height / 4])
            cube([100, band_slit, 100]);

        translate([0, band_y + band_tab_d / 2, band_or + band_tab_height - band_tab_h / 2])
            rotate([90, 0, 0])
                nut_trap(M3_clearance_radius, nut_radius(M3_nut), M3_nut_trap_depth, horizontal = true);

    }

}

module camera_bar(male = false) {
    length = bar_length / 2 + (male ? -bar_overlap / 2 : bar_overlap / 2);

    translate([0, base_depth / 2 - bar_y, 0])
        difference() {
            union() {
                tube(or = bar_dia / 2, ir = bar_dia / 2 - bar_wall, h = length, center = false);
                if(male)
                    translate([0, 0, length - 6 * layer_height])
                        cylinder(r = bar_dia / 2 - wall - 0.1, h = bar_overlap + 6 * layer_height);
            }
            if(!male)
                translate([0, 0, length])
                    cylinder(r = bar_dia / 2 - wall, h = 2 * bar_overlap + 2, center = true);

            *translate([-100, 0, 0])
                cube([200, 200, 200]);
    }
}

module rpi_light_clamp_stl() {

    thickness = 3;
    overlap = 1;
    length = light_strip_width(light) + 2 * wall;
    gap = light_strip_width(light) + clearance;

    stl("rpi_light_clamp");

    difference() {
        union() {
            translate([-length / 2, - bar_y_offset, 0])
                cube([length, thickness + bar_y_offset, band_width]);

            translate([0, 0, band_width / 2 + eta])
                rotate([-90, 0, 0])
                    teardrop(r = nut_trap_radius(M3_nut) + wall, h = wall + M3_nut_trap_depth);


            translate([bar_z_offset, -bar_y_offset, 0]) {
                cylinder(r = band_or, h = band_width);

                translate([light_band_tab_height / 2, 0, band_width / 2])
                    cube([light_band_tab_height, band_tab_d, band_width], center = true);                     // tab for screw
            }
        }
        translate([-gap / 2, - bar_y_offset * 2, -1])
            cube([gap, bar_y_offset * 2, band_width + 2]);

        translate([-gap / 2 - wall - 1, -bar_y_offset -overlap, -1])
            cube([wall + 2, bar_y_offset, band_width + 2]);

        translate([bar_z_offset, -bar_y_offset, 0])
            cylinder(r = band_ir, h = 100, center = true);


        translate([0, wall + M3_nut_trap_depth, band_width / 2])
            rotate([90, 0, 0])
                nut_trap(M3_clearance_radius, nut_radius(M3_nut), M3_nut_trap_depth, horizontal = true);
        //
        // bar clamp
        //
        translate([bar_z_offset, -bar_y_offset, 0]) {
            translate([0, -band_slit / 2, -1])
                cube([100, band_slit, band_width + 2]);

            translate([light_band_tab_height - light_band_tab_h / 2, -band_tab_d / 2, band_width / 2])
                rotate([90, 0, 0])
                    nut_trap(M3_clearance_radius, nut_radius(M3_nut), M3_nut_trap_depth, horizontal = true);
        }
   }
}


module raspberry_pi_camera_assembly(light_strip = true) {
    assembly("raspberry_pi_camera_assembly");

    translate([0, bar_y, bar_z]) {
        rotate([angle, 0, 0])
            translate([cam_x, cam_y - bar_y, cam_z - bar_z]) rotate([90, 0, 0]) translate([0, -pi_cam_centreline, 0]) {
                color("lime") render()
                    translate([0, 0, - pi_cam_front_depth - 40 * exploded])
                        rpi_camera_back_stl();

                color("blue") render()
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

                translate([0, (band_y - band_tab_d / 2), -(band_or + band_tab_height - band_tab_h / 2)]) {
                    rotate([90, 0, 0])
                        screw_and_washer(M3_cap_screw, 16);

                    translate([0, band_tab_d - M3_nut_trap_depth, 0])
                        rotate([-90, 0, 0])
                            nut(M3_nut, true);
                }

                translate([0, pi_cam_centreline, 1.5 + 10 * exploded]) color("lime") render() rpi_camera_focus_ring_stl();
            }

        if(light_strip)
            rotate([light_angle, 0, 0])
                translate([light_x, bar_y_offset, bar_z_offset]) {
                    rotate([90, 0, 0])
                        light_strip(light);

                    for(side = [-1, 1])
                        translate([side * light_strip_hole_pitch(light) / 2, 0, 0]) {
                            translate([-band_width / 2, 0, 0])
                                rotate([0, 90, 0])
                                    color("blue") render() rpi_light_clamp_stl();

                            translate([0, -light_strip_thickness(light), 0])
                                rotate([90, 0, 0])
                                    screw_and_washer(M3_cap_screw, 10);

                            translate([0, wall, 0])
                                rotate([-90, 90, 0])
                                    nut(M3_nut, true);

                            translate([0, -bar_y_offset, -bar_z_offset]) {
                                translate([0, band_tab_d / 2, -light_band_tab_height + light_band_tab_h / 2])
                                    rotate([-90, 0, 0])
                                        screw_and_washer(M3_cap_screw, 16);

                                translate([0, -band_tab_d / 2 + M3_nut_trap_depth,
                                              -light_band_tab_height + light_band_tab_h / 2])
                                    rotate([90, 90, 0])
                                        nut(M3_nut, true);
                            }
                        }
                }

    }

    stl("rpi_camera_bar");

    for(side = [-1, 1])
        translate([side < 0 ? left : right, base_depth / 2, bar_z])
            explode([20 * side, 0, 0])
                rotate([0, side * 90, 180])
                    frame_edge_clamp_assembly(length = clamp_length, left = side < 0)
                        camera_bar(side > 0);

    if(show_rays) {
        %hull() {                           // light ray, should point at centre of Y axis.
            translate([0, bar_y, bar_z])
                rotate([angle, 0, 0])
                    translate([cam_x, cam_y - bar_y, cam_z - bar_z])
                        sphere();

            translate([X_origin, Y0, bed_height])
                sphere();
        }

        %hull() {                           // light ray, should point at centre of Y axis.
            translate([0, bar_y, bar_z])
                rotate([light_angle, 0, 0])
                    translate([X_origin, bar_y_offset - light_strip_thickness(light), bar_z_offset])
                        sphere();

            translate([X_origin, Y0, bed_height])
                sphere();
        }

        translate([X_origin, Y0 + Y_travel / 2, bed_height + Z_travel / 2])
            %cube([X_build, Y_build, Z_travel], center = true);               // work volume at max Y travel
    }

    end("raspberry_pi_camera_assembly");
}

module rpi_camera_bar_stl() {

    for(side = [-1, 1])
        translate([side * (clamp_length / 2 + 1), 0, 0]) {
            frame_edge_clamp_front_stl(length = clamp_length)
                camera_bar(side > 0);

            translate([0, frame_edge_clamp_width() + 2, 0])
                frame_edge_clamp_back_stl(length = clamp_length);
        }
}

module rpi_camera_case_stl() {
    rpi_camera_front_stl();

    translate([pi_cam_front_length, 0, 0])
        rpi_camera_back_stl();
}

if(1)
    raspberry_pi_camera_assembly();
else
    if(1)
        rpi_camera_case_stl();
    else
        rpi_camera_bar_stl();
