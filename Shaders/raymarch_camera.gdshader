shader_type spatial;

render_mode unshaded;

#include "Libraries/SDFLibrary.gdshaderinc"
#include "Libraries/NoiseLibrary.gdshaderinc"

uniform float nearFogBlend;
uniform float farFogBlend;
uniform float radius;
uniform vec3 brightColour : source_color;
uniform vec3 darkColour : source_color;
uniform vec3 objColour : source_color;

const int maxSteps = 128;
const float EPS = 0.0001;



float sdf(vec3 pos) {
	pos = pos - 0.5;
	pos = pos - round(pos);
	return sphere(pos,radius);
}

vec3 normal(vec3 pos) {
	float base = sdf(pos);
	vec2 h = vec2(EPS,0);
	return normalize(
		vec3(
			sdf(pos + h.xyy) - base,
			sdf(pos + h.yxy) - base,
			sdf(pos + h.yyx) - base
		)
	);
}

void fragment() {
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = -normalize( (INV_VIEW_MATRIX * vec4(VIEW,0)).xyz );
	float dist = 0.;
	float sample = 1.;

	for(int i = 0; i < maxSteps; i++) {
		sample = sdf(ro + rd * dist);
		if(sample < EPS) {
			break;
		}
		dist += sample;
	}
	vec3 pos = ro + rd * dist;
	vec3 normal = normal(pos);
	float fog = smoothstep(nearFogBlend,farFogBlend,dist);
	vec3 fogColour = mix(darkColour,brightColour,(0.5 * rd.z + 0.5));
	
	ALBEDO = (dist < farFogBlend) ? normal : fogColour;
	
	
}
