@tool
extends Resource

class_name PlanetData

@export var radius := 32
@export var resolution := 64
@export var noise_map := FastNoiseLite.new()
@export var amplitude : float = 0.2
@export var min_height : float = 0.14

# for terrain color
@export var planet_color : GradientTexture1D

# applies terrain noice on a spherical surface
func point_on_planet(point_on_sphere : Vector3) -> Vector3:
	var elevation = noise_map.get_noise_3dv(point_on_sphere)
	elevation = elevation + 1 / 2.0 * amplitude
	elevation = max(0.0, elevation - min_height)
	return point_on_sphere * radius * (elevation+1.0)
	
# function to pass radius to the shader
func set_radius_to_shader(material: ShaderMaterial, radius_value: float, terrain_color: GradientTexture1D):
	material.set_shader_parameter("min_height", radius_value)
	material.set_shader_parameter("max_height", radius_value * 1.5)
	material.set_shader_parameter("planet_color", terrain_color)
