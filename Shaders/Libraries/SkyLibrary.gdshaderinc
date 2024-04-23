#ifndef SKY_LIBRARY
#define SKY_LIBRARY

#include "Voronoi.gdshaderinc"

vec3 stars(vec3 dir , float starSpacing) {
	vec3 closestStar = voronoi(dir*starSpacing)/starSpacing;
	float strength = hash33(closestStar * starSpacing).x;
	return vec3(step(0.999999,dot(dir,normalize(closestStar))))*strength*strength;
}

#endif