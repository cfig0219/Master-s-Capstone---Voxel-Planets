@tool
extends Node3D

@export var planet_data: PlanetData:
	set(val):
		planet_data = val
		on_data_changed()
		
func _ready():
	on_data_changed()

# Iterates through all the faces to generate planet
func on_data_changed():
	for child in get_children():
		var face := child as PlanetFace
		face.regenerate_mesh(planet_data)
