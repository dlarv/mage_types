shader_type spatial;
#include "clay_lib.gdshaderinc"

uniform vec4 base_color: source_color = vec4(1, 1, 1, 1);

void vertex() {
	inv_modelview_matrix = inverse(MODELVIEW_MATRIX);
}

void fragment() {
	normal_weights = get_normal_weights(NORMAL);
	projected_coords = get_projected_coordinates(VERTEX);
	
	ALBEDO = base_color.rgb;
	ROUGHNESS = roughness;
	NORMAL_MAP = get_triplanar_normal_map();
	
	if(show_diffuse_test) {
		ALBEDO = get_adjusted_normal(diffuse_test, fingerprint_scale, fingerprint_offset);
	}
}
