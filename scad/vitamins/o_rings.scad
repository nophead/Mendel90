//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// O rings
//
module O_ring(id, minor_d, actual_id = 0) {
    vitamin(str("ORG", id * 10, minor_d * 10, ": Nitrile O-ring ", id, "mm x ", minor_d, "mm"));

    D = actual_id > id ? actual_id : id;            // allow it to be stretched
    //
    // assume volume conserved when stretched. It is proportional to major diameter and square of minor diameter
    //
    r = (minor_d / 2) * sqrt(id / D);
    R = D / 2 + r / 2;
    color([0.2, 0.2, 0.2]) render() rotate_extrude(convexity = 10)
        translate([R, 0, 0])
            circle(r = r);
}

//O_ring(2.5, 1.6, 3);
