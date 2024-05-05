#ifndef SKY_LIBRARY
#define SKY_LIBRARY

#include "Voronoi.gdshaderinc"

vec3 stars(int seed,vec3 dir, float starSpacing, float minFlickerPeriod,float maxFlickerPeriod,float lightThreshold) {
	vec3 seedOffset = vec3(float(seed));
	vec3 closestStar = voronoi((dir+seedOffset)*starSpacing)/starSpacing-seedOffset;
	vec3 starHash = hash33(closestStar * starSpacing);
	float strength = starHash.x;
	float phaseOffset = starHash.y;
	float period = mix(minFlickerPeriod,maxFlickerPeriod,starHash.z);
	strength = strength - 0.5 * strength * (1. + sin(TIME/period+phaseOffset));
	float starProximity = dot(dir,normalize(closestStar));
	float star = smoothstep(13,14.,-log(1.-starProximity));
	vec3 output = vec3(star * strength);
	return output * smoothstep(vec3(lightThreshold/2.),vec3(lightThreshold),output);
}

#endif