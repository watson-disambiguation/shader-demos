shader_type spatial;
#include "Libraries/NoiseLibrary.gdshaderinc"

uniform float depth;
uniform float edge;
uniform float seed;
uniform float gridSize;
uniform int octaves;

void fragment() {
	float noiseVal = 0.5 * perlinNoise3DOctaves(vec3(UV,depth),gridSize,seed,octaves) + 0.5;
	ALBEDO = vec3(noiseVal);
}
