shader_type spatial;
#include "Libraries/NoiseLibrary.gdshaderinc"

uniform float seed;
uniform float gridSize;
uniform int octaves;

void fragment() {
	ALBEDO = vec3(0.5 * perlinNoise2DOctaves(UV,gridSize,seed,octaves) + 0.5);
}
