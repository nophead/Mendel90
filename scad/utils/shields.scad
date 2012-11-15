// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// For making heat shields to prevent corner warping, see http://hydraraptor.blogspot.co.uk/2010/09/some-corners-like-it-hot.html
//
shield_thickness = 1;
shield_base_thickness = 4;
shield_base_height = 5;
shield_clearance = 1;

module L(w,h,t) {
	translate([-t,-t,0])
		difference() {
			cube([w,w,h]);
			translate([t,t,-1]) cube([w,w,h+2]);
		}
}

module corner_shield(w,h) {
	color([0,1,0])union() translate([-shield_clearance, -shield_clearance, 0]) {
		L(w,h,shield_thickness);
		L(w + shield_base_thickness - shield_thickness, shield_base_height, shield_base_thickness);
	}
}

module side_shield(w,h) {
	translate([-w/2, -shield_thickness, 0])
		color([0,1,0]) union() {
			cube([w, shield_thickness, h]);
			translate([0,shield_thickness - shield_base_thickness, 0]) 
				cube([w, shield_base_thickness, shield_base_height]);
		}
}

//corner_sheild(20, 15);

