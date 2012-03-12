//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// BOM generation
//
module assembly(name) {                 // start an assembly
    if(bom > 0)
        echo(str(name, "/"));
}

module end(name) {                      // end an assembly
    if(bom > 0)
        echo(str("/",name));
}

module stl(name) {                      // name an stl
    if(bom > 0)
        echo(str(name,".stl"));
}

module vitamin(name) {                  // name a vitamin
    if(bom > 1)
        echo(name);
}
