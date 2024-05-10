extends Node3D

var chunk_scene = load("res://chunk.tscn")

var load_radius = 2
@onready var chunks = $Chunks
@onready var player = $Player

func _ready():
	for i in range(-load_radius, load_radius):
		for j in range(-load_radius, load_radius):
			var chunk_instance = chunk_scene.instantiate()
			chunk_instance.set_chunk_position(Vector2(i, j))
			chunks.add_child(chunk_instance)
			chunk_instance.set_chunk_position(Vector2(i, j))
