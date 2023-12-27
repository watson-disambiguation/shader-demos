//https://www.shadertoy.com/view/ttc3zr

uvec2 murmurHash21(uint src) {
    const uint M = 0x5bd1e995u;
    uvec2 h = uvec2(1190494759u, 2147483647u);
    src *= M; src ^= src>>24u; src *= M;
    h *= M; h ^= src;
    h ^= h>>13u; h *= M; h ^= h>>15u;
    return h;
}

// 2 outputs, 1 input
vec2 hash21(float src) {
    uvec2 h = murmurHash21(floatBitsToUint(src));
    return vec2(
		uintBitsToFloat(h.x & 0x007fffffu | 0x3f800000u),
		uintBitsToFloat(h.y & 0x007fffffu | 0x3f800000u)
		) - 1.0;
}

uint murmurHash11(uint src) {
    const uint M = 0x5bd1e995u;
    uint h = 1190494759u;
    src *= M; src ^= src>>24u; src *= M;
    h *= M; h ^= src;
    h ^= h>>13u; h *= M; h ^= h>>15u;
    return h;
}

// 1 output, 1 input
float hash11(float src) {
    uint h = murmurHash11(floatBitsToUint(src));
    return uintBitsToFloat(h & 0x007fffffu | 0x3f800000u) - 1.0;
}
uvec2 murmurHash22(uvec2 src) {
    const uint M = 0x5bd1e995u;
    uvec2 h = uvec2(1190494759u, 2147483647u);
    src *= M; src ^= src>>24u; src *= M;
    h *= M; h ^= src.x; h *= M; h ^= src.y;
    h ^= h>>13u; h *= M; h ^= h>>15u;
    return h;
}

// 2 outputs, 2 inputs
vec2 hash22(vec2 src) {
    uvec2 h = murmurHash22(floatBitsToUint(src));
    return vec2(
		uintBitsToFloat(h.x & 0x007fffffu | 0x3f800000u),
		uintBitsToFloat(h.y & 0x007fffffu | 0x3f800000u)
		) - 1.0;
}

uint murmurHash12(uvec2 src) {
    const uint M = 0x5bd1e995u;
    uint h = 1190494759u;
    src *= M; src ^= src>>24u; src *= M;
    h *= M; h ^= src.x; h *= M; h ^= src.y;
    h ^= h>>13u; h *= M; h ^= h>>15u;
    return h;
}

// 1 output, 2 inputs
float hash12(vec2 src) {
    uint h = murmurHash12(floatBitsToUint(src));
    return uintBitsToFloat(h & 0x007fffffu | 0x3f800000u) - 1.0;
}

uvec3 murmurHash31(uint src) {
    const uint M = 0x5bd1e995u;
    uvec3 h = uvec3(1190494759u, 2147483647u, 3559788179u);
    src *= M; src ^= src>>24u; src *= M;
    h *= M; h ^= src;
    h ^= h>>13u; h *= M; h ^= h>>15u;
    return h;
}

// 3 outputs, 1 input
vec3 hash31(float src) {
    uvec3 h = murmurHash31(floatBitsToUint(src));
    return vec3(
		uintBitsToFloat(h.x & 0x007fffffu | 0x3f800000u),
		uintBitsToFloat(h.y & 0x007fffffu | 0x3f800000u),
		uintBitsToFloat(h.z & 0x007fffffu | 0x3f800000u)
		) - 1.0;
}

uvec3 murmurHash33(uvec3 src) {
    const uint M = 0x5bd1e995u;
    uvec3 h = uvec3(1190494759u, 2147483647u, 3559788179u);
    src *= M; src ^= src>>24u; src *= M;
    h *= M; h ^= src.x; h *= M; h ^= src.y; h *= M; h ^= src.z;
    h ^= h>>13u; h *= M; h ^= h>>15u;
    return h;
}

// 3 outputs, 3 inputs
vec3 hash33(vec3 src) {
    uvec3 h = murmurHash33(floatBitsToUint(src));
    return vec3(
		uintBitsToFloat(h.x & 0x007fffffu | 0x3f800000u),
		uintBitsToFloat(h.y & 0x007fffffu | 0x3f800000u),
		uintBitsToFloat(h.z & 0x007fffffu | 0x3f800000u)
		) - 1.0;
}
