shader_type spatial;

uniform float thickness;
uniform float alpha = 0.8;

varying float v_view_z;   

vec4 calculate_border(vec3 vertex, mat4 modelview, float adjusted_thickness) {
	// radial expansion from near the BASE so bottom verts expand outward (not down)
	// -> the outline wraps the bottom too. Continuous shell, no gaps, no normal use.
	vec3 d = vertex - vec3(0.0, 0.05, 0.0);
	vec3 dir = length(d) > 0.001 ? normalize(d) : vec3(0.0, -1.0, 0.0);
	vec3 view_n = normalize((modelview * vec4(dir, 0.0)).xyz);
	vec4 view_pos = modelview * vec4(vertex, 1.0);
	
	view_pos.xyz += view_n * adjusted_thickness;
	
	return view_pos;
}
void vertex() {
	vec4 view_pos = calculate_border(VERTEX, MODELVIEW_MATRIX, thickness);
	v_view_z = view_pos.z;
	POSITION = PROJECTION_MATRIX * view_pos;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALPHA = alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
