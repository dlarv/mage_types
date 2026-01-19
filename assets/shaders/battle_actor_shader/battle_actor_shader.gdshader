shader_type spatial;

const uvec3 GRAY_VALUES = uvec3(0x33, 0x7f, 0xFF);
const vec3 B_SHADES[3] = vec3[3](vec3(0x00,0x00,0x7F), vec3(0x00,0x00,0xDC), vec3(0x47,0x47,0xFF));
const vec3 P_SHADES[3] = vec3[3](vec3(0x19,0x00,0x29), vec3(0x7A,0x00,0xC5), vec3(0x97,0x00,0xF5));
const vec3 M_SHADES[3] = vec3[3](vec3(0xB8,0x00,0xB8), vec3(0xFF,0x20,0xFF), vec3(0xFF,0x47,0xFF));
const vec3 R_SHADES[3] = vec3[3](vec3(0x3D,0x00,0x00), vec3(0xAB,0x00,0x00), vec3(0xF5,0x00,0x00));
const vec3 O_SHADES[3] = vec3[3](vec3(0x7A,0x21,0x00), vec3(0xFF,0x44,0x00), vec3(0xFF,0x69,0x33));
const vec3 Y_SHADES[3] = vec3[3](vec3(0xCC,0xCC,0x00), vec3(0xFF,0xFF,0x4c), vec3(0xFF,0xFF,0x70));
const vec3 G_SHADES[3] = vec3[3](vec3(0x00,0x7A,0x06), vec3(0x25,0xFF,0x30), vec3(0xFC,0xFF,0x64));
const vec3 C_SHADES[3] = vec3[3](vec3(0x08,0x49,0x49), vec3(0x0E,0x81,0x81), vec3(0x20,0xE6,0xE6));

uniform sampler2D diffuse_map;
uniform int element_id: hint_enum("BLUE", "PURPLE", "MAGENTA", "RED", "ORANGE", "YELLOW", "GREEN", "CYAN");

void vertex() {
	// Called for every vertex the material is visible on.
}

vec3 select_shade(uint value, vec3[3] shades) {
	if(value <= GRAY_VALUES.r) {
		return shades[0];
	} else if(value <= GRAY_VALUES.g) {
		return shades[1];
	} else {
		return shades[2];
	}
}

void fragment() {
	vec4 tex = texture(diffuse_map, UV);
	uint sel = uint(tex.r * 255.0);
	switch(element_id) {
		case 0:
			ALBEDO = select_shade(sel, B_SHADES) / 255.0;
			break;
		case 1:
			ALBEDO = select_shade(sel, P_SHADES) / 255.0;
			break;
		case 2:
			ALBEDO = select_shade(sel, M_SHADES) / 255.0;
			break;
		case 3:
			ALBEDO = select_shade(sel, R_SHADES) / 255.0;
			break;
		case 4:
			ALBEDO = select_shade(sel, O_SHADES) / 255.0;
			break;
		case 5:
			ALBEDO = select_shade(sel, Y_SHADES) / 255.0;
			break;
		case 6:
			ALBEDO = select_shade(sel, G_SHADES) / 255.0;
			break;
		case 7:
			ALBEDO = select_shade(sel, C_SHADES) / 255.0;
			break;
		default:
			ALBEDO = tex.rgb;
			break;
	}

}

