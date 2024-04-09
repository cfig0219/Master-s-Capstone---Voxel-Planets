extends Node3D

# player and camera variables
@onready var player = $Player
@onready var camera = player.get_node("TwistPivot/PitchPivot/Camera3D")

# mesh vertices variables



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera_global_position = camera.global_transform.origin
	print(camera_global_position)
