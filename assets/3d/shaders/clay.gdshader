shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform sampler2D PRINTS;
uniform sampler2D IMPRESSIONS;
uniform sampler2D NOISE;

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
vec3 cracks(vec3 noise_coord) {
	noise_coord -= vec3(0.7);
	noise_coord *= noise_coord;
	float a = pow(noise_coord.r, noise_coord.g);
	float b = pow(noise_coord.g, noise_coord.b);
	float c = pow(noise_coord.r, noise_coord.b);
	return vec3(a, b, c);
}
void vertex() {
	// Called for every vertex the material is visible on.
	NORMAL += NORMAL 
			* texture(IMPRESSIONS, UV).xyz
			* texture(PRINTS, UV).xyz
			* finger_scale;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(.5, .6, .5);
	vec3 finger = texture(PRINTS, UV).xyz;
	ALBEDO = finger;
	
	//ALBEDO = cracks(texture(NOISE, UV).xyz);
}



