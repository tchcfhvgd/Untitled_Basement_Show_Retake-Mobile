package shaders.tbs;

import flixel.system.FlxAssets.FlxShader;

class VignetteThing extends FlxShader
{
	@:glFragmentSource('
// Automatically converted with ShadertoyToFlixel.js

#pragma header

vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime;

float zoom = 1;
void main()
{
    vec2 uv = openfl_TextureCoordv;
    uv = (uv-.5)*2.;
    uv *= zoom;
    
    uv.x *= 1. + pow(abs(uv.y/2.),3.);
    uv.y *= 1. + pow(abs(uv.x/2.),3.);
    uv = (uv + 1.)*.5;
    
    vec4 tex = vec4( 
        flixel_texture2D(bitmap, uv).r,
        flixel_texture2D(bitmap, uv).g,
        flixel_texture2D(bitmap, uv).b, 
        1.0
    );
    
    tex *= smoothstep(uv.x,uv.x+0.1,1.)*smoothstep(uv.y,uv.y+0.1,1.)*smoothstep(-0.1,0.,uv.x-0.1)*smoothstep(-0.05,0.,uv.y-0.08);
    
    float avg = (tex.r+tex.g+tex.b)/3.;
    gl_FragColor = tex + pow(avg,15.);
}
    ')

    public function new()
	{
		super();
	}
}