shader_type spatial;
uniform sampler2D normalmap;
uniform sampler2D diffusemap;
varying vec2 tex_position;

void vertex() {
	// Called for every vertex the material is visible on.
	tex_position = VERTEX.xy;
	//float height = texture(noise, tex_position).x;
}

void fragment() {
	// Called for every pixel the material is visible on.
	//NORMAL_MAP = texture(normalmap, tex_position).xyz;
	//ALBEDO = texture(diffusemap, tex_position).xyz;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
