shader_type sky;

#include "Libraries/SkyLibrary.gdshaderinc"

void sky() {
	COLOR = vec3(stars(EYEDIR));
}
