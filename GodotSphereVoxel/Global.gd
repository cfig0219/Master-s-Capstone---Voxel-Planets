extends Node


# make to store global player data
# including information about nodes in an auto-loaded program leads to null errors
@export var player_position = Vector3.ZERO
@export var chunk_scene = load("chunk.tscn")

 # stores the current planet's important parameters
@export var terrain_noise = FastNoiseLite.new()
@export var planet_radius = 10
@export var planet_position = Vector3.ZERO


# variables for chunk generation
const DIMENSION = Vector3(16, 64, 16)
const TEXTURE_ATLAS_SIZE = Vector2(16, 16)

enum {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	FRONT,
	BACK,
	SOLID
}

enum {
	AIR,
	DIRT,
	GRASS,
	STONE
}

const types = {
	AIR:{
		SOLID:false
	},
	DIRT:{
		TOP:Vector2(2, 0), BOTTOM:Vector2(2, 0), LEFT:Vector2(2, 0),
		RIGHT:Vector2(2,0), FRONT:Vector2(2, 0), BACK:Vector2(2, 0),
		SOLID:true
	},
	GRASS:{
		TOP:Vector2(0, 0), BOTTOM:Vector2(2, 0), LEFT:Vector2(3, 0),
		RIGHT:Vector2(3, 0), FRONT:Vector2(3, 0), BACK:Vector2(3, 0),
		SOLID:true
	},
	STONE:{
		TOP:Vector2(1, 0), BOTTOM:Vector2(1, 0), LEFT:Vector2(1, 0),
		RIGHT:Vector2(1, 0), FRONT:Vector2(1, 0), BACK:Vector2(1, 0),
		SOLID:true
	}
}
