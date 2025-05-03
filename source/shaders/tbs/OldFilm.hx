package shaders.tbs;

import flixel.system.FlxAssets.FlxShader;

class OldFilm extends FlxShader
{
	@:glFragmentSource('
#pragma header
uniform float iTime;
uniform float brightness;
uniform float sat;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

#define int2 vec2
#define float2 vec2
#define int3 vec3
#define float3 vec3
#define int4 vec4
#define float4 vec4
#define frac fract
#define float2x2 mat2
#define float3x3 mat3
#define float4x4 mat4
#define saturate(x) clamp(x,0.,1.)
#define lerp mix
#define CurrentTime (iTime)
#define sincos(x,s,c) s = sin(x),c = cos(x)
#define mul(x,y) (x*y)
#define atan2 atan
#define fmod mod
#define static

float2 hash(float2 p)
{
    float3 p3 = frac(float3(p.xyx) * float3(56.1031, 147.1030, 142.0973));
    p3 += dot(p3, p3.yzx + 343.33);
    return frac((p3.xx + p3.yz) * p3.zy);
}

float simplexNoise(float2 uv)
{
    const float k1 = 0.366025f;
    const float k2 = 0.211324f;

    int2 idx = floor(uv + (uv.x + uv.y) * k1);
    float2 a = uv - (float2(idx) - float(idx.x + idx.y) * k2);
    int2 tb = a.y > a.x ? int2(0, 1) : int2(1, 0);
    float2 b = a - tb + k2;
    float2 c = a - 1.f + k2 * 2.f;
    
    float3 kernel = max(0.504f - float3(dot(a, a), dot(b, b), dot(c, c)), 0.f);
    float3 noise = kernel * kernel * kernel * kernel * 
    float3(dot(a, hash(idx)*2.f-1.), 
           dot(b, hash(idx + tb)*2.-1.), 
           dot(c, hash(idx + 1.f)*2.-1.));
    
    return dot(float3(70.f), noise);
}

mat4 saturationMatrix( float saturation )
{
    vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
    
    float oneMinusSat = 1.0 - saturation;
    
    vec3 red = vec3( luminance.x * oneMinusSat );
    red+= vec3( saturation, 0, 0 );
    
    vec3 green = vec3( luminance.y * oneMinusSat );
    green += vec3( 0, saturation, 0 );
    
    vec3 blue = vec3( luminance.z * oneMinusSat );
    blue += vec3( 0, 0, saturation );
    
    return mat4( red,     0,
                 green,   0,
                 blue,    0,
                 0, 0, 0, 1 );
}


float verticalLine(float2 uv, float time)
{
    float uvX = uv.x + time*0.0000003;
    float2 xHash = hash(float2(uvX,uvX));
    float vertical = step(0.9999996,sin(uvX*1000.0 * (xHash.x*0.01+0.01)));
    
    float uvY = uv.y + time*0.00000000001;
    float2 yHash = hash(float2(uvY,uvY));
    vertical *= sin(uvY*1000.0 * (yHash.x));
    
    
    return saturate(1.0 - vertical);
}

void mainImage()
{
    vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
    float t = iTime;
    
    float3 col = float3(-1.3,-1.3,-1.3);
    col += verticalLine(uv-1.0,t)*1* brightness;
    col += (1.9 - verticalLine(uv-3.0,t*5.0))*0.5;
    col *= smoothstep(0.9,0.83, simplexNoise((uv + hash(float2(t,t))*154.4541-154.4541)*10.0));
    col *= 0.8 - hash(uv + t * 0.01f).x * 0.65;
    col *= smoothstep(1.5 + hash(floor(float2(t,t)*5.)).x*1.3,1.0, length(uv-0.5));
   
    float3 tex = texture(iChannel0,uv).rgb - 0.3;
    tex = float3( (tex.r + tex.g + tex.b)/3.0 );
    
    fragColor = saturationMatrix(sat) * flixel_texture2D(bitmap, openfl_TextureCoordv) * vec4(col + tex, flixel_texture2D(iChannel0,uv).a);
}
    ')

    public function new()
	{
		super();
	}
}