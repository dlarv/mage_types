shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
;
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float dot2(vec2 x) {
	return dot(x, x);
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
float param_rndi(float minimum, float maximum, float seed) {
	return floor(param_rnd(minimum, maximum + 1.0, seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
const vec4 p_o546534596035_albedo_color = vec4(0.601562500, 0.075195312, 0.075195312, 1.000000000);
const float p_o546534596035_metallic = 0.000000000;
const float p_o546534596035_roughness = 1.000000000;
const float p_o546534596035_emission_energy = 1.000000000;
const float p_o546534596035_normal = 1.000000000;
const float p_o546534596035_ao = 1.000000000;
const float p_o546534596035_depth_scale = 0.450000000;
const float p_o547188907714_amount = 1.000000000;
const float p_o547088244171_d_in1_x = 0.000000000;
const float p_o547088244171_d_in1_y = 0.000000000;
const float p_o547088244171_d_in1_z = 0.000000000;
const float p_o547088244171_d_in2_x = 0.000000000;
const float p_o547088244171_d_in2_y = 0.000000000;
const float p_o547088244171_d_in2_z = 0.000000000;
const float p_o548430421813_d_in1_x = 0.000000000;
const float p_o548430421813_d_in1_y = 0.000000000;
const float p_o548430421813_d_in1_z = 0.000000000;
const float p_o548430421813_d_in2_x = 0.000000000;
const float p_o548430421813_d_in2_y = 0.000000000;
const float p_o548430421813_d_in2_z = 0.000000000;
const float p_o548463976247_color = 1.770000000;
uniform sampler2D texture_1;
uniform sampler2D texture_2;
// #globals: math_v3 (o547088244171)
float o547188907714_input_in(vec2 uv, float _seed_variation_) {
// #output0: uniform_greyscale_3 (o548463976247)
float o548463976247_0_1_f = p_o548463976247_color;
// #output0: combine_2 (o548447199030)
vec4 o548447199030_0_1_rgba = vec4(o548463976247_0_1_f, o548463976247_0_1_f, o548463976247_0_1_f, 1.0);
vec4 o546551373247_0 = textureLod(texture_1, mod((uv), 1.0), 0.0);
// #code: math_v3_8 (o548430421813)
vec3 o548430421813_0_clamp_false = pow(((o546551373247_0).rgb),((o548447199030_0_1_rgba).rgb));
vec3 o548430421813_0_clamp_true = clamp(o548430421813_0_clamp_false, vec3(0.0), vec3(1.0));
// #output0: math_v3_8 (o548430421813)
vec3 o548430421813_0_1_rgb = o548430421813_0_clamp_false;
vec4 o546819808709_0 = textureLod(texture_2, mod((uv), 1.0), 0.0);
// #code: math_v3 (o547088244171)
vec3 o547088244171_0_clamp_false = ((o546819808709_0).rgb)*o548430421813_0_1_rgb;
vec3 o547088244171_0_clamp_true = clamp(o547088244171_0_clamp_false, vec3(0.0), vec3(1.0));
// #output0: math_v3 (o547088244171)
vec3 o547088244171_0_1_rgb = o547088244171_0_clamp_false;
return (dot(o547088244171_0_1_rgb, vec3(1.0))/3.0);
}
// #instance: normal_map2/edge_detect_1 (o547188907714)
vec3 nm_o547188907714(vec2 uv, float amount, float size, float _seed_variation_) {
	vec3 e = vec3(1.0/size, -1.0/size, 0);
	vec2 rv;
	if (0 == 0) {
		rv = vec2(1.0, -1.0)*o547188907714_input_in((uv+e.xy), _seed_variation_);
		rv += vec2(-1.0, 1.0)*o547188907714_input_in((uv-e.xy), _seed_variation_);
		rv += vec2(1.0, 1.0)*o547188907714_input_in((uv+e.xx), _seed_variation_);
		rv += vec2(-1.0, -1.0)*o547188907714_input_in((uv-e.xx), _seed_variation_);
		rv += vec2(2.0, 0.0)*o547188907714_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(-2.0, 0.0)*o547188907714_input_in((uv-e.xz), _seed_variation_);
		rv += vec2(0.0, 2.0)*o547188907714_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(0.0, -2.0)*o547188907714_input_in((uv-e.zx), _seed_variation_);
		rv *= size*amount/128.0;
	} else if (0 == 1) {
		rv = vec2(3.0, -3.0)*o547188907714_input_in((uv+e.xy), _seed_variation_);
		rv += vec2(-3.0, 3.0)*o547188907714_input_in((uv-e.xy), _seed_variation_);
		rv += vec2(3.0, 3.0)*o547188907714_input_in((uv+e.xx), _seed_variation_);
		rv += vec2(-3.0, -3.0)*o547188907714_input_in((uv-e.xx), _seed_variation_);
		rv += vec2(10.0, 0.0)*o547188907714_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(-10.0, 0.0)*o547188907714_input_in((uv-e.xz), _seed_variation_);
		rv += vec2(0.0, 10.0)*o547188907714_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(0.0, -10.0)*o547188907714_input_in((uv-e.zx), _seed_variation_);
		rv *= size*amount/512.0;
	} else if (0 == 2) {
		rv = vec2(2.0, 0.0)*o547188907714_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(-2.0, 0.0)*o547188907714_input_in((uv-e.xz), _seed_variation_);
		rv += vec2(0.0, 2.0)*o547188907714_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(0.0, -2.0)*o547188907714_input_in((uv-e.zx), _seed_variation_);
		rv *= size*amount/64.0;
	} else {
		rv = vec2(1.0, 0.0)*o547188907714_input_in((uv+e.xz), _seed_variation_);
		rv += vec2(0.0, 1.0)*o547188907714_input_in((uv+e.zx), _seed_variation_);
		rv += vec2(-1.0, -1.0)*o547188907714_input_in((uv), _seed_variation_);
		rv *= size*amount/20.0;
	}
	return vec3(0.5)+0.5*normalize(vec3(rv, -1.0));
}
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);

// #output0: normal_map2/edge_detect_1 (o547188907714)
vec3 o547188907714_0_1_rgb = nm_o547188907714((uv), p_o547188907714_amount, 4096.0, _seed_variation_);

	vec3 albedo_tex = o547188907714_0_1_rgb.rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*p_o546534596035_albedo_color.rgb;
	METALLIC = 1.0*p_o546534596035_metallic;
	ROUGHNESS = 1.0*p_o546534596035_roughness;
	NORMAL = vec3(0.5);
	EMISSION = vec3(0.0)*p_o546534596035_emission_energy;
}
