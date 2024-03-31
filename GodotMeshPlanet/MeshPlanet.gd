extends Node3D


# Iterates through all the faces to generate planet
func _ready():
	for child in get_children():
		var face := child as PlanetFace
		face.regenerate_mesh()
