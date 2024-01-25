shader_type spatial;
#include "Libraries/NoiseLibrary.gdshaderinc"

uniform float depth;
uniform float edge;
uniform float seed;
uniform float gridSize;
uniform int octaves;

void fragment() {
	vec3 pos = vec3(UV,depth);
	//float noiseVal = 0.5 * perlinNoise3DOctaves(pos,gridSize,seed,octaves) + 0.5;10
	ALBEDO = hash33(pos);
}
