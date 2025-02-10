shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform sampler2D noise;
varying vec4 tex;
varying vec3 normal;

void vertex() {
	// Called for every vertex the material is visible on.
	normal = normalize(NORMAL);
	tex = texture(noise, VERTEX.xz);
	VERTEX.y += tex.y * NORMAL.y / 100.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
	if(normal.y > 0.5) {
		ALBEDO = vec3(0, 0, 0.8);
	} else {
		ALBEDO = vec3(0, 0, 0.2);
	}
	ALBEDO = vec3(0, 0, .5 * normal.y * (tex.y + 0.5));
	//ALBEDO = tex.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
