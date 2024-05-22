# source: https://www.youtube.com/watch?v=hHRhDEVwDho&list=LL&index=6&t=605s
@tool

extends MeshInstance3D
class_name PlanetFace


# vector specifies which planet face to render
# @export allows for the use of script variables
@export var normal : Vector3

# stores the vertices array
var arrays := []
# the face's bounding box location
var box_location = Vector3.ZERO
var subchild_coordinates = []


# helper function to generate parent planet face
func generate_face(planet_data : PlanetData, resolution : int):
	regenerate_mesh(planet_data, resolution, 0, resolution, 0, resolution)

# generates the mesh for the current face
# the start and end determine what portion of the face gets generated
func regenerate_mesh(planet_data : PlanetData, resolution : int, y_start: int, y_end: int, x_start : int, x_end : int):
	arrays.resize(Mesh.ARRAY_MAX)
	
	# applies texture to planet
	var planet_material = load("res://Planet/PlanetMaterial.tres")
	planet_data.set_radius_to_shader(planet_material, planet_data.radius, planet_data.planet_color)
	
	# specifies the triangles in the vertex array
	var vertex_array := PackedVector3Array()
	var uv_array := PackedVector2Array()
	var normal_array := PackedVector3Array()
	var index_array := PackedInt32Array()
	
	# determines how many triangles to generate depending on planet size
	var num_vertices : int = resolution * resolution
	var num_indices : int = (resolution-1) * (resolution-1) * 6
	
	# resizes the mesh to the appropriate scale
	normal_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	vertex_array.resize(num_vertices)
	index_array.resize(num_indices)
	
	# generates mesh by iterating through every square of the face
	var tri_index : int = 0
	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)
	
	# generates the current face at the specified range
	for y in range(y_start, y_end):
		for x in range(x_start, x_end):
			var i : int = x + y * resolution
			var percent := Vector2(x,y) / (resolution-1)
			var pointOnUnitCube : Vector3 = normal + (percent.x-0.5) * 2.0 * axisA + (percent.y-0.5) * 2.0 * axisB
			# transforms the cube into a sphere by making all distances equal through normalizaiton
			var pointOnUnitSphere := pointOnUnitCube.normalized() #* planet_data.radius
			# applies terrain noise to planet
			var pointOnPlanet := planet_data.point_on_planet(pointOnUnitSphere)
			
			vertex_array[i] = pointOnPlanet #pointOnUnitSphere #swap with pointOnUnitCube to generate cube
			if x != resolution-1 and y != resolution-1:
				index_array[tri_index+2] = i
				index_array[tri_index+1] = i+resolution+1
				index_array[tri_index] = i+resolution
				index_array[tri_index+5] = i
				index_array[tri_index+4] = i+1
				index_array[tri_index+3] = i+resolution+1
				tri_index += 6
				
	# calculates the normals based on direction of the face
	for a in range(0, index_array.size(), 3):
		var b : int = a + 1
		var c : int = a + 2
		var ab : Vector3 = vertex_array[index_array[b]] - vertex_array[index_array[a]]
		var bc : Vector3 = vertex_array[index_array[c]] - vertex_array[index_array[b]]
		var ca : Vector3 = vertex_array[index_array[a]] - vertex_array[index_array[c]]
		
		var cross_ab_bc : Vector3 = ab.cross(bc) * -1.0
		var cross_bc_ca : Vector3 = bc.cross(ca) * -1.0
		var cross_ca_ab : Vector3 = ca.cross(ab) * -1.0
		normal_array[index_array[a]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[b]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[c]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		
	# insures that the range of the normals remains between zero and one
	for i in range(normal_array.size()):
		normal_array[i] = normal_array[i].normalized()
		
	# stores the vertex data inside an array of arrays
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	arrays[Mesh.ARRAY_INDEX] = index_array
	
	# insures that the mesh is generated dynamically during runtime
	call_deferred("_update_mesh", arrays)
	
	
# updates the mesh during runtime
func _update_mesh(pt_arrays : Array):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, pt_arrays)
	self.mesh = _mesh
	
# sets the location of the face's assigned bounding box
func set_face_location(radius : int):
	box_location = self.get_global_position() + (normal * Vector3(radius, radius, radius))
	
func get_face_location():
	return box_location
	
func get_normal():
	return normal
	
func get_child_locations(child_locations : Array):
	subchild_coordinates = child_locations
	return subchild_coordinates
	
	
# generates the children of the face
# face child code order is determined in BoundingBox function set_child_location()
func sub_faces(planet_data : PlanetData, resolution : int):
	if subchild_coordinates != []:
		# erases current parent face
		regenerate_mesh(planet_data, 4, 0, 0, 0, 0)
		
		# generates the child faces
		var child_face1 = self.duplicate()
		child_face1.regenerate_mesh(planet_data, resolution, 0, (resolution/2.0)+1, 0, (resolution/2.0)+1)
		self.add_child(child_face1) # face child 00
		
		var child_face2 = child_face1.duplicate()
		child_face2.regenerate_mesh(planet_data, resolution, 0, (resolution/2.0)+1, resolution/2.0, resolution)
		self.add_child(child_face2) # face child 01
		
		var child_face3 = child_face1.duplicate()
		child_face3.regenerate_mesh(planet_data, resolution, resolution/2.0, resolution, 0, (resolution/2.0)+1)
		self.add_child(child_face3) # face child 10
		
		var child_face4 = child_face1.duplicate()
		child_face4.regenerate_mesh(planet_data, resolution, resolution/2.0, resolution, resolution/2.0, resolution)
		self.add_child(child_face4) # face child 11
		

# determines if the player distance to the current bounding box is the shortest
func is_closest_child(child_position : Vector3, player_position : Vector3):
	if player_position != Vector3(0, 0, 0):
		# populates a distances array using the information in the box coordinates array
		var distances = []
		for coor in subchild_coordinates:
			distances.append(Global.player_position.distance_to(coor))
		
		# obtains shortest distance from distances list
		var shortest = distances.min()
		var curr_distance = player_position.distance_to(child_position)
		var is_shortest = false
		
		# determines if the current distance is the shortest one
		for dist in distances:
			if curr_distance == shortest:
				is_shortest = true
				distances = [shortest] # erases all non-shortest positions
		#print("current distance: ", curr_distance, " shortest distance: ", shortest, " is shortest: ", is_shortest)
		return is_shortest

# modifies an individual child face
func alter_subface(index : int, planet_data : PlanetData, resolution : int):
	var current_children = self.get_children()
	if subchild_coordinates != []:
		# determines what child to modify
		if index == 0:
			current_children[0].regenerate_mesh(planet_data, resolution, 0, (resolution/2.0)+1, 0, (resolution/2.0)+1)
		if index == 1:
			current_children[1].regenerate_mesh(planet_data, resolution, 0, (resolution/2.0)+1, resolution/2.0, resolution)
		if index == 2:
			current_children[2].regenerate_mesh(planet_data, resolution, resolution/2.0, resolution, 0, (resolution/2.0)+1)
		if index == 3:
			current_children[3].regenerate_mesh(planet_data, resolution, resolution/2.0, resolution, resolution/2.0, resolution)
	#print(" altered distance: ", current_children[index])
