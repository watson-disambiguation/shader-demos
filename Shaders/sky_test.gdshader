shader_type sky;



#include "Libraries/SkyLibrary.gdshaderinc"

uniform float starSpacing;

void sky() {
	COLOR = stars(EYEDIR,starSpacing);
}
