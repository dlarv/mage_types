shader_type spatial;

const uvec3 GRAY_VALUES = uvec3(0x33, 0x7f, 0xFF);
const vec3 B_SHADES[3] = vec3[3](
	vec3(0x00,0x00,0x82), 
	vec3(0x00,0x00,0xDC), 
	vec3(0x00,0x00,0xFF)
);
const vec3 P_SHADES[3] = vec3[3](
	vec3(0x50,0x00,0x82), 
	vec3(0x7A,0x00,0xC5), 
	vec3(0x7F,0x00,0x7F)
);
const vec3 M_SHADES[3] = vec3[3](
	vec3(0xC9,0x00,0xC9), 
	vec3(0xD6,0x00,0xD6), 
	vec3(0xFF,0x00,0xFF)
);
const vec3 R_SHADES[3] = vec3[3](
	vec3(0x6D,0x00,0x00), 
	vec3(0xAB,0x00,0x00), 
	vec3(0xFF,0x00,0x00)
);
const vec3 O_SHADES[3] = vec3[3](
	vec3(0xAB,0x2E,0x00), 
	vec3(0xCF,0x37,0x00), 
	vec3(0xFF,0x44,0x33)
);
const vec3 Y_SHADES[3] = vec3[3](
	vec3(0xCC,0xCC,0x00), 
	vec3(0xFF,0xFF,0x4c), 
	vec3(0xC7,0xC7,0x3C)
);
const vec3 G_SHADES[3] = vec3[3](
	vec3(0x16,0x94,0x1C), 
	vec3(0x1F,0xCF,0x28),
	vec3(0x25,0xFF,0x30) 
);
const vec3 C_SHADES[3] = vec3[3](
	vec3(0x0E,0x81,0x81), 
	vec3(0x13,0xAD,0xAD), 
	vec3(0x1C,0xFF,0xFF)
);

uniform sampler2D diffuse_map;
uniform sampler2D normal_map;
uniform int element_id: hint_enum("BLUE", "PURPLE", "MAGENTA", "RED", "ORANGE", "YELLOW", "GREEN", "CYAN");

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

	NORMAL_MAP = texture(normal_map, UV).rgb;
}

