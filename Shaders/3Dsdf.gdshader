shader_type spatial;
#include "Libraries/SDFLibrary.gdshaderinc"

render_mode specular_disabled;
render_mode diffuse_burley;
render_mode cull_front;

uniform vec3 color : source_color;
uniform sampler3D noiseTex;
uniform float noiseScale;
uniform float raycastStepSize;
uniform int raycastSteps;
uniform vec3 sphereCenter1;
uniform float sphereRadius1;
uniform vec3 sphereCenter2;
uniform float sphereRadius2;
uniform float mergeRadius;

const float h = 0.0001;

float sphereSDF(vec3 pos, vec3 center, float radius) {
	return length(pos-center) - radius;
}

float sdf(vec3 pos) {
	float sdf1 = sphereSDF(pos,sphereCenter1,sphereRadius1);
	float sdf2 = sphereSDF(pos,sphereCenter2,sphereRadius2);
	float noise = texture(noiseTex,fract(pos + vec3(0.,-TIME,0.))).x * noiseScale;
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



vec3 raycast() {
	vec3 raycastStep = viewDir * raycastStepSize;
	vec3 startPos = pos - raycastStep * float(raycastSteps);
	vec3 currPos = startPos;
	for(int i = 0; i < raycastSteps; i++) {
		float sdfVal = sdf(currPos);
		if(sdfVal < 0.) {
			return normalize(sdfGradient(currPos));
		}
		currPos += raycastStep;
	}
	return vec3(0);
}

void vertex() {
	pos = (MODEL_MATRIX * vec4(VERTEX,1.)).xyz;
	viewDir = normalize(pos - CAMERA_POSITION_WORLD);
}

void fragment() {
	vec3 normal = raycast();
	if(length(normal) < h) {
		discard;
	}
	NORMAL = normal;
	ALBEDO = color;
	
}

