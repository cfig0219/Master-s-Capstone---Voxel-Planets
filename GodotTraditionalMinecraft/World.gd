extends Node3D

var chunk_scene = load("res://chunk.tscn")

var load_radius = 7
@onready var chunks = $Chunks
@onready var player = $Player

func _ready():
	# initializes the chunks
	for i in range(load_radius):
		for j in range(load_radius):
			var chunk_instance = chunk_scene.instantiate()
			chunk_instance._ready()
			# differentiates the chunks
			chunk_instance.set_chunk_position(Vector2(i, j))
			chunks.add_child(chunk_instance)

	var index = 0
	# alters the location of the chunks
	for i in range(-2, load_radius - 2):
		for j in range(-2, load_radius - 2):
			var chunk_instance = chunks.get_child(index)
			# moves the chunks after tree creation
			chunk_instance.set_chunk_position(Vector2(i, j))
			index += 1  # Move to the next chunk instance in the chunks list
