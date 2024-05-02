@tool
extends Area3D
class_name BoundingBoxes

var bounding_radius = 100
var tree_levels = 2
# an array of arrays that contains all the bounding boxes
var bounding_boxes = [[], [], [], [], [], [], []]
var box_coordinates = []


# sets the radius variable of the bounding box
func set_radius(radius : int):
	bounding_radius = radius
	set_levels() # sets the levels after radius is set

# sets the number of quadtree levels to generate
func set_levels():
	# uses logarithm to determine by what x 4 needs to equal radius*2
	var levels = floor(log(bounding_radius*2) / log(4))
	var min_size_level = floor(log(bounding_radius*2) / log(16))
	
	# uses difference between min size 4 and min size 16 levels to find tree levels
	# ensures that the minimum size of blocks per chunk remains at 16
	tree_levels = levels - min_size_level
	#print(tree_levels)

	
# initializes all the bounding boxes
func set_bounding_boxes():
	# creates the root planet bounding box
	var planet_box = CollisionShape3D.new()
	planet_box.shape = SphereShape3D.new()
	planet_box.scale = Vector3(bounding_radius*10, bounding_radius*10, bounding_radius*10)
	self.add_child(planet_box)
	bounding_boxes[0].append(planet_box)
	
	# initializes parent face bounding boxes
	for i in range(1,7):
		var parent_face = CollisionShape3D.new()
		parent_face.shape = BoxShape3D.new()
		parent_face.scale = Vector3(bounding_radius*2, bounding_radius*2, bounding_radius*2)
		
		# rotates the box depending on the current index
		if i == 1: # top
			parent_face.translate(Vector3(0, 0.5, 0))
			# adds children to bounding boxes
			#add_subboxes(1, Vector3(0, 0.5, 0))
		if i == 2: # bottom
			parent_face.translate(Vector3(0, -0.5, 0))
			#add_subboxes(2, Vector3(0, -0.5, 0))
		if i == 3: # left
			parent_face.translate(Vector3(-0.5, 0, 0))
			#add_subboxes(3, Vector3(-0.5, 0, 0))
		if i == 4: # right
			parent_face.translate(Vector3(0.5, 0, 0))
			#add_subboxes(4, Vector3(0.5, 0, 0))
		if i == 5: # front
			parent_face.translate(Vector3(0, 0, -0.5))
			#add_subboxes(5, Vector3(0, 0, -0.5))
		if i == 6: # back
			parent_face.translate(Vector3(0, 0, 0.5))
			#add_subboxes(6, Vector3(0, 0, 0.5))
		
		# appends new boxes to the bounding boxes array
		self.add_child(parent_face)
		bounding_boxes[i].append(parent_face)
		

# adds a child to every parent_face bounding box
# rotates the children by the x and y values that correspond to the current planet face
func add_subboxes(index : int, normal : Vector3):
	
	# creates bounding boxes in a 4 by 4 space
	for x in range(-1, 3):
		for y in range(-1, 3):
			var face_child = CollisionShape3D.new()
			var box_scale = Vector3(bounding_radius/2.0, bounding_radius/2.0, bounding_radius/2.0)
			var face_translation = normal * Vector3(4,4,4)
			face_child.shape = BoxShape3D.new()
			face_child.scale = box_scale
			
			# translates and scales once more to the appropriate length
			face_child.translate(face_translation)
			face_child.scale = box_scale * Vector3(1, 2, 1)
			
			# rotates and shifts depending on the normal of the current planet face
			if normal == Vector3(0, 0.5, 0): # top
				face_child.rotate_x(deg_to_rad(180))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(0, -0.5, 0): # bottom
				face_child.rotate_x(deg_to_rad(0))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(-0.5, 0, 0): # left
				face_child.rotate_z(deg_to_rad(270))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(0.5, 0, 0): # right
				face_child.rotate_z(deg_to_rad(90))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(0, 0, -0.5): # front
				face_child.rotate_x(deg_to_rad(90))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(0, 0, 0.5): # back
				face_child.rotate_x(deg_to_rad(270))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			
			# appends the children to the appropriate sub array in the bounding boxes array
			self.add_child(face_child)
			bounding_boxes[index].append(face_child)
			

# assigns a parent face bounding box to the face meshes
func assign_box(curr_normal : Vector3):
	var box_location = Vector3.ZERO
	
	# assigns the current box's coordinates by using the normal
	if curr_normal == Vector3(0, 1, 0): # top
		box_location = bounding_boxes[1][0].get_global_position()
		# stores the box coordinates of the planet faces
		box_coordinates.append(box_location)
	if curr_normal == Vector3(0, -1, 0): # bottom
		box_location = bounding_boxes[2][0].get_global_position()
		box_coordinates.append(box_location)
	if curr_normal == Vector3(-1, 0, 0): # left
		box_location = bounding_boxes[3][0].get_global_position()
		box_coordinates.append(box_location)
	if curr_normal == Vector3(1, 0, 0): # right
		box_location = bounding_boxes[4][0].get_global_position()
		box_coordinates.append(box_location)
	if curr_normal == Vector3(0, 0, -1): # front
		box_location = bounding_boxes[5][0].get_global_position()
		box_coordinates.append(box_location)
	if curr_normal == Vector3(0, 0, 1): # back
		box_location = bounding_boxes[6][0].get_global_position()
		box_coordinates.append(box_location)
		
	return box_location

# determines if the player distance to the current bounding box is the shortest
func is_shortest_distance(box_position : Vector3, player_position : Vector3):
	if player_position != Vector3(0, 0, 0):
		# populates a distances array using the information in the box coordinates array
		var distances = []
		for coor in box_coordinates:
			distances.append(Global.player_position.distance_to(coor))
		
		# obtains shortest distance from distances list
		var shortest = distances.min()
		var curr_distance = player_position.distance_to(box_position)
		var is_shortest = false
		
		# determines if the current distance is the shortest one
		for dist in distances:
			if (curr_distance == shortest) and (shortest < bounding_radius):
				is_shortest = true
				distances = [shortest] # erases all non-shortest positions
		return is_shortest

'''
# updates shortest box distance thorughout game runtime
func _process(delta):
	pass
		
	# code was commented out due to issues with collision detection
	for body in get_overlapping_bodies():
		print(body)
		if body == bounding_boxes[3][0]:  # Avoid detecting collisions with the Area3D itself
			print("Collision detected with:", body.name)'''
