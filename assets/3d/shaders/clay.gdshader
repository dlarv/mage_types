shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform sampler2D finger_print_image;
uniform sampler2D finger_impressions_image;

uniform vec3 base_color: source_color;
uniform vec3 finger_color: source_color;
uniform float finger_color_intensity;

uniform float global_scale;
uniform float finger_scale;
uniform float finger_impressions;
uniform float finger_prints;
void color_ramp(float fac, vec2 mulbias, vec4 color1, vec4 color2, out vec4 outcol, out float outalpha)
{
  fac = clamp(fac * mulbias.x + mulbias.y, 0.0f, 1.0f);
  fac = fac * fac * (3.0f - 2.0f * fac);
  outcol = mix(color1, color2, fac);
  outalpha = outcol.a;
}

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX += NORMAL * texture(finger_impressions_image, UV).xyz * finger_scale / 15.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(.5, .6, .5);
	vec3 finger = texture(finger_print_image, UV).xyz;
	ALBEDO *= finger;
}



