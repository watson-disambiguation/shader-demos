shader_type spatial;

render_mode unshaded;

#include "Libraries/SDFLibrary.gdshaderinc"
#include "Libraries/NoiseLibrary.gdshaderinc"

uniform int blurIterations;
uniform float blurTime;
uniform float nearFogBlend;
uniform float farFogBlend;
uniform float surfaceHeight;
uniform float radius;
uniform float rainSpeed;
uniform float rainSpacing = 1.;
uniform float offset;
uniform float mergeRadius;
uniform float aoDist;
uniform int aoSamples;
uniform float aoStrength;
uniform vec3 fogColour : source_color;
uniform vec3 objColour : source_color;
uniform float camRadius = 0.5;

const int maxSteps = 128;
const float EPS = 0.0001;

float surfacePlane(vec3 pos) {
	return pos.y - surfaceHeight;
}

float repeatedRain( vec3 p, float s )
{
    vec3 id = round(p/s);
    vec3 o = sign(p - s * id);
    float d = 1e20;
	for( int k=0; k<2; k++ )
    for( int j=0; j<2; j++ )
    for( int i=0; i<2; i++ )
    {
        vec3 rid = id + vec3(float(i),float(j),float(k)) * o;
        vec3 r = p - s*rid;
		vec3 offsetVector = (2.*hash33(rid)-1.) * (0.5 * rainSpacing);
        d = min( d, sphere(r + offsetVector, radius) );
    }
    return d;
}

float sdf(vec3 pos, vec3 camPos) {
	float surface = surfacePlane(pos);
	pos.y += TIME * rainSpeed;
	float rain = repeatedRain(pos,rainSpacing);
	rain = round_merge(rain,surface,mergeRadius);
	return rain;
}

vec3 normal(vec3 pos, vec3 camPos) {
	float base = sdf(pos, camPos);
	vec2 h = vec2(EPS,0);
	return normalize(
		vec3(
			sdf(pos + h.xyy, camPos) - base,
			sdf(pos + h.yxy, camPos) - base,
			sdf(pos + h.yyx, camPos) - base
		)
	);
}
/*
float occlusion(vec3 pos, vec3 normal) {
	float invAO = 0.;
	float stepSize = aoDist / float(aoSamples);
	float decay = 1.;
	for(int i = 1; i <= aoSamples; i++) {
		decay /= 2.;
		float distOut = float(i) * stepSize;
		float sampleDist = sdf(pos + normal * distOut);
		invAO += decay * (distOut - sampleDist);
	}
	return 1. - aoStrength * invAO;
}
*/
float raymarch(vec3 ro, vec3 rd) {
	float dist = 0.;
	float sample = 1.;
	for(int i = 0; i < maxSteps; i++) {
		sample = sdf(ro + rd * dist, ro);
		if(sample < EPS || dist > farFogBlend) {
			return dist;
		}
		dist += sample;
	}
	return dist;
}

void fragment() {
	vec3 col = objColour;
	vec3 ro = CAMERA_POSITION_WORLD;
	vec3 rd = normalize( (INV_VIEW_MATRIX * vec4(VIEW,0)).xyz );
	float dist = raymarch(ro,rd);
	vec3 pos = ro + rd * dist;
	vec3 normal = normal(pos,ro);
	float fog = smoothstep(nearFogBlend,farFogBlend,dist);
	//float fresnel = 1.-pow(clamp(0,1,dot(-rd,normal)),0.1);
	//vec3 col = mix(objColour,vec3(1),fresnel);
	col = mix(col,fogColour,fog);
	ALBEDO = col;
	
	
}
