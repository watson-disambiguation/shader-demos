#include "HashLibrary.gdshaderinc"


float perlinNoise2D(vec2 uv, float cellSize, float seed) {
	vec2 hashedSeed = hash21(seed);
	vec2 scaledUV = uv / cellSize;
	vec2[4] cornerPositions;
	float[4] dotProducts;
	cornerPositions[0] = floor(scaledUV) * cellSize; //top left
	cornerPositions[1] = vec2(ceil(scaledUV.x),floor(scaledUV.y)) * cellSize; // top right
	cornerPositions[2] = vec2(floor(scaledUV.x),ceil(scaledUV.y)) * cellSize; // bottom left
	cornerPositions[3] = ceil(scaledUV) * cellSize; // bottom right
	for(int i = 0; i < 4; i++) {
		float angle = hash12(cornerPositions[i]+hashedSeed) * TAU;
		vec2 cornerVector = vec2(cos(angle),sin(angle));
		vec2 pointVector = uv - cornerPositions[i];
		dotProducts[i] = dot(cornerVector,pointVector);
	}
	float smoothX = smoothstep(cornerPositions[0].x,cornerPositions[1].x,uv.x);
	float smoothY = smoothstep(cornerPositions[0].y,cornerPositions[2].y,uv.y);
	float topEdge = dotProducts[0] + smoothX * (dotProducts[1]-dotProducts[0]);
	float bottomEdge = dotProducts[2] + smoothX * (dotProducts[3]-dotProducts[2]);
	// readjust based on cell size
	return clamp(2.*mix(topEdge,bottomEdge,smoothY)/cellSize,-1,1);
}

float perlinNoise2DOctaves(vec2 uv, float cellSize, float seed, int octaves) {
	float noiseValue = 0.;
	uint power = 1u;
	float currCellSize = cellSize;
	float currSeed = seed;
	float octaveSize = 1.; 
	for(int i = 1; i <= octaves; i++) {
		noiseValue += perlinNoise2D(uv,currCellSize*octaveSize,currSeed)*octaveSize;
		octaveSize /= 2.;
		currSeed = hash11(currSeed);
	}
	return noiseValue;
}

