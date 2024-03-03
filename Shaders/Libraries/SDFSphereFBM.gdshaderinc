#ifndef SDFSPHEREFBM
#define SDFSPHEREFBM

#include "HashLibrary.gdshaderinc"
#include "SDFLibrary.gdshaderinc"

float sph( ivec3 i, vec3 f, ivec3 c )
{
   // random radius at grid vertex i+c
   float rad = 0.5*hash33(vec3(i+c)).r;
   // distance to sphere at grid vertex i+c
   return length(f-vec3(c)) - rad; 
}

float sdBase( vec3 p )
{
   ivec3 i = ivec3(floor(p));
    vec3 f =       fract(p);
   // distance to the 8 corners spheres
   return min(min(min(sph(i,f,ivec3(0,0,0)),
                      sph(i,f,ivec3(0,0,1))),
                  min(sph(i,f,ivec3(0,1,0)),
                      sph(i,f,ivec3(0,1,1)))),
              min(min(sph(i,f,ivec3(1,0,0)),
                      sph(i,f,ivec3(1,0,1))),
                  min(sph(i,f,ivec3(1,1,0)),
                      sph(i,f,ivec3(1,1,1)))));
}

float sdFbm( vec3 p, float d, int levels )
{
   float s = 1.0;
   for( int i=0; i<levels; i++ )
   {
       // evaluate new octave
       float n = s*sdBase(p);
	
       // add
       n = round_intersect(n,d-0.1*s,0.3*s);
       d = round_merge(n,d      ,0.3*s);
	
       // prepare next octave
       p = mat3( vec3(0.00, 1.60, 1.20),
                vec3(-1.60, 0.72,-0.96),
                vec3(-1.20,-0.96, 1.28) )*p;
       s = 0.5*s;
   }
   return d;
}

float sdFbmLod( vec3 p, float d, float th )
{
   float s = 1.0;
   for( int i=0; i<11; i++ )
   {
       // evaluate new octave
       float n = s*sdBase(p);
	
       // add
       n = round_intersect(n,d-0.1*s,0.3*s);
       d = round_merge(n,d      ,0.3*s);
	
       // prepare next octave
       p = mat3( vec3(0.00, 1.60, 1.20),
                vec3(-1.60, 0.72,-0.96),
                vec3(-1.20,-0.96, 1.28) )*p;
       s = 0.5*s;
	
       // lod
       if( s<th ) break;
   }
   return d;
}

#endif