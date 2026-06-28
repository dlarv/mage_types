shader_type spatial;
#include "clay_lib.gdshaderinc"

global uniform sampler2D wave_displacement;

uniform vec4 base_color: source_color = vec4(1, 1, 1, 1);
uniform float wave_intensity = 0.0;

varying float x;

float wave(vec2 pos) {
	pos += texture(wave_displacement, pos / 10.0).x * 2.0 - 1.0;
	vec2 wv = 1.0 - abs(sin(pos));
	return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);
}

float height(vec2 pos, float time) {
	float h = wave((pos + time) * .09) * 2.0;
	h += wave((pos - time) * .2) * 1.5;
	return h;
}

void vertex() {
	inv_modelview_matrix = inverse(MODELVIEW_MATRIX);
	//x = texture(wave_displacement, UV).z * wave_intensity;
	vec2 pos = VERTEX.xz;
	float k = height(pos, TIME / 1.0);
	VERTEX.y = k;
	NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
}

void fragment() {
	normal_weights = get_normal_weights(NORMAL);
	projected_coords = get_projected_coordinates(VERTEX);
	
	ALBEDO = base_color.rgb;
	ROUGHNESS = roughness;
	NORMAL = get_triplanar_normal_map();
	
	if(show_diffuse_test) {
		ALBEDO = get_adjusted_normal(diffuse_test, fingerprint_scale, fingerprint_offset);
	}
}
