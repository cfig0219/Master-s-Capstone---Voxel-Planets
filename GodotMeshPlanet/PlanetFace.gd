# source: https://www.youtube.com/watch?v=hHRhDEVwDho&list=LL&index=6&t=605s
@tool

extends MeshInstance3D
class_name PlanetFace


# vector specifies which planet face to render
# @export allows for the use of script variables
@export var normal : Vector3

# generates the mesh for the current face
func regenerate_mesh(planet_data : PlanetData):
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	
	# specifies the triangles in the vertex array
	var vertex_array := PackedVector3Array()
	var uv_array := PackedVector2Array()
	var normal_array := PackedVector3Array()
	var index_array := PackedInt32Array()
	
	# determines how many triangles to generate depending on planet size
	var resolution := planet_data.resolution
	var num_vertices : int = resolution * resolution
	var num_indices : int = (resolution-1) * (resolution-1) * 6
	
	# resizes the mesh to the appropriate scale
	normal_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	vertex_array.resize(num_vertices)
	index_array.resize(num_indices)
	
	# generates mesh by iterating through every squaare of the face
	var tri_index : int = 0
	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)
	
	for y in range(resolution):
		for x in range(resolution):
			var i : int = x + y * resolution
			var percent := Vector2(x,y) / (resolution-1)
			var pointOnUnitCube : Vector3 = normal + (percent.x-0.5) * 2.0 * axisA + (percent.y-0.5) * 2.0 * axisB
			# transforms the cube into a sphere by making all distances equal through normalizaiton
			var pointOnUnitSphere := pointOnUnitCube.normalized() #* planet_data.radius
			# applies terrain noise to planet
			var pointOnPlanet := planet_data.point_on_planet(pointOnUnitSphere)
			
			# applues texture to planet
			var planet_material = load("PlanetMaterial.tres")
			planet_data.set_radius_to_shader(planet_material, planet_data.radius, planet_data.planet_color)
			
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
		
	# stores the vertex data insize an array of arrays
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	arrays[Mesh.ARRAY_INDEX] = index_array
	# insures that the mesh is generated dynamically duriing runtime
	call_deferred("_update_mesh", arrays)
	
# updates the mesh during runtime
func _update_mesh(arrays : Array):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh
