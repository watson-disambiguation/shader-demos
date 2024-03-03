shader_type spatial;
#include "Libraries/SDFSphereFBM.gdshaderinc"

float sdf(vec3 pos) {
	float dist = sphere(pos,0.5);
	return sdFbm(pos,dist,8);
}

const int maxSteps = 128;
const float EPS = 0.001;

float raymarch(vec3 ro, vec3 rd, float maxDist) {
	float dist = 0.;
	float sample = 1.;
	for(int i = 0; i < maxSteps; i++) {
		sample = sdf(ro + rd * dist);
		if(dist > maxDist) {
			return dist;
		}
		if(sample < EPS) {
			return dist;
		}
		dist += sample;
	}
	return dist;
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
	vec3 pos = (INV_VIEW_MATRIX * vec4(VERTEX,1)).xyz;
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = pos - ro;
	float maxDist = length(rd);
	rd = normalize(rd);

	float dist = raymarch(ro,rd,maxDist);
	if(dist > maxDist) {
		discard;
	}
	vec3 surfacePos = ro + rd * dist;
	vec4 clipPos =  PROJECTION_MATRIX * VIEW_MATRIX * vec4(surfacePos,1);
	float depth = (clipPos.z / clipPos.w);
	DEPTH = depth;
	NORMAL = normal(surfacePos);
	
}
