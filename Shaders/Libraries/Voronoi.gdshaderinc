#ifndef VORONOI
#define VORONOI
#include "HashLibrary.gdshaderinc"

vec3 voronoi(vec3 pos) {
	vec3 center = floor(pos);
	vec3 cells[27];
	cells[0] = center;
	cells[1] = center + vec3(0,0,1);
	cells[2] = center + vec3(0,1,0);
	cells[3] = center + vec3(0,1,1);
	cells[4] = center + vec3(1,0,0);
	cells[5] = center + vec3(1,0,1);
	cells[6] = center + vec3(1,1,0);
	cells[7] = center + vec3(1,1,1);
	cells[8] = center + vec3(0,0,-1);
	cells[9] = center + vec3(0,1,-1);
	cells[10] = center + vec3(1,0,-1);
	cells[11] = center + vec3(1,1,-1);
	cells[12] = center + vec3(0,-1,0);
	cells[13] = center + vec3(0,-1,1);
	cells[14] = center + vec3(1,-1,0);
	cells[15] = center + vec3(1,-1,1);
	cells[16] = center + vec3(0,-1,-1);
	cells[17] = center + vec3(1,-1,-1);
	cells[18] = center + vec3(-1,0,0);
	cells[19] = center + vec3(-1,0,1);
	cells[20] = center + vec3(-1,1,0);
	cells[21] = center + vec3(-1,1,1);
	cells[22] = center + vec3(-1,0,-1);
	cells[23] = center + vec3(-1,1,-1);
	cells[24] = center + vec3(-1,-1,0);
	cells[25] = center + vec3(-1,-1,1);
	cells[26] = center + vec3(-1,-1,-1);
	float minDist = 2.;
	vec3 closestPos = vec3(0);
	for(int i = 0; i < 27; i++) {
		vec3 cellHash = hash33(cells[i]) + cells[i];
		vec3 seperation = pos - cellHash;
		float sqrDist = dot(seperation,seperation);
		if(sqrDist < minDist) {
			minDist = sqrDist;
			closestPos = cellHash;
		}
	}
	return closestPos;
}
#endif