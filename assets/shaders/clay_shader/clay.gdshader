shader_type spatial;

global uniform sampler2D fingerprints;
global uniform sampler2D cracks;
global uniform sampler2D crack_detail;

uniform vec4 base_color: source_color = vec4(1, 1, 1, 1);
uniform float roughness = 1.0;
uniform vec2 uv_scale = vec2(1, 1);
uniform float fingerprint_offset = 0;
uniform float fingerprint_scale = 1;
uniform float crack_offset = 0;
uniform float crack_scale = 1;
uniform float crack_detail_level = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = base_color.rgb;
	ROUGHNESS = roughness;
	
	vec2 scaled_uv = uv_scale * UV;
	vec2 crack_uv = (scaled_uv + crack_offset) * crack_scale;
	vec2 fingerprint_uv = (scaled_uv + fingerprint_offset) * fingerprint_scale;
	
	vec3 crack_base_normal = texture(cracks, crack_uv).xyz;
	vec3 crack_detail_normal = texture(crack_detail, crack_uv).xyz * crack_detail_level;
	vec3 crack_normal = crack_base_normal + crack_detail_normal;
	
	vec3 fingerprint_normal = texture(fingerprints, fingerprint_uv).xyz;
	
	NORMAL = fingerprint_normal * crack_normal;
}
