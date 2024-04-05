shader_type spatial;

// the min_height is equal to the planet radius
uniform float min_height;
uniform float max_height; // min_height * 1.5
uniform sampler2D planet_color; // the planet color gradient input

varying float height;

// determines the color of terrain by elevation
void vertex() {
	height = length(VERTEX);
}

// gets the proportion between the sea level and max height
void fragment() {
	float h_color = height / (max_height-min_height) - (min_height / (max_height-min_height));
	vec4 grad_color = texture(planet_color, vec2(h_color, 0.0));
	
	// Extract RGB components from the sampled color
	vec3 albedo_color = grad_color.rgb;
	ALBEDO = albedo_color;
}
