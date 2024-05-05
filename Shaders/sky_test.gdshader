shader_type sky;



#include "Libraries/SkyLibrary.gdshaderinc"

uniform float starSpacing;
uniform float minFlickerPeriod;
uniform float maxFlickerPeriod;
uniform float lightThreshold;
uniform int seed;

void sky() {
	COLOR = stars(seed,EYEDIR,starSpacing,minFlickerPeriod,maxFlickerPeriod,lightThreshold);
	
}
