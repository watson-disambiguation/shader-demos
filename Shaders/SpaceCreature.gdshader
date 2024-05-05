shader_type spatial;
render_mode unshaded;

#include "Libraries/SkyLibrary.gdshaderinc"
uniform int seed;
uniform float starDensity = 40;
uniform float minFlicker = 0.1;
uniform float maxFlicker = 1.;
uniform float fresnelThreshold = 0.8;
uniform float fresnelWidth = 0.2;
uniform vec3 tint : source_color; 

void fragment() {
	vec3 dir = (INV_VIEW_MATRIX * vec4(VIEW,0)).xyz;
	vec3 normalWorld = (INV_VIEW_MATRIX * vec4(NORMAL,0)).xyz;
	vec3 color = stars(seed,dir,starDensity,minFlicker,maxFlicker,1.);
	float edge = smoothstep(fresnelThreshold-fresnelWidth,fresnelThreshold,(1. - dot(dir,normalWorld)));
	ALBEDO = (color + edge) * tint;
	EMISSION = color;
}
