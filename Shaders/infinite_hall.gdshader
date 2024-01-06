shader_type spatial;

render_mode unshaded;

#include "Libraries/SDFLibrary.gdshaderinc"
#include "Libraries/NoiseLibrary.gdshaderinc"

uniform float nearFogBlend;
uniform float farFogBlend;
uniform float pillarSize;
uniform float baseSize;
uniform float baseHeight;
uniform float pillarRounding = 0.01;
uniform float tileSize = 0.5;
uniform float tileRounding;
uniform float noiseSize = 0.01;
uniform float mergeRadius = 0.01;
uniform float hallSize;
uniform float lightBlend;
uniform vec3 brightColour : source_color;
uniform vec3 darkColour : source_color;
uniform vec3 objColour : source_color;

const int maxSteps = 128;
const float EPS = 0.0001;

float hallFloor(vec3 pos) {
	pos.xz = pos.xz - round(pos.xz);
	pos.y = abs(pos.y);
	pos.y = pos.y - hallSize;
	float size = tileSize - tileRounding;
	return box(pos,vec3(size,0.1 - tileRounding,size)) - tileRounding;
}

float pillar(vec3 pos) {
	pos.z = pos.z - round(pos.z);
	pos.x = abs(pos.x);
	pos = pos - vec3(hallSize,0,0);
	float upright = box(pos, vec3(pillarSize,hallSize,pillarSize));
	pos.y = abs(pos.y)  - hallSize + baseHeight;
	float base = box(pos, vec3(baseSize,baseHeight,baseSize));
	return min(upright,base) - pillarRounding;
}

float sdf(vec3 pos) {
	float hall = -rectangle(pos.xy,vec2(hallSize));
	float pillars = pillar(pos);
	float hallFloor = hallFloor(pos);
	
	float result = round_merge(hall,pillars,mergeRadius);
	result = merge(result,hallFloor);
	result += perlinNoise3DOctaves(pos,0.25,0,2) * noiseSize;
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
	int steps = 0;
	for(int i = 0; i < maxSteps; i++) {
		sample = sdf(ro + rd * dist);
		if(sample < EPS) {
			steps = i;
			break;
		}
		dist += sample;
	}
	vec3 pos = ro + rd * dist;
	vec3 normal = normal(pos);
	float fog = smoothstep(nearFogBlend,farFogBlend,dist);
	vec3 fogColour = mix(darkColour,brightColour,(0.5 * rd.z + 0.5));
	vec3 lightCol = mix(darkColour,brightColour,(0.5 * normal.z + 0.5) * (1. - float(steps)/128.));
	vec3 col = mix(objColour,lightCol,lightBlend);
	
	ALBEDO = (dist < farFogBlend) ? mix(col,fogColour,fog) : fogColour;
	
	
}
