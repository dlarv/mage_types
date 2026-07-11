// NOTE: Shader automatically converted from Godot Engine 4.6.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

global uniform vec4 element_b;
global uniform vec4 element_p;
global uniform vec4 element_m;
global uniform vec4 element_r;
global uniform vec4 element_o;
global uniform vec4 element_y;
global uniform vec4 element_g;
global uniform vec4 element_c;

uniform int element_id: hint_enum("Blue", "Purple", "Magenta", "Red", "Orange", "Yellow", "Green", "Cyan", "Blank") = 8;

uniform float roughness : hint_range(0.0, 1.0);

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

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
		case 8:
			return vec3(0.5);
	}
}
void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

	ALBEDO = get_color();
	METALLIC = metallic;
	SPECULAR = specular;

	ROUGHNESS = roughness;
}
