float circle(vec2 uv, vec2 center, float radius) {
	return length(uv-center) - radius;
}

float sphere(vec3 pos, float radius) {
	return length(pos) - radius;
}

vec2 transform(vec2 samplePosition, vec2 offset, float angleDegrees) {
	vec2 position = samplePosition - offset;
	float angleRadians = angleDegrees * PI / 180.;
	float s = sin(angleRadians);
	float c = cos(angleRadians); 
	return vec2(c * position.x + s * position.y, c * position.y - s * position.x);
}

float rectangle(vec2 pos, vec2 size) {
	vec2 componentDistance = abs(pos) - size;
	float outsideDistance = length(max(componentDistance,vec2(0)));
	float insideDistance = min(max(componentDistance.x,componentDistance.y), 0);
	return outsideDistance + insideDistance;
}

float box( vec3 pos, vec3 size )
{
  vec3 q = abs(pos) - size;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float merge(float shape1, float shape2) {
	return min(shape1,shape2);
}

float intersect(float shape1, float shape2) {
	return max(shape1,shape2);
}

float subtract(float shape1, float shape2) {
	return intersect(shape1,-shape2);
}

float round_merge(float shape1, float shape2, float radius){
    float h = clamp( 0.5 + 0.5*(shape2-shape1)/radius, 0.0, 1.0 );
    return mix( shape2, shape1, h ) - radius*h*(1.0-h);
}

float round_intersect(float shape1, float shape2, float radius){
    vec2 intersectionSpace = vec2(shape1 + radius, shape2 + radius);
    intersectionSpace = max(intersectionSpace, 0);
	float outsideDistance = length(intersectionSpace);
	float simpleIntersect = intersect(shape1,shape2);
	float insideDistance = min(simpleIntersect,-radius);
    return  insideDistance + outsideDistance;
}
