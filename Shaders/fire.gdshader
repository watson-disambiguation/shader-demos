shader_type canvas_item;


#include "res://Shaders/Libraries/SDFLibrary.gdshaderinc"
#include "res://Shaders/Libraries/PixelLibrary.gdshaderinc"

uniform vec2 centerRect;
uniform vec2 sizeRect;
uniform float rotationDegreesRect;
uniform vec2 centerCircle;
uniform float circleRadius;
uniform float cornerRadius;

vec3 sdf(vec2 uv) {
	float rectangle = rectangle(transform(uv,centerRect,TIME* 40.),sizeRect);
	float circle = circle(uv,centerCircle,circleRadius);
	return vec3(round_intersect(circle,rectangle,cornerRadius),circle,rectangle);
}

void vertex() {
	numPixels = getNumPixels(UV,MODEL_MATRIX);
}

void fragment() {
	vec2 pixelUV = pixelateUV(UV,numPixels);
	vec3 sdf = step(0,sdf(pixelUV));
	COLOR = vec4(vec3(sdf.x),1.);
}
