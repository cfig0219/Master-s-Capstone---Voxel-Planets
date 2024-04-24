@tool
extends Node3D

@export var planet_data: PlanetData:
	set(val):
		planet_data = val
		on_data_changed()
		
func _ready():
	# sets game_running boolean to true
	on_data_changed()

# Iterates through all the faces to generate planet
func on_data_changed():
	for child in get_children():
		for i in range(6):
			var face_child = child.get_child(i)
			if face_child:
				var face := face_child as PlanetFace
				face.regenerate_mesh(planet_data)
