shader_type spatial;

render_mode unshaded;

#include "Libraries/SkyLibrary.gdshaderinc"
#include "Libraries/SDFLibrary.gdshaderinc"

#define UP vec3(0.,1.,0.)

uniform float starSpacing;
uniform float minFlickerPeriod;
uniform float maxFlickerPeriod;
uniform float lightThreshold;
uniform int seed;
uniform vec3 sphereCenter;
uniform float sphereRadius;
uniform vec3 landColour : source_color;

const int maxSteps = 128;
#define EPS 0.0001

uniform float maxDist = 100.;

float planeDist(vec3 ro, vec3 rd, float height) {
	return -(ro.y + height) / rd.y;
}

float sdf(vec3 pos) {
	return sphere(pos-sphereCenter,sphereRadius);
}

struct raymarchResult {
	float dist;
	bool hit;
};

raymarchResult raymarch(vec3 ro, vec3 rd) {
	raymarchResult result;
	result.dist = 0.;
	float sample = 1.;
	for(int i = 0; i < maxSteps; i++) {
		sample = sdf(ro + rd * result.dist);
		if(sample < EPS) {
			result.hit = true;
			return result;
		}
		result.dist += sample;
	}
	result.hit = false;
	return result;
}

void fragment() {
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize( (INV_VIEW_MATRIX * vec4(VIEW,0)).xyz );
	float seaDist = planeDist(ro,rd,0.);
	raymarchResult result = raymarch(ro,rd);
	vec3 sky = stars(seed,rd,starSpacing,minFlickerPeriod,maxFlickerPeriod,lightThreshold);
	vec3 world = result.hit ? landColour : sky;
	vec3 reflectedView = reflect(rd,UP);
	raymarchResult reflectedResult = raymarch(ro+rd*seaDist,reflectedView);
	vec3 skyReflection = stars(seed,reflectedView,starSpacing,minFlickerPeriod,maxFlickerPeriod,lightThreshold);
	vec3 reflectedWorld = reflectedResult.hit ? landColour : skyReflection;
	ALBEDO = seaDist > 0. && seaDist < result.dist ?  (1. + rd.y) * reflectedWorld  : world; 
}