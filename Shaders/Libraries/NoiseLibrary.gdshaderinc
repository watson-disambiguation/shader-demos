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

float perlinNoise3D(vec3 pos, float cellSize, float seed) {
	vec3 hashedSeed = hash31(seed);
	vec3 scaledPos = pos / cellSize;
	vec3[8] cornerPositions;
	float[8] dotProducts;
	vec3 floors = floor(scaledPos);
	vec3 ceils = ceil(scaledPos);
	for(int i = 0; i < 8; i++) {
		// calculated corner positions
		float x = mix(floors.x,ceils.x,float(i % 2));
		float y = mix(floors.y,ceils.y,clamp(float((i % 4)-1),0.,1.));
		float z = mix(floors.z,ceils.z,clamp(float(i-3),0.,1.));
		cornerPositions[i] = vec3(x,y,z) * cellSize;
		// get normalized vector from angles
		vec2 angles = hash23(cornerPositions[i] +hashedSeed);
		angles.x *= TAU;
		angles.y = angles.y * PI - (PI * 0.5);
		vec2 planeVector = vec2(cos(angles.x),sin(angles.x));
		vec3 cornerVector = vec3(planeVector * cos(angles.y),sin(angles.y));
		// calculate dot products
		vec3 pointVector = pos - cornerPositions[i] ;
		dotProducts[i] = dot(cornerVector,pointVector);
	}

	float smoothX = smoothstep(cornerPositions[0].x,cornerPositions[1].x,pos.x);
	float smoothY = smoothstep(cornerPositions[0].y,cornerPositions[2].y,pos.y);
	float smoothZ = smoothstep(cornerPositions[0].z,cornerPositions[4].z,pos.z);
	float interpX[4];
	for(int i = 0; i < 4; i++) {
		interpX[i] = mix(dotProducts[i*2],dotProducts[i*2+1],smoothX);
	}
	float interpYTop = mix(interpX[0],interpX[1],smoothY);
	float interpYBottom = mix(interpX[2],interpX[3],smoothY);
	//readjust based on cell size
	return clamp(2.*mix(interpYTop,interpYBottom ,smoothZ)/cellSize,-1,1);
	return 0.;
}

float perlinNoise3DOctaves(vec3 pos, float cellSize, float seed, int octaves) {
	float noiseValue = 0.;
	float currCellSize = cellSize;
	float currSeed = seed;
	float octaveSize = 1.; 
	for(int i = 1; i <= octaves; i++) {
		noiseValue += perlinNoise3D(pos,currCellSize*octaveSize,currSeed)*octaveSize;
		octaveSize /= 2.;
		currSeed = hash11(currSeed);
	}
	return noiseValue;
}
