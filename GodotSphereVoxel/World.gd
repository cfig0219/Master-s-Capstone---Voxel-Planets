extends Node3D

# player and camera variables
@onready var player = $Player
@onready var camera = player.get_node("TwistPivot/PitchPivot/Camera3D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var camera_global_position = player.global_transform.origin
	# references global player positaw ion variable
	Global.player_position = camera_global_position
	
	# prints fps and ram
	var fps = Engine.get_frames_per_second()
	var ram = OS.get_static_memory_usage() / 1000000.0
	print("FPS: ", fps, " RAM(MB): ", ram)
