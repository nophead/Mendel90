//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Virtual extruder
//
include <conf/config.scad>
use <wade.scad>
use <direct.scad>

function extruder_connector_offset() = extruder == Wades ? wades_extruder_connector_offset() : direct_extruder_connector_offset();

module extruder_motor_assembly(show_connector = true, exploded = exploded)
    if(extruder == Wades)
        wades_motor_assembly(show_connector, exploded);
    else
        direct_motor_assembly(show_connector, exploded);

module extruder_assembly(show_connector = true, show_drive = true)
    if(extruder == Wades)
        wades_assembly(show_connector, show_drive);
    else
        direct_assembly(show_connector, show_drive);
