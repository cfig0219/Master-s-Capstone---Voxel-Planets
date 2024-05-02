@tool
extends Node3D


@export var planet_data: PlanetData:
	set(val):
		planet_data = val
		
func _ready():
	# sets game_running boolean to true
	on_data_changed()

# Iterates through all the faces to generate planet
func on_data_changed():
	for child in get_children():
		# sets the radius of the bounding box
		child.set_radius(planet_data.radius)
		child.set_bounding_boxes()
		
		# loops through the 6 planet faces
		for i in range(6):
			var face_child = child.get_child(i)
			if face_child:
				var face := face_child as PlanetFace
				face.regenerate_mesh(planet_data, planet_data.resolution)
				
				# assigns the location of the current face by using the normals
				var current_normal = face.get_normal()
				var box_location = child.assign_box(current_normal)
				face.set_box_location(box_location)
				


# declares a dictionary to store whether each face has been updated
var updated_faces = {}

# updates shortest box distance throughout game runtime
func _process(_delta):
	# runs through the planet faces after initial generation
	for child in get_children():
		for i in range(6):
			var face = child.get_child(i)
			
			# gets the current face's location
			var face_location = face.get_box_location()
			var is_closest = child.is_shortest_distance(face_location, Global.player_position)
			
			# checks if the face needs to be updated
			if is_closest == true and not updated_faces.has(face):
				var new_resolution = planet_data.resolution * 4
				face.regenerate_mesh(planet_data, new_resolution)
				updated_faces[face] = true
			elif is_closest == false and updated_faces.has(face):
				# resets the face to its original resolution
				face.regenerate_mesh(planet_data, planet_data.resolution)
				updated_faces.erase(face)
