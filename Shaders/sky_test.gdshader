shader_type sky;



#include "Libraries/SkyLibrary.gdshaderinc"

uniform float starSpacing;

void sky() {
	vec3 output = stars(EYEDIR,starSpacing);
	COLOR = output;
	
}
