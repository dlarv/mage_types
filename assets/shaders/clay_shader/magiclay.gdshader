shader_type spatial;
#include "clay_lib.gdshaderinc"

global uniform vec4 element_b;
global uniform vec4 element_p;
global uniform vec4 element_m;
global uniform vec4 element_r;
global uniform vec4 element_o;
global uniform vec4 element_y;
global uniform vec4 element_g;
global uniform vec4 element_c;

uniform int element_id: hint_enum("Blue", "Purple", "Magenta", "Red", "Orange", "Yellow", "Green", "Cyan");

void vertex() {
	inv_modelview_matrix = inverse(MODELVIEW_MATRIX);
}

vec3 get_color() {
	switch(element_id) {
		case 0:
			return element_b.rgb;
		case 1:
			return element_p.rgb;
		case 2:
			return element_m.rgb;
		case 3:
			return element_r.rgb;
		case 4:
			return element_o.rgb;
		case 5:
			return element_y.rgb;
		case 6:
			return element_g.rgb;
		case 7:
			return element_c.rgb;
	}
}

void fragment() {
	normal_weights = get_normal_weights(NORMAL);
	projected_coords = get_projected_coordinates(VERTEX);
	
	ALBEDO = get_color();
	ROUGHNESS = roughness;
	NORMAL = calculate_normals();
	
	if(show_diffuse_test) {
		ALBEDO = get_adjusted_normal(diffuse_test, fingerprint_scale, fingerprint_offset);
	}
}
