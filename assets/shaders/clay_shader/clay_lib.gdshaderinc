const float GLOBAL_SCALING = 10.0;

global uniform sampler2D fingerprints;
global uniform sampler2D cracks;
global uniform sampler2D crack_detail;
global uniform sampler2D diffuse_test;

uniform bool show_diffuse_test = false;
uniform vec4 base_color: source_color = vec4(1, 1, 1, 1);
uniform float roughness: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float fingerprint_offset = 0;
uniform float fingerprint_scale = 1;
uniform float crack_offset = 0;
uniform float crack_scale = 1;
uniform float crack_detail_level = 0.5;

varying mat4 inv_modelview_matrix;
varying flat vec4 projected_coords;
varying flat vec3 normal_weights;

vec4 get_projected_coordinates(vec3 vertex) {
	return inv_modelview_matrix 
		* vec4(vertex, 1.0) 
		/ GLOBAL_SCALING;
}

vec3 get_normal_weights(vec3 normal) {
	vec3 world_normal = abs(inv_modelview_matrix * vec4(normal, 0.0)).xyz;
	return world_normal / (world_normal.x + world_normal.y + world_normal.z);
}

vec3 get_adjusted_normal(sampler2D tex, float scale, float offset) {
	vec4 uv = projected_coords * scale + offset;
	vec3 x = texture(tex, uv.zy).rgb;
	vec3 y = texture(tex, uv.xz).rgb;
	vec3 z = texture(tex, uv.xy).rgb;
	
	return x * normal_weights.x 
		+ y * normal_weights.y 
		+ z * normal_weights.z;
}

vec3 calculate_normals() {
	vec3 crack_base_normal = get_adjusted_normal(cracks, crack_scale, crack_offset);
	vec3 crack_detail_normal = get_adjusted_normal(crack_detail, crack_scale, crack_offset);
	vec3 crack_normal = crack_base_normal + crack_detail_normal * crack_detail_level;
	
	vec3 fingerprint_normal = get_adjusted_normal(fingerprints, fingerprint_scale, fingerprint_offset);
	return fingerprint_normal * crack_normal;
}