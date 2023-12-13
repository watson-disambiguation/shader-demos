shader_type spatial;
#include "Libraries/SDFLibrary.gdshaderinc"

render_mode specular_disabled;
render_mode unshaded;
render_mode cull_front;

uniform vec3 innerColor : source_color;
uniform vec3 outerColor : source_color;
uniform sampler3D noiseTex;
uniform float noiseScale;
uniform float raycastLength;
uniform int raycastSteps;
uniform vec3 sphereCenter1;
uniform float sphereRadius1;
uniform vec3 sphereCenter2;
uniform float sphereRadius2;
uniform float burnSpeed = 1.;
uniform float mergeRadius;
uniform float depthMultiplier;

const float h = 0.0001;

float sphereSDF(vec3 pos, vec3 center, float radius) {
	return length(pos-center) - radius;
}

float sdf(vec3 pos) {
	float sdf1 = sphereSDF(pos,sphereCenter1,sphereRadius1);
	float sdf2 = sphereSDF(pos,sphereCenter2,sphereRadius2);
	float noise = texture(noiseTex,fract(pos + burnSpeed * vec3(0.,-TIME,0.))).x * noiseScale;
	return round_merge(sdf1,sdf2,mergeRadius) - noise;
}

vec3 sdfGradient(vec3 pos) {
	float dx = (sdf(pos + vec3(h,0.,0.)) - sdf(pos)) / h;
	float dy = (sdf(pos + vec3(0.,h,0.)) - sdf(pos)) / h;
	float dz = (sdf(pos + vec3(0.,0.,h)) - sdf(pos)) / h;
	return vec3(dx,dy,dz);
}

varying vec3 pos;
varying vec3 viewDir;



vec4 raycast() {
	float raycastStepSize = raycastLength / float(raycastSteps);
	vec3 raycastStep = viewDir * raycastStepSize;
	vec3 startPos = pos - raycastStep * float(raycastSteps);
	vec3 currPos = startPos;
	float distThrough = 0.;
	vec3 normal = vec3(0);
	for(int i = 0; i < raycastSteps; i++) {
		float sdfVal = sdf(currPos);
		
		distThrough += raycastStepSize * step(0,-sdfVal);
		
		currPos += raycastStep;
	}
	return vec4(normal,distThrough);
}

void vertex() {
	pos = VERTEX;
	mat4 invModelMatrix = inverse(MODEL_MATRIX);
	viewDir = normalize(pos - (invModelMatrix * vec4(CAMERA_POSITION_WORLD,1.)).xyz);
}

void fragment() {
	vec4 raycastResult = raycast();
	vec3 normal = raycastResult.xyz;
	float distThrough = raycastResult.w * depthMultiplier;
	if(distThrough < h) {
		discard;
	}
	
	vec3 finalColor =  mix(outerColor,innerColor,distThrough);
	ALBEDO = finalColor;
	EMISSION = finalColor * 3.;
}


