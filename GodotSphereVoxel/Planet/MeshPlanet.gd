@tool
extends Node3D

# instance of Chunk program
var chunks = Node3D

@export var planet_data: PlanetData:
	set(val):
		planet_data = val
		
func _ready():
	# stores global planet parameters
	Global.terrain_noise = planet_data.noise_map
	Global.planet_radius = planet_data.radius
	Global.planet_position = self.get_global_position()
	
	# calls function to generate planet
	on_data_changed()

# Iterates through all the faces to generate planet
func on_data_changed():
	for child in get_children():
		# sets the radius of the Area3D
		child.set_radius(planet_data.radius)
		
		# loops through the 6 planet faces
		for i in range(6):
			var face_child = child.get_child(i)
			if face_child:
				var face := face_child as PlanetFace
				
				# generates entire planet face at range 0 to planet resolution
				face.generate_face(planet_data, planet_data.resolution)
				# sets and stores the location of the current face
				face.set_face_location(planet_data.radius)
				child.store_coordinates(face.get_face_location())
				
		# calls last child of Area3D
		chunks = child.get_child(6)


# declares a dictionary to store whether each face has been updated
var updated_faces = {}
var children_created = false
var subface_coordinates = []
var closest_subface = MeshInstance3D

# updates shortest box distance throughout game runtime
func _process(_delta):
	# runs through the planet faces after initial generation
	for child in get_children():
		for i in range(6):
			var face = child.get_child(i)
			
			# gets the current face's location
			var face_location = face.get_face_location()
			var is_closest = child.is_closest_face(face_location, Global.player_position)
			var shortest_dist = child.shortest_distance()
			var child_render = planet_data.radius * 2 # render threshold for face child generation
			
			# checks if the face needs to be updated
			if is_closest == true and not updated_faces.has(face):
				var new_resolution = planet_data.resolution * 3
				face.generate_face(planet_data, new_resolution)
				updated_faces[face] = true
					
			elif shortest_dist < child_render and is_closest == true and updated_faces.has(face) and children_created == false:
				children_created = true # sets children created boolean to true
				var new_resolution = planet_data.resolution * 3
				var child_coordinates = []
				# adds children to face and assigns locations to the sub faces
				child_coordinates = child.set_child_locations(face.get_normal())
				subface_coordinates = face.get_child_locations(child_coordinates)
				face.sub_faces(planet_data, new_resolution)
					

			# determines which child is the closest
			elif children_created == true and is_closest == true:
				var face_children = face.get_children()
				for x in range(4):
					# adjusted the subface_coordinate index due to disprecepcy in face determination
					var sub_in = x+2
					if sub_in == 4:
						sub_in = 0
					if sub_in == 5:
						sub_in = 1
					
					var closest_child = face.is_closest_child(subface_coordinates[sub_in], Global.player_position)
					var current_child = face_children[x] # stores the current child
					if closest_child == true and closest_subface != current_child:
						# increases the resolution of the nearest child face
						var new_resolution = planet_data.resolution * 6
						face.alter_subface(x, planet_data, new_resolution)
						closest_subface = current_child
						
					# resets the resolution when face is no longer the closest
					elif closest_child == false and closest_subface == current_child:
						current_child = face_children[x]
						var new_resolution = planet_data.resolution * 3
						face.alter_subface(x, planet_data, new_resolution)
				
			elif is_closest == false and updated_faces.has(face):
				# resets the face to its original resolution
				face.generate_face(planet_data, planet_data.resolution)
				updated_faces.erase(face)
				children_created = false
				# removes the children of previous face
				for subface in face.get_children():
					face.remove_child(subface)
					subface.queue_free()
					
		# generates the chunks
		chunks.generate_chunks(Global.player_position, Global.planet_position, Global.planet_radius)
