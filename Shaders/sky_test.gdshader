shader_type sky;



#include "Libraries/SkyLibrary.gdshaderinc"

uniform float starSpacing;
uniform float minFlickerPeriod;
uniform float maxFlickerPeriod;
uniform float lightThreshold;
uniform int seed;

void sky() {
	vec3 output = stars(seed,EYEDIR,starSpacing,minFlickerPeriod,maxFlickerPeriod);
	COLOR = output * smoothstep(vec3(lightThreshold/2.),vec3(lightThreshold),output);
	
}
