extends Node3D

var chunk_scene = load("res://chunk.tscn")

var load_radius = 2
@onready var chunks = $Chunks
@onready var player = $Player


func _ready():
	for i in range(-load_radius, load_radius):
		for j in range(-load_radius, load_radius):
			generate_chunk(i, j)
			
func generate_chunk(xpoint : int, zpoint : int):
	# get the global position of the chunks node
	var chunks_global_position = chunks.global_transform.origin
	
	var chunk_instance = chunk_scene.instantiate()
	chunk_instance.set_chunk_position(chunks_global_position/16 + Vector3(xpoint, -0.5, zpoint))
	chunks.add_child(chunk_instance)
	chunk_instance.set_global_position(Vector3(xpoint*16, -0.5, zpoint*16))

	
# Loads terrain on a separate thread from the player
func _process(delta):
	var player_pos = player.get_global_position()
	var player_position = floor(Vector2(player_pos.x, player_pos.z) / 16)
	var chunks_to_remove = []
	var existing_chunk_positions = []
	
	# prints fps and ram
	var fps = Engine.get_frames_per_second()
	var ram = OS.get_static_memory_usage() / 1000000.0
	print("FPS: ", fps, " RAM(MB): ", ram)
	
	if player_pos != Vector3(0, 0, 0):
		var chunk_children = chunks.get_children()
		for child in chunk_children:
			var chunk_position = child.get_chunk_position()
			var chunk_vec2 = Vector2(chunk_position.x, chunk_position.y)
			existing_chunk_positions.append(chunk_vec2)
			
			var xdiff = abs(chunk_vec2.x - player_position.x)
			var zdiff = abs(chunk_vec2.y - player_position.y)
			
			if xdiff > load_radius or zdiff > load_radius:
				chunks_to_remove.append(child)
				
		for chunk in chunks_to_remove:
			chunk.queue_free()
		
		for i in range(-load_radius, load_radius + 1):
			for j in range(-load_radius, load_radius + 1):
				var new_chunk_pos = player_position + Vector2(i, j)
				if not new_chunk_pos in existing_chunk_positions:
					generate_chunk(int(new_chunk_pos.x), int(new_chunk_pos.y))
