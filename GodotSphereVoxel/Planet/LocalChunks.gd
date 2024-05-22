@tool
extends Node3D

var load_radius = 2
var last_player_position = Vector2()

# Called when the node enters the scene tree for the first time.
func generate_chunks(player_position : Vector3, planet_center : Vector3, planet_radius : int):
	if player_position != Vector3(0,0,0) and planet_center != Vector3(0,0,0):
		var chunk_rotation = calculate_rotation(player_position, planet_center)
		var chunk_location = calculate_location(player_position, planet_center, planet_radius)
		
		# measures distance to planet
		var distance = player_position.distance_to(planet_center)
		# obtains the surface coordinates of the planet
		var coordinate = get_coordinate(chunk_rotation, planet_radius, distance)
		
		# generates first chunk on the planet
		if distance < (planet_radius + 200):
			chunk_matrix(chunk_location, chunk_rotation, coordinate, planet_center)
		elif distance > (planet_radius + 200):
			remove_chunks()
			
# adds one chunk at requested location
func add_one_chunk(chunk_position : Vector3, global_location : Vector3, planet_center : Vector3):
	var chunk_instance = Global.chunk_scene.instantiate()
	chunk_instance.set_planet_center(planet_center)
	chunk_instance.set_chunk_position(chunk_position)
	self.add_child(chunk_instance)
	chunk_instance.set_global_position(global_location)

func remove_chunks():
	var children = get_children()
	# iterates through the array and remove each child
	for child in children:
		child.queue_free()


# calculates the rotation needed for the chunk
func calculate_rotation(player_pos : Vector3, planet_center : Vector3):
	if player_pos != Vector3(0,0,0) and planet_center != Vector3(0,0,0):
		
		# calculates the latitude
		var direction_to_player = (player_pos - planet_center).normalized()
		var planet_rotation_axis = Vector3(0, 1, 0)
		var dot_product = direction_to_player.dot(planet_rotation_axis)
		var latitude = acos(dot_product)
		
		# calculates the longitude
		var direction_to_player_proj = direction_to_player - planet_rotation_axis * dot_product
		var equator_reference = Vector3(1, 0, 0)  # change this as per your equator direction
		var longitude_dot_product = direction_to_player_proj.dot(equator_reference)
		var cross_product = equator_reference.cross(planet_rotation_axis)
		var longitude = atan2(cross_product.dot(direction_to_player_proj), longitude_dot_product) - PI/2
		
		# Convert longitude to range [0, 2*PI)
		if longitude < 0:
			longitude += 2 * PI
		
		# returns the needed rotation
		var orientation = Vector3(latitude, 0, longitude)
		return orientation
	
# rotates the current chunk in the order neccesary to avoid any distortions
func rotate_chunks(old_rotation : Vector3):
	var current_rotation = old_rotation
	current_rotation.x = old_rotation.x
	current_rotation.y = -old_rotation.z # inverts z axis rotation
	current_rotation.z = 0 # sets z to zero to prevent flipping
	return current_rotation


# calculates the coordinate relative to the planet's surface
func calculate_location(player_pos : Vector3, planet_center : Vector3, radius : int):
	if player_pos != Vector3(0,0,0) and planet_center != Vector3(0,0,0):
		var direction_to_player = (player_pos - planet_center).normalized()
		var surface_position = planet_center + direction_to_player * radius
		return surface_position

# converts the existing default spatial coordinate system
# the new system uses the distance from the planet as the y coordinate
func get_coordinate(current_rotation : Vector3, radius : int, distance : int):
	# converts the current rotation to degrees
	var degrees = Vector3(
		rad_to_deg(current_rotation.x),
		rad_to_deg(current_rotation.y),
		rad_to_deg(current_rotation.z)
	)
	
	# converts the x component of degrees into the north and south coordinate
	var zaxis = (degrees.x / 180) * (radius*PI)
	# converts the z compoment of degrees into east and west coordinate
	var xaxis = (degrees.z / 360) * ((radius*2) * PI)
	var yaxis = distance - radius # y axis represents distance to sea level
	
	var coordinate = Vector3(floor(xaxis), yaxis, floor(zaxis))
	return coordinate


# generates an x by z matrix of chunk positions arounf the player
func chunk_matrix(node_location : Vector3, node_rotation : Vector3, surface_coordinate : Vector3, planet_center : Vector3):
	var player_pos = surface_coordinate
	var player_position = floor(Vector2(player_pos.x, player_pos.z) / 16)
	var chunk_positions = []
	var global_positions = []
	
	# creates a collision box variable to determine where to generate chunks
	var chunk_area = Area3D.new()
	self.add_child(chunk_area)
	
	# tracks the distance the player has moved
	var distance_moved = (player_position - last_player_position).length()*16
	var player_moved = distance_moved >= 16
	if not player_moved:
		return
	# updates the last known player position
	last_player_position = player_position
	
	# instances of the chunk collision box
	for i in range(-load_radius, load_radius):
		for j in range(-load_radius, load_radius):
			var chunk_box = CollisionShape3D.new()
			chunk_box.shape = BoxShape3D.new()
			chunk_box.scale = Vector3(16, 64, 16)
			chunk_box.translate(Vector3(i, 0, j))
			chunk_area.add_child(chunk_box)
			
			chunk_area.set_global_position(node_location) # eliminates holes at poles
			chunk_area.set_global_rotation(rotate_chunks(node_rotation))
			
			# appends the chunk position and global chunk position to the arrays
			var global_pos = chunk_box.get_global_position()
			var chunk_position = Vector3((-surface_coordinate.x/16 + i), 0, (surface_coordinate.z/16 + j))
			chunk_positions.append(chunk_position)
			global_positions.append(global_pos)
			
	var chunk_children = chunk_area.get_children()
	
	# sets the rotation of the chunks node to follow the player
	self.set_rotation(rotate_chunks(node_rotation))
	remove_chunks() # removes the chunk area collision shapes
	
	# Ensure that there are no more positions than children
	var num_children = chunk_children.size()
	var num_positions = chunk_positions.size()
	var max_count = min(num_children, num_positions)
	
	# Assign positions to each child in order
	for child_index in range(max_count):
		var child = chunk_children[child_index]
		var chunk_position = chunk_positions[child_index]
		var global_location = global_positions[child_index]
			
		child.queue_free()
		add_one_chunk(chunk_positions[child_index], global_positions[child_index], planet_center)
