@tool
extends Area3D
class_name BoundingBoxes

var bounding_radius = 100
# an array of arrays that contains all the bounding boxes
var box_coordinates = []
var shortest = 0


# sets the radius variable of the bounding box
func set_radius(radius : int):
	bounding_radius = radius
	var planet_box = CollisionShape3D.new()
	planet_box.shape = SphereShape3D.new()
	planet_box.scale = Vector3(bounding_radius*10, bounding_radius*10, bounding_radius*10)
	self.add_child(planet_box)
	
func store_coordinates(current_box : Vector3):
	box_coordinates.append(current_box)


# determines if the player distance to the current bounding box is the shortest
func is_closest_face(box_position : Vector3, player_position : Vector3):
	if player_position != Vector3(0, 0, 0):
		# populates a distances array using thed information in the box coordinates array
		var distances = []
		for coor in box_coordinates:
			distances.append(Global.player_position.distance_to(coor))
		
		# obtains shortest distance from distances list
		shortest = distances.min()
		var curr_distance = player_position.distance_to(box_position)
		var is_shortest = false
		
		# determines if the current distance is the shortest one
		for dist in distances:
			if (curr_distance == shortest) and (shortest < (bounding_radius*3)):
				is_shortest = true
				distances = [shortest] # erases all non-shortest positions
		#print("current distance: ", curr_distance, " shortest distance: ", shortest)
		return is_shortest
		
# obtains the current shortest distance
func shortest_distance():
	return shortest


# determines the location of the children faces
# the face child codes 00, 01, 10, 11 determine child generation order
func set_child_locations(normal : Vector3):
	var child_coordinates = []
	
	# creates bounding boxes in a 4 by 4 space
	for x in range(0, 2):
		for y in range(0, 2):
			var face_child = CollisionShape3D.new()
			var box_scale = Vector3(bounding_radius, bounding_radius, bounding_radius)
			var face_translation = normal
			face_child.shape = BoxShape3D.new()
			face_child.scale = box_scale
			
			# translates and scales once more to the appropriate length
			face_child.translate(face_translation)
			face_child.scale = box_scale * Vector3(1, 1.2, 1)
			#print(x, y) #00, 01, 10, 11 face child code order
			
			# rotates and shifts depending on the normal of the current planet face
			if normal == Vector3(0, 1, 0): # top
				face_child.rotate_x(deg_to_rad(180))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(0, -1, 0): # bottom
				face_child.rotate_x(deg_to_rad(0))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(-1, 0, 0): # left
				face_child.rotate_z(deg_to_rad(270))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(1, 0, 0): # right
				face_child.rotate_z(deg_to_rad(90))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(0, 0, -1): # front
				face_child.rotate_x(deg_to_rad(90))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			if normal == Vector3(0, 0, 1): # back
				face_child.rotate_x(deg_to_rad(270))
				face_child.translate(Vector3((x*0.7)-0.35, 0, (y*0.7)-0.35))
			
			# appends the children to the appropriate sub array in the bounding boxes array
			self.add_child(face_child)
			child_coordinates.append(face_child.get_global_position())
			
	return child_coordinates
