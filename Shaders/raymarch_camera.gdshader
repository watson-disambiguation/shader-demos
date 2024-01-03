shader_type spatial;

render_mode unshaded;

#include "Libraries/SDFLibrary.gdshaderinc"

uniform float nearFogBlend;
uniform float farFogBlend;
uniform vec3 skyColour : source_color;
uniform vec3 objColour : source_color;

const int maxSteps = 128;
const float EPS = 0.000001;

float sdf(vec3 pos) {
	pos = pos - round(pos);
	return sphere(pos, 0.1);
}

void fragment() {
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = -normalize( (INV_VIEW_MATRIX * vec4(VIEW,0)).xyz );
	vec3 curPos = ro;
	float sample = 1.;
	vec3 finalPos = ro;
	bool hit = false;
	for(int i = 0; i < 128; i++) {
		sample = sdf(curPos);
		if(sample < EPS) {
			finalPos = curPos;
			hit = true;
			break;
		}
		vec3 rayStep = rd * sample;
		curPos += rayStep;
	}
	
	vec3 col = hit ? objColour : skyColour;
	float dist = length(ro - finalPos);
	col = mix(col,skyColour,smoothstep(nearFogBlend,farFogBlend,dist));
	ALBEDO = col;
	
	
}
