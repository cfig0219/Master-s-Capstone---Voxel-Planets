@tool
extends Node3D

var load_radius = 1
var first_chunk = false
var prev_chunk = Vector3.ZERO
var chunk_gap = 0

# Called when the node enters the scene tree for the first time.
func generate_chunk(player_position : Vector3, planet_center : Vector3, planet_radius : int):
	if player_position != Vector3(0,0,0) and planet_center != Vector3(0,0,0):
		var chunk_rotation = calculate_rotation(player_position, planet_center)
		var chunk_location = calculate_location(player_position, planet_center, planet_radius)
		# measures distance to planet
		var distance = player_position.distance_to(planet_center)
		
		# obtains the surface coordinates of the planet
		var coordinate = get_coordinate(chunk_rotation, planet_radius, distance)
		#print(" correct: ", chunk_location)
		
		# generates first chunk on the planet
		if first_chunk == false and distance < (planet_radius + 200):
			prev_chunk = chunk_location # stores location of first chunk
			self.add_chunk(chunk_location, coordinate)
			#self.rotate_chunks(chunk_rotation)
			first_chunk = true
			
		elif first_chunk == true and chunk_gap < 20:
			# measures distance between previous chunk and new chunk to be generated
			chunk_gap = prev_chunk.distance_to(chunk_location)
		# generates new chunk when player walks far enough
		elif chunk_gap > 20:
			prev_chunk = chunk_location
			chunk_gap = prev_chunk.distance_to(chunk_location)
			remove_chunks()
			self.add_chunk(chunk_location, coordinate)
			self.rotate_chunks(chunk_rotation)
			
# generates one chunk at the requested location
func add_chunk(location : Vector3, planet_coordinate: Vector3):
	for i in range(-load_radius, load_radius):
		for j in range(-load_radius, load_radius):
			var chunk_instance = Global.chunk_scene.instantiate()
			chunk_instance.set_chunk_position(planet_coordinate + Vector3(i, 0, j))
			self.add_child(chunk_instance)
			
			# translates the individual chubks before setting location of chunk node
			chunk_instance.translate(Vector3(i * 16, 0, j * 16))
			self.set_global_position(location)

func remove_chunks():
	var children = get_children()
	# iterates through the array and remove each child
	for child in children:
		remove_child(child)


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
func rotate_chunks(rotation : Vector3):
	var current_rotation = self.rotation
	current_rotation.y = -rotation.z # inverts z axis rotation
	current_rotation.x = rotation.x
	current_rotation.z = 0 # sets z to zero to prevent flipping
	self.rotation = current_rotation
	print(current_rotation)


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
	
	var coordinate = Vector3(round(xaxis), yaxis, round(zaxis))
	return coordinate
