shader_type spatial;
uniform sampler2D diffuse;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	//vec4 color = texture(diffuse, UV);
	//
	//if(color.r >= 0.5) {
		//ALBEDO = vec3(1, 0, 0);
	//} else {
		//ALBEDO = vec3(0, 0, 0);
	//}
	//ALBEDO = color.rgb;

	ALPHA = 0.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
