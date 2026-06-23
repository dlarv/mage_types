// Inverted-hull outline pass
// https://godotshaders.com/shader/inverted-hull-outline-with-group-merge/
shader_type spatial;
render_mode cull_front, unshaded, blend_mix, depth_draw_opaque, shadows_disabled;

struct Element {
	vec4 outline_color;
	float thickness_mod;
};

const float DEFAULT_THICKNESS = .11;

global uniform vec4 element_b;
global uniform vec4 element_p;
global uniform vec4 element_m;
global uniform vec4 element_r;
global uniform vec4 element_o;
global uniform vec4 element_y;
global uniform vec4 element_g;
global uniform vec4 element_c;
global uniform int magiclay_effect_mode;

group_uniforms Outline;
uniform float thickness : hint_range(0.0, 0.3) = 0.04;   // view-space units
uniform float outline_energy : hint_range(0.0, 4.0) = 1.0; // brightness: 0 dark, 1 full, >1 blooms

group_uniforms ElementalEffects;
uniform int element_id: hint_enum("Blue", "Purple", "Magenta", "Red", "Orange", "Yellow", "Green", "Cyan", "Blank");
uniform sampler3D random_noise;
uniform sampler3D orange_noise;
uniform sampler3D purple_noise;
uniform float p_color_mod = 0.3;
uniform sampler3D magenta_noise;
uniform float red_pulse_amount = 0.02;
uniform float red_pulse_speed = 2.0;
uniform float m_speed_damp = 7.0;
uniform float m_bright_offset = 0.2;
uniform float o_speed_damp = 15.0;
uniform float c_thickness_mod = 35.0;
uniform float g_pulse_amount = 50.0;
uniform float g_fade_damp = 1.5;
uniform float g_color_mod = 0.1;
uniform float c_bright_offset = 0.6;

// view-space z of the (expanded) outline vertex
varying float v_view_z;   
varying flat vec4 haze_color;

Element get_fancy_effect(float time, vec3 vertex) {
	Element e;
	e.thickness_mod = DEFAULT_THICKNESS;
	
	switch(element_id) {
		case 0: // blue
			e.outline_color = element_b;
			break;
		case 1: // purple
			vec3 uv = vertex - time;
			e.outline_color = texture(purple_noise, uv) 
				* element_p
				* vec4(vec3(p_color_mod), 1.0);
			e.thickness_mod *= 2.0;
			break;
		case 2: // magenta
			vec3 uv = vertex - time/m_speed_damp;
			e.outline_color = m_bright_offset
				+ element_m 
				* texture(magenta_noise, uv);
			e.thickness_mod *= 3.0;
			break;
		case 3: // red
			float t = red_pulse_speed * time;
			e.thickness_mod = red_pulse_amount * sin(t) + 0.1;
			e.outline_color = vec4(
				element_r.rgb * max(0.7, sin(t)), 
				1.0
			);
			break;
		case 4: // orange
			vec3 uv = vertex + time/o_speed_damp;
			e.thickness_mod = DEFAULT_THICKNESS * 3.0;
			e.outline_color = element_o 
				* texture(orange_noise, uv);
			break;
		case 5: // yellow
			vec3 uv = vertex - time;
			vec4 a = texture(purple_noise, uv);
			vec4 b = texture(orange_noise, uv);
			e.outline_color =  element_y * (a + b);
			e.thickness_mod *= 1.0;
			break;
		case 6: // green
			float t = mod(time, g_fade_damp);
			float reps = g_fade_damp * .5;
			e.thickness_mod = DEFAULT_THICKNESS*2.0;
			e.outline_color = t > reps ? vec4(element_g.rgb * g_color_mod,1.0) : element_g;
			break;
		case 7: // cyan
			e.outline_color = vec4(element_c.rgb + c_bright_offset, 0.1);
			e.thickness_mod *= c_thickness_mod;
			break;
		default: // blank
			e.outline_color = vec4(1.0);
			e.thickness_mod = .01;
			break;
	}
	
	return e;
}

Element get_solid_border_effect() {
	Element e;
	e.thickness_mod = DEFAULT_THICKNESS;
	switch(element_id) {
		case 0: // blue
			e.outline_color = element_b;
			break;
		case 1: // purple
			e.outline_color = element_p;
			break;
		case 2: // magenta
			e.outline_color = element_m;
			break;
		case 3: // red
			e.outline_color = element_r;
			break;
		case 4: // orange
			e.outline_color = element_o; 
			break;
		case 5: // yellow
			e.outline_color =  element_y;
			break;
		case 6: // green
			e.outline_color = element_g;
			break;
		case 7: // cyan
			e.outline_color = element_c;
			break;
		default: // blank
			e.outline_color = vec4(1.0);
			e.thickness_mod = .01;
			break;
	}
	return e;
}

vec4 calculate_border(vec3 vertex, mat4 modelview, float adjusted_thickness) {
	if(magiclay_effect_mode == 2) { return vec4(0.0); }
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
	Element e;
	float time_offset = TIME + (2.0 * texture(random_noise, VERTEX).r - 1.0);

	switch(magiclay_effect_mode) {
		case 0:
			e = get_fancy_effect(time_offset, VERTEX);
			break;
		case 1:
			e = get_solid_border_effect();
			break;
		case 2:
			e.outline_color = vec4(0.0);
			break;
	}
	
	haze_color = e.outline_color;
	
	float adjusted_thickness = haze_color.a * e.thickness_mod;
	vec4 view_pos = calculate_border(VERTEX, MODELVIEW_MATRIX, adjusted_thickness);
	
	v_view_z = view_pos.z;
	POSITION = PROJECTION_MATRIX * view_pos * time_offset;
}



void fragment() {
	// Unshaded: ALBEDO is the final colour (EMISSION is ignored in unshaded mode).
	// outline_energy scales it; values >1 bloom via the HDR colour buffer.
	// outline_transparency = true alpha mix with whatever is behind it (object or sky).
	ALPHA = haze_color.a;
	ALBEDO = outline_energy * haze_color.rgb;
}
