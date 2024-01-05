shader_type spatial;

render_mode unshaded;

#include "Libraries/SDFLibrary.gdshaderinc"
#include "Libraries/NoiseLibrary.gdshaderinc"

uniform float nearFogBlend;
uniform float farFogBlend;
uniform float pillarSize;
uniform float pillarRounding = 0.01;
uniform float noiseSize = 0.01;
uniform float mergeRadius = 0.01;
uniform float hallSize;
uniform vec3 brightColour : source_color;
uniform vec3 darkColour : source_color;
uniform vec3 objColour : source_color;

const int maxSteps = 128;
const float EPS = 0.0001;



float sdf(vec3 pos) {
	float hall = -rectangle(pos.xy,vec2(hallSize));
	vec3 pillarPos = pos;
	pillarPos.z = pillarPos.z - round(pillarPos.z);
	pillarPos.x = abs(pillarPos.x);
	float pillars = box(pillarPos- vec3(hallSize,0,0), vec3(pillarSize,hallSize,pillarSize)) - pillarRounding;
	
	float result = round_merge(hall,pillars,mergeRadius);
	//result += perlinNoise3DOctaves(pos,0.25,0,4) * noiseSize;
	return result;
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
	vec3 lightCol = mix(darkColour,brightColour,(0.5 * normal.z + 0.5));
	vec3 col = mix(objColour,lightCol,0.3);
	
	ALBEDO = (dist < farFogBlend) ? mix(col,fogColour,fog) : fogColour;
	
	
}
