import bpy
import sys

global ob
global cam_target
mat = 'abs'

def load_stl(file_path):
    global cam_target,ob
    # load
    bpy.ops.import_mesh.stl(filepath=file_path)
    # select properly
    ob = bpy.context.selected_objects[0]
    print(ob)
    bpy.ops.object.select_all(action='DESELECT')
    ob.select = True
    # remove doubles and clean
    #py.ops.object.editmode_toggle()
    #bpy.ops.mesh.select_all(action='TOGGLE')
    #bpy.ops.mesh.remove_doubles(limit=0.0001)
    #bpy.ops.mesh.normals_make_consistent(inside=False)
    #bpy.ops.object.editmode_toggle()
    bpy.ops.object.origin_set(type='GEOMETRY_ORIGIN', center='BOUNDS')
    # place
    z_dim = ob.dimensions[2]
    print(z_dim)
    bpy.ops.transform.translate(value=(0,0,z_dim/2.0))
    cam_target = (0,0,z_dim/3.0)
    # assign material
    ob.material_slots.data.active_material = bpy.data.materials[mat]

def place_camera():
    global cam_target
    max_dim = max(ob.dimensions[0] * 0.75, ob.dimensions[1] * 0.75,  ob.dimensions[2])
    print(max_dim)
    bpy.data.objects['target'].location = cam_target
    cam = bpy.data.objects['Camera'].location.x = max_dim * 2.4

def render_thumb(image,gl=False,anim=False):
    if gl:
        if anim:
            bpy.data.scenes['Scene'].render.filepath = "/tmp/"+ob.name+"#"
            bpy.ops.render.opengl(animation=True)
        else:
            bpy.ops.render.opengl(write_still=True)
            bpy.data.images['Render Result'].save_render(filepath=image)
    else:
        if anim:
            bpy.data.scenes['Scene'].render.filepath = "/tmp/"+ob.name+"#"
            bpy.ops.render.render(animation=True)
        else:
            bpy.ops.render.render(write_still=True)
            bpy.data.images['Render Result'].save_render(filepath=image)

image = sys.argv[-1]
stl = sys.argv[-2]
print(stl)
print(image)

load_stl(stl)
place_camera()
render_thumb(image,gl=False)
#bpy.ops.object.delete()
