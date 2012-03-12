//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Springs
//

extruder_spring = [7, 1, 10, 5];
hob_spring      = [12, 0.75, 10, 6];

// taken from openscad example 20
module coil(r1 = 100, r2 = 10, h = 100, twists)
{
    hr = h / (twists * 2);
    stepsize = 1/16;
    module segment(i1, i2) {
        alpha1 = i1 * 360*r2/hr;
        alpha2 = i2 * 360*r2/hr;
        len1 = sin(acos(i1*2-1))*r2;
        len2 = sin(acos(i2*2-1))*r2;
        if (len1 < 0.01)
            polygon([
                [ cos(alpha1)*r1, sin(alpha1)*r1 ],
                [ cos(alpha2)*(r1-len2), sin(alpha2)*(r1-len2) ],
                [ cos(alpha2)*(r1+len2), sin(alpha2)*(r1+len2) ]
            ]);
        if (len2 < 0.01)
            polygon([
                [ cos(alpha1)*(r1+len1), sin(alpha1)*(r1+len1) ],
                [ cos(alpha1)*(r1-len1), sin(alpha1)*(r1-len1) ],
                [ cos(alpha2)*r1, sin(alpha2)*r1 ],
            ]);
        if (len1 >= 0.01 && len2 >= 0.01)
            polygon([
                [ cos(alpha1)*(r1+len1), sin(alpha1)*(r1+len1) ],
                [ cos(alpha1)*(r1-len1), sin(alpha1)*(r1-len1) ],
                [ cos(alpha2)*(r1-len2), sin(alpha2)*(r1-len2) ],
                [ cos(alpha2)*(r1+len2), sin(alpha2)*(r1+len2) ]
            ]);
    }
    linear_extrude(height = h, twist = 180*h/hr,
            $fn = (hr/r2)/stepsize, convexity = 5) {
        for (i = [ stepsize : stepsize : 1+stepsize/2 ])
            segment(i-stepsize, min(i, 1));
    }
}


module comp_spring(spring, l = 0) {
    l = (l == 0) ? spring[2] : l;

    vitamin(str("SPR",  spring[0], spring[1] * 100, spring[2], ": Spring ", spring[0], " x ", spring[1], " x ", spring[2] ));

    color([0.2, 0.2, 0.2]) render() coil(r1 = (spring[0] - spring[1])/ 2, r2 = spring[1] / 2, h = l, twists = spring[3]);

}

//comp_spring(extruder_spring);
