shader_type spatial;

// For some reason 0,0 on the gradient is white, not black.
// This is the point where the 
const float OFFSET = .002;

uniform sampler2D normal_map;
uniform sampler2D gradient;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 base_color = vec3(0.0);
	float coord = fresnel(2.5, NORMAL, VIEW);
	vec4 col = texture(gradient, vec2(coord + OFFSET, 0));
	ALBEDO = base_color + col.rgb;
	
	NORMAL_MAP = texture(normal_map, UV).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
