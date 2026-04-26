shader_type spatial;

const float GLOBAL_SCALING = 10.0;

global uniform sampler2D fingerprints;
global uniform sampler2D cracks;
global uniform sampler2D crack_detail;

uniform vec4 base_color: source_color = vec4(1, 1, 1, 1);
uniform float roughness: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform vec2 uv_scale = vec2(1, 1);
uniform float fingerprint_offset = 0;
uniform float fingerprint_scale: hint_range(0.0, 1.0, 0.1) = 1;
uniform float crack_offset = 0;
uniform float crack_scale: hint_range(0.0, 1.0, 0.1) = 1;
uniform float crack_detail_level: hint_range(0.0, 1.0, 0.1) = 0.5;

varying mat4 inv_modelview_matrix;

void vertex() {
	// Called for every vertex the material is visible on.
	inv_modelview_matrix = inverse(MODELVIEW_MATRIX);
}

vec3 get_triplanar(vec4 coords, sampler2D tex, vec3 weights) {
	vec3 x = texture(tex, coords.zy).rgb;
	vec3 y = texture(tex, coords.xz).rgb;
	vec3 z = texture(tex, coords.xy).rgb;
	return x * weights.x + y * weights.y + z * weights.z;
}

void fragment() {
	ALBEDO = base_color.rgb;
	ROUGHNESS = roughness;
	
	// Must be neg, otherwise normals are inverted
	vec4 proj_coords = (inv_modelview_matrix * vec4(VERTEX, 1.0) / GLOBAL_SCALING);
	vec3 world_normal = abs(inv_modelview_matrix * vec4(NORMAL, 0.0)).xyz;
	vec3 normal_weights = world_normal / (world_normal.x + world_normal.y + world_normal.z);
	
	vec4 crack_uv = proj_coords * crack_scale + crack_offset;
	vec3 crack_base_normal = get_triplanar(crack_uv, cracks, normal_weights);
	vec3 crack_detail_normal = get_triplanar(crack_uv, crack_detail, normal_weights);
	vec3 crack_normal = crack_base_normal + crack_detail_normal * crack_detail_level;
	
	vec4 fingerprint_uv = proj_coords * fingerprint_scale + fingerprint_offset;
	vec3 fingerprint_normal = get_triplanar(fingerprint_uv, fingerprints, normal_weights);
	NORMAL = fingerprint_normal * crack_normal;
}
