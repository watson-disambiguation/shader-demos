shader_type spatial;

render_mode specular_disabled;
render_mode unshaded;


uniform sampler2D normalMap : hint_normal;

varying vec3 viewDir;
varying vec3 pos;


void vertex() {
	pos = (MODEL_MATRIX * vec4(VERTEX,1.)).xyz;
	viewDir = normalize(pos - CAMERA_POSITION_WORLD);
}

void fragment() {
	
	
}
