extends Node3D

# player and camera variables
@onready var player = $Player
@onready var camera = player.get_node("TwistPivot/PitchPivot/Camera3D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera_global_position = camera.global_transform.origin
	# references global player position variable
	Global.player_position = camera_global_position
