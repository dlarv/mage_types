shader_type spatial;

uniform sampler2D diffuse_map: source_color;
uniform sampler2D normal_map;
uniform sampler2D rough_map;
uniform sampler2D element_map;
uniform vec4 color_1: source_color;
uniform vec4 color_2: source_color;

void fragment() {
	NORMAL_MAP = texture(normal_map, UV).xyz;
	ROUGHNESS = texture(rough_map, UV).x;
	
	vec3 primary = (texture(element_map, UV).r * color_1).rgb;
	vec3 secondary = (texture(element_map, UV).g * color_2).rgb;
	vec3 diffuse = texture(element_map, UV).b * texture(diffuse_map, UV).rgb;
	ALBEDO = diffuse + primary + secondary;
}
