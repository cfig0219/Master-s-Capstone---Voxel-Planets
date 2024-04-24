extends MeshInstance3D
class_name QuadTree

# variables relevant to the current planet face mesh instance
var mesh_array : Array = []
var face_mesh : MeshInstance3D
var current_normal : Vector3

# variables relevant to the bounding boxes quadtree
var in_bounds = false
var tree_levels = 2
var bounding_boxes : Array = []


# Constructor to ensure the QuadTree requires a MeshInstance3D node
func _init(mesh_instance: MeshInstance3D, ):
	assert(mesh_instance != null, "QuadTree requires a MeshInstance3D node.")
	face_mesh = mesh_instance

# updates mesh array information
func set_total_mesh(mesh_data : Array):
	mesh_array = mesh_data
	
# stores information about the current planet face's orientation
func set_normal(normal : Vector3):
	current_normal = normal
	
func player_nearby(player_position : Vector3):
	#print(player_position)
	pass

	
# sets the number of quadtree levels to generate
func set_levels(radius : int):
	# uses logarithm to determine by what x 4 needs to equal radius*2
	var levels = floor(log(radius*2) / log(4))
	var min_size_level = floor(log(radius*2) / log(16))
	
	# uses difference between min size 4 and min size 16 levels to find tree levels
	# ensures that the minimum size of blocks per chunk remains at 16
	tree_levels = levels - min_size_level
	
# creates the desired collision shape
func create_box(radius : int):
		var box_shape = CylinderMesh.new()
		# transforms the cylynder box into a pyramid
		box_shape.set_radial_segments(4)
		box_shape.set_top_radius(0.0)
		box_shape.set_bottom_radius(2.83)
		box_shape.set_rings(0)
		
		# creates a the bounding box mesh instance
		var bounding_box = MeshInstance3D.new()
		bounding_box.mesh = box_shape
		
		# sets the scale of the bounding box
		bounding_box.scale = Vector3(radius, radius, radius)
		# offsets the box to the approproate location
		bounding_box.translate(current_normal * Vector3(1, 1, 1))
		bounding_box.rotate_y(deg_to_rad(45))
		
		# rotates the pyramid depending on the current's face normal
		if current_normal == Vector3(0, 1, 0): # top
			bounding_box.rotate_x(deg_to_rad(180)) 
		if current_normal == Vector3(0, -1, 0): # bottom
			bounding_box.rotate_x(deg_to_rad(0))
		if current_normal == Vector3(-1, 0, 0): # left
			bounding_box.rotate_z(deg_to_rad(270))
		if current_normal == Vector3(1, 0, 0): # right
			bounding_box.rotate_z(deg_to_rad(90))
		if current_normal == Vector3(0, 0, -1): # front
			bounding_box.rotate_x(deg_to_rad(90))
		if current_normal == Vector3(0, 0, 1): # back
			bounding_box.rotate_x(deg_to_rad(270))
			
		return bounding_box


# subdivides the existing total mesh into quads
func subdivide(radius : int):
	if mesh_array != []:
		# creates parent collision shape
		var parent_box = create_box(radius)
		#face_mesh.add_child(parent_box)
		#var shape = CollisionShape3D.new()
		#shape = parent_box.get_shape()
