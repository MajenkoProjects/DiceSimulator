shader_type spatial;

uniform vec4 Color = vec4(0.9, 0, 0, 1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO.x = Color.r;
	ALBEDO.y = Color.g;
	ALBEDO.z = Color.b;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
