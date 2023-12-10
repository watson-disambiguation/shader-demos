uniform float pixelScale = 1.;

vec2 pixelateUV(vec2 uv, vec2 numPixels) {
	vec2 amount = numPixels / pixelScale;
	return round(uv * amount+0.5) / (amount);
}

vec2 getWorldPos(vec2 uv, mat4 modelMatrix) {
	return (modelMatrix * vec4(uv, 0.0, 1.0)).xy;
}

vec2 getNumPixels(vec2 uv, mat4 modelMatrix) {
	return getWorldPos(uv+1.,modelMatrix) - getWorldPos(uv,modelMatrix);
}

varying vec2 numPixels;