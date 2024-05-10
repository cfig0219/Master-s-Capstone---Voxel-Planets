extends Node3D

# player and camera variables
@onready var player = $Player
@onready var camera = player.get_node("TwistPivot/PitchPivot/Camera3D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var camera_global_position = camera.global_transform.origin
	# references global player positaw ion variable
	Global.player_position = camera_global_position


# loads the chunks into the world
var chunk_scene = load("chunk.tscn")
var load_radius = 2
@onready var chunks = $Chunks

func _ready():
	for i in range(-load_radius, load_radius):
		for j in range(-load_radius, load_radius):
			var chunk_instance = chunk_scene.instantiate()
			chunk_instance.set_chunk_position(Vector2(i, j))
			chunks.add_child(chunk_instance)
			chunk_instance.set_chunk_position(Vector2(i, j))
