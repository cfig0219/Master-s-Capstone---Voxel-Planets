@tool
# source: https://www.youtube.com/watch?v=Q2iWDNq5PaU&t=45s

extends StaticBody3D

const vertices = [
	Vector3(0, 0, 0), #0
	Vector3(1, 0, 0), #1
	Vector3(0, 1, 0), #2
	Vector3(1, 1, 0), #3
	Vector3(0, 0, 1), #4
	Vector3(1, 0, 1), #5
	Vector3(0, 1, 1), #6
	Vector3(1, 1, 1)  #7
]

const TOP = [2, 3, 7, 6]
const BOTTOM = [0, 4, 5, 1]
const LEFT = [6, 4, 0, 2]
const RIGHT = [3, 1, 5, 7]
const FRONT = [7, 5, 4, 6]
const BACK = [2, 0, 1, 3]

var blocks = []

var st = SurfaceTool.new()
var mesh = null
var mesh_instance = null

var material = preload("res://Planet/PlanetMaterial.tres")

var _chunk_position = Vector3.ZERO
var planet_center = Vector3.ZERO
# adds terrain noise, note SimplexNoise does not work in godot4
var noise = Global.terrain_noise

func get_chunk_position() -> Vector3:
	return _chunk_position
	
func set_planet_center(planet_location):
	planet_center = planet_location

func _ready():
	generate()
	update()


# generates the different block types
func generate():
	blocks = []
	blocks.resize(Global.DIMENSION.x)
	for i in range(0, Global.DIMENSION.x):
		blocks[i] = []
		blocks[i].resize(Global.DIMENSION.y)
		for j in range(0, Global.DIMENSION.y):
			blocks[i][j] = []
			blocks[i][j].resize(Global.DIMENSION.z)
			for k in range(0, Global.DIMENSION.z):
				# gets the local x and z position for chunk noise
				var global_pos = _chunk_position * \
					Vector3(Global.DIMENSION.x, 0, Global.DIMENSION.z) + \
					Vector3(i, 0 , k)
					
				# uses local x and z positions to obtain y noise variable
				var height = int((noise.get_noise_3dv(global_pos/(Global.planet_radius/2))+1)/1 * (Global.DIMENSION.y) - 50)
				if height < 1:
					height = 1
				if height > Global.DIMENSION.y:
					height = Global.DIMENSION.y
				
				var block = Global.AIR
				
				# uses height value to generate terrain noise
				if j <= height - 3:
					block = Global.AIR
				elif j < height - 1 and j > height - 3:
					block = Global.STONE
				elif j < height:
					block = Global.DIRT
				elif j == height:
					block = Global.GRASS
					
				blocks[i][j][k] = block

func update():
	# Unload
	if mesh_instance != null:
		mesh_instance.call_deferred("queue_free")
		mesh_instance = null
	
	mesh = ArrayMesh.new()
	mesh_instance = MeshInstance3D.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1) # makes chunks seemless
	
	for x in Global.DIMENSION.x:
		for y in Global.DIMENSION.y:
			for z in Global.DIMENSION.z:
				create_block(x, y, z)
	
	st.generate_normals(false)
	st.set_material(material) # assigns the texture atlas material
	st.commit(mesh)
	mesh_instance.set_mesh(mesh)
	
	add_child(mesh_instance)
	# Create collision shape in a deferred call
	if mesh_instance != null:
		mesh_instance.call_deferred("create_trimesh_collision")
	
# checks to see if block faces are exposed to air "transparent"
func check_transparent(x, y, z):
	if x >= 0 and x < Global.DIMENSION.x and \
		y >= 0 and y < Global.DIMENSION.y and \
		z >= 0 and z < Global.DIMENSION.z:
			return not Global.types[blocks[x][y][z]][Global.SOLID]
	return true
	
# checks to see what faces to generate depending on which one is exposed to air
func create_block(x, y, z):
	var block = blocks[x][y][z]
	if block == Global.AIR:
		return
	
	var block_info = Global.types[block]
	
	if check_transparent(x, y + 1, z):
		create_face(TOP, x, y, z, block_info[Global.TOP])
	
	if check_transparent(x, y - 1, z):
		create_face(BOTTOM, x, y, z, block_info[Global.BOTTOM])
	
	if check_transparent(x - 1, y, z):
		create_face(LEFT, x, y, z, block_info[Global.LEFT])
		
	if check_transparent(x + 1, y, z):
		create_face(RIGHT, x, y, z, block_info[Global.RIGHT])
		
	if check_transparent(x, y, z - 1):
		create_face(BACK, x, y, z, block_info[Global.BACK])
		
	if check_transparent(x, y, z + 1):
		create_face(FRONT, x, y, z, block_info[Global.FRONT])
	

func create_face(i, x, y, z, texture_atlas_offset):
	var offset = Vector3(x, y, z)
	var a = vertices[i[0]] + offset
	var b = vertices[i[1]] + offset
	var c = vertices[i[2]] + offset
	var d = vertices[i[3]] + offset
	
	# Apply transformations to the vertices to distort the cube into a spheroid
	#a = distort_vertex(a)
	#b = distort_vertex(b)
	#c = distort_vertex(c)
	#d = distort_vertex(d)
	
	var uv_offset = texture_atlas_offset / Global.TEXTURE_ATLAS_SIZE
	var height = 1.0 / Global.TEXTURE_ATLAS_SIZE.y
	var width = 1.0 / Global.TEXTURE_ATLAS_SIZE.x
	
	var uv_a = uv_offset + Vector2(0, 0)
	var uv_b = uv_offset + Vector2(0, height)
	var uv_c = uv_offset + Vector2(width, height)
	var uv_d = uv_offset + Vector2(width, 0)
	
	st.add_triangle_fan(([a, b, c]), ([uv_a, uv_b, uv_c]))
	st.add_triangle_fan(([a, c, d]), ([uv_a, uv_c, uv_d]))
	
# distorts the chunk into a sphere shape
func distort_vertex(vertex):
	var x = vertex.x
	var y = vertex.y
	var z = vertex.z
	
	# obtains the domensions of the current chunk
	var x_dim = (Global.DIMENSION.x)/2
	var z_dim = (Global.DIMENSION.z)/2
	x = x - x_dim # sets the center x and z coords to (0,0)
	z = z - z_dim
	
	# curve factor
	var curve = 0.01

	# distorts the current chunk into sphere segment
	x = ((x * y) / 40)
	y = y - (((abs(x))**2) * curve) - (((abs(z))**2) * (curve/1.5))
	z = ((z * y) / 40)
	
	return Vector3(x, y, z)


func set_chunk_position(pos : Vector3):
	_chunk_position = pos
	pos.x = -pos.x
	var translation = (pos - (planet_center/16)) * 16
	
	# moves chunk to new position
	if mesh_instance:
		var new_transform = mesh_instance.global_transform
		new_transform.origin = translation
		mesh_instance.global_transform = new_transform
