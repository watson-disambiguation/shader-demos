shader_type spatial;

render_mode unshaded;

#include "Libraries/SkyLibrary.gdshaderinc"
#include "Libraries/SDFLibrary.gdshaderinc"
#include "Libraries/SDFSphereFBM.gdshaderinc"

#define UP vec3(0.,1.,0.)

uniform float seaDepth;
uniform float starSpacing;
uniform float minFlickerPeriod;
uniform float maxFlickerPeriod;
uniform float lightThreshold;
uniform int seed;
uniform vec3 sphereCenter;
uniform float sphereRadius;
uniform vec3 landColour : source_color;
uniform vec3 horizonColour : source_color;
uniform vec3 skyColour : source_color;
uniform vec3 seaColour : source_color;
uniform float fresnelPower;
uniform float depthFalloff;
uniform vec3 boxCenter;
uniform vec3 boxSize;
uniform float lightingMin;

const int maxSteps = 128;
#define EPS 0.01

uniform float maxDist = 100.;

float planeDist(vec3 ro, vec3 rd, float height) {
	return -(ro.y + height) / rd.y;
}


float sdf(vec3 pos) {
	float dist = sphere(pos-sphereCenter,sphereRadius);
	dist = round_merge(dist,pos.y-seaDepth,1.);
	dist = sdFbm(pos,dist,4);
	return round_merge(dist,box(pos-boxCenter,boxSize),0.5);
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

vec3 sky(vec3 dir) {
	return stars(seed,dir,starSpacing,minFlickerPeriod,maxFlickerPeriod,lightThreshold);
}
float constrain(float x) {
	return x / (x + depthFalloff);
}

vec3 calcWorld(raymarchResult result,vec3 ro, vec3 rd) {
	float lighting = mix(lightingMin,1.,normal(ro+rd*result.dist).y);
	return result.hit ? landColour * lighting : sky(rd);
}

void fragment() {
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize( (INV_VIEW_MATRIX * vec4(VIEW,0)).xyz );
	float seaDist = planeDist(ro,rd,0.);
	raymarchResult result = raymarch(ro,rd);
	vec3 world = calcWorld(result,ro,rd);
	vec3 reflectedView = reflect(rd,UP);
	raymarchResult reflectedResult = raymarch(ro+rd*seaDist,reflectedView);
	vec3 reflectedWorld = calcWorld(reflectedResult,ro+rd*seaDist,reflectedView);
	float waterDist = constrain(result.dist-seaDist);
	vec3 waterDiffuse = mix(world,seaColour, waterDist);
	vec3 waterSpecular = reflectedWorld;
	vec3 sea = mix(waterDiffuse, waterSpecular,pow(1.+rd.y,fresnelPower));
	ALBEDO = seaDist > 0. && seaDist < result.dist ?  sea  : world; 
}