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
uniform vec3 sunColour : source_color;
uniform float fresnelPower;
uniform float depthFalloff;
uniform vec3 boxCenter;
uniform vec3 boxSize;
uniform vec3 holeCenter;
uniform vec3 holeSize;
uniform float lightingMin;
uniform float edgeFoam : hint_range(0.01,10.,0.01);
uniform float waveHeight = 0.05;
uniform float waveTexScale = 1.;
uniform vec3 sunDir;
uniform float sunRadius;
uniform sampler2D waveNormals1;
uniform sampler2D waveNormals2;
uniform float waveSpeed = 1.;
uniform float shadowStep = 3.;
uniform float shadowHardness = 32.;
uniform float sunStrength = 100.;

const int maxSteps = 128;
#define EPS 0.01

uniform float maxDist = 100.;

float planeDist(vec3 ro, vec3 rd, float height) {
	return -(ro.y + height + sin(TIME) * waveHeight) / rd.y;
}


float sdf(vec3 pos) {
	float monolith = box(pos-boxCenter,boxSize);
	monolith = subtract(monolith,box(pos-holeCenter,holeSize));
	float dist = sphere(pos-sphereCenter,sphereRadius);
	dist = round_merge(dist,pos.y-seaDepth,1.);
	return round_merge(dist,monolith,0.5);
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

vec4 sky(vec3 dir) {
	// return stars(seed,dir,starSpacing,minFlickerPeriod,maxFlickerPeriod,lightThreshold);
	float sun = step(cos(sunRadius),dot(normalize(sunDir),dir));
	vec3 skyGradient = mix(horizonColour,skyColour,pow(abs(dir.y),0.5));
	return vec4(vec3(skyGradient + sun),sun*sunStrength);
}
float constrain(float x) {
	return x / (x + depthFalloff);
}

float shadow(vec3 pos) {
	vec3 dir = normalize(sunDir);
    float res = 1.0;
    float t = EPS*shadowStep;
    for( int i=0; i<maxSteps; i++ )
    {
        float h = sdf(pos + dir*t);
        if( h<0.001 )
            return 0.0;
        res = min( res, shadowHardness*h/t );
        t += h;
    }
    return res;
}

vec4 calcWorld(raymarchResult result,vec3 ro, vec3 rd) {
	float lighting = shadow(ro+rd*result.dist) * dot(normalize(sunDir),normal(ro+rd*result.dist)) + lightingMin;
	return result.hit ? vec4(landColour * lighting,0.) : sky(rd);
}

vec3 getNormal(vec3 pos) {
	vec2 uv1 = fract(pos.xz * waveTexScale + TIME * waveSpeed);
	vec3 normal1 = 2.*texture(waveNormals1,uv1).xzy - 1.;
	vec2 uv2 = fract(pos.xz * waveTexScale - TIME * waveSpeed) ;
	vec3 normal2 = 2.*texture(waveNormals2,uv2).xzy - 1.;
	return normalize(normal1 + normal2);
}

void fragment() {
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize( (INV_VIEW_MATRIX * vec4(VIEW,0)).xyz );
	float seaDist = planeDist(ro,rd,0.);
	raymarchResult result = raymarch(ro,rd);
	vec4 worldTotal = calcWorld(result,ro,rd);
	vec3 world = worldTotal.xyz;
	float worldEmission = worldTotal.w;
	vec3 reflectionPoint = ro+rd*seaDist;
	vec3 waveNormal = getNormal(reflectionPoint);
	vec3 reflectedView = reflect(rd,waveNormal);
	raymarchResult reflectedResult = raymarch(reflectionPoint,reflectedView);
	vec4 reflectedWorldTotal = calcWorld(reflectedResult,reflectionPoint,reflectedView);
	vec3 reflectedWorld = reflectedWorldTotal.xyz;
	float reflectedWorldEmission = reflectedWorldTotal.w;
	float waterDist = constrain(result.dist-seaDist);
	vec3 waterDiffuse = seaColour;
	vec3 waterSpecular = reflectedWorld;
	vec3 sea = mix(waterDiffuse, waterSpecular,pow(1.+rd.y,fresnelPower));
	float seaEdge = sdf(reflectionPoint) * edgeFoam;
	sea = mix(vec3(1.),sea,clamp(seaEdge,0.,1.));
	sea = sea * (shadow(reflectionPoint) + lightingMin);
	vec3 albedo = seaDist > 0. && seaDist < result.dist ?  sea  : world; 
	float emission = seaDist > 0. && seaDist < result.dist ?  reflectedWorldEmission  : worldEmission;
	ALBEDO = albedo + emission;
	EMISSION = vec3(emission);
}