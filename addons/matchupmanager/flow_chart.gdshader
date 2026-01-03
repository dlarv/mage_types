shader_type canvas_item;

const int B_NODE = 0x0442b5;
const int P_NODE = 0x6e5db7;
const int M_NODE = 0xb350b4;
const int R_NODE = 0xbb1a00;
const int O_NODE = 0xb96206;
const int Y_NODE = 0xb2ab3d;
const int G_NODE = 0x47ae20;
const int C_NODE = 0x5cafb0;

const int B_EDGE = 0x1b48bd;
const int P_EDGE = 0x7362bd;
const int M_EDGE = 0xb955ba;
const int R_EDGE = 0xc12205;
const int O_EDGE = 0xbe6913;
const int Y_EDGE = 0xb8b042;
const int G_EDGE = 0x4db427;
const int C_EDGE = 0x62b4b5;

uniform bool HIDE_B_NODE = false;
uniform bool HIDE_P_NODE = false;
uniform bool HIDE_M_NODE = false;
uniform bool HIDE_R_NODE = false;
uniform bool HIDE_O_NODE = false;
uniform bool HIDE_Y_NODE = false;
uniform bool HIDE_G_NODE = false;
uniform bool HIDE_C_NODE = false;

uniform bool HIDE_B_EDGE = false;
uniform bool HIDE_P_EDGE = false;
uniform bool HIDE_M_EDGE = false;
uniform bool HIDE_R_EDGE = false;
uniform bool HIDE_O_EDGE = false;
uniform bool HIDE_Y_EDGE = false;
uniform bool HIDE_G_EDGE = false;
uniform bool HIDE_C_EDGE = false;

bool _is_orphan(float alpha) {
	if(alpha >= .99 && alpha <= 1.0) { return false; }
	switch(int(alpha * 255.0)) {
		case 0xFC:
			return HIDE_B_NODE || HIDE_C_NODE;
		case 0xFA:
			return HIDE_P_NODE || HIDE_C_NODE;
		case 0xF7:
			return HIDE_B_NODE || HIDE_P_NODE;
		case 0xF5:
			return HIDE_B_NODE || HIDE_M_NODE;
		case 0xF2:
			return HIDE_P_NODE || HIDE_M_NODE;
		case 0xF0:
			return HIDE_P_NODE || HIDE_O_NODE;
		case 0xED:
			return HIDE_M_NODE || HIDE_O_NODE;
		case 0xEB:
			return HIDE_M_NODE || HIDE_R_NODE;
		case 0xE8:
			return HIDE_O_NODE || HIDE_R_NODE;
		case 0xE5:
			return HIDE_O_NODE || HIDE_Y_NODE;
		case 0xE3:
			return HIDE_R_NODE || HIDE_Y_NODE;
		case 0xE0:
			return HIDE_G_NODE || HIDE_Y_NODE;
		case 0xDE:
			return HIDE_G_NODE || HIDE_C_NODE;
		case 0xDB:
			return HIDE_O_NODE || HIDE_G_NODE;
		default:
			return true;
	}
}

bool _find_closest(int r, int g, int b, float a) {
	int threshold = 0xA0;

	if(r >= threshold && g >= threshold) {
		return HIDE_Y_EDGE;
	} else if(r >= threshold && b >= threshold) {
		return HIDE_M_EDGE;
	} else if(r >= threshold && g >= threshold / 2) {
		return HIDE_O_EDGE;
	} else if(b >= threshold && g >= threshold) {
		return HIDE_C_EDGE;
	} else if(b >= threshold && r >= threshold / 2) {
		return HIDE_P_EDGE;
	} else if(b >= threshold) {
		return HIDE_B_EDGE;
	} else if(g >= threshold) {
		return HIDE_G_EDGE;
	} else if(r >= threshold) {
		return HIDE_R_EDGE;
	} else {
		return false;
	}
}

bool _is_restricted(vec4 pixel) {
	if(pixel.a <= 0.2) { return false; }

	int r = int(pixel.r * 255.0);
	int g = int(pixel.g * 255.0);
	int b = int(pixel.b * 255.0);
	int val = r * 0x10000 + g * 0x100 + b;

	switch(val) {
		case B_NODE:
			return HIDE_B_NODE;
		case P_NODE:
			return HIDE_P_NODE;
		case M_NODE:
			return HIDE_M_NODE;
		case R_NODE:
			return HIDE_R_NODE;
		case O_NODE:
			return HIDE_O_NODE;
		case Y_NODE:
			return HIDE_Y_NODE;
		case G_NODE:
			return HIDE_G_NODE;
		case C_NODE:
			return HIDE_C_NODE;
		case B_EDGE:
			return HIDE_B_EDGE;
		case P_EDGE:
			return HIDE_P_EDGE;
		case M_EDGE:
			return HIDE_M_EDGE;
		case R_EDGE:
			return HIDE_R_EDGE;
		case O_EDGE:
			return HIDE_O_EDGE;
		case Y_EDGE:
			return HIDE_Y_EDGE;
		case G_EDGE:
			return HIDE_G_EDGE;
		case C_EDGE:
			return HIDE_C_EDGE;
		default:
			return _find_closest(r, g, b, pixel.a);
	}
}

void fragment() {
	//COLOR.a = float(!_is_orphan(COLOR.a, COLOR));
	//COLOR.a = float(!_is_restricted(COLOR));
	COLOR.a = float(!_is_restricted(COLOR)) * float(!_is_orphan(COLOR.a));
}
