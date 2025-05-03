package shaders.tbs;

import flixel.system.FlxAssets.FlxShader;

class Monitor extends FlxShader
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
        texture2D(bitmap, uv+.001).r,
        texture2D(bitmap, uv).g,
        texture2D(bitmap, uv-.001).b, 
        1.0
    );
    
    tex *= smoothstep(uv.x,uv.x+0.01,1.)*smoothstep(uv.y,uv.y+0.01,1.)*smoothstep(-0.01,0.,uv.x-0.01)*smoothstep(-0.01,0.,uv.y-0.01);
    
    float avg = (tex.r+tex.g+tex.b)/3.;
    gl_FragColor = tex + pow(avg,15.);
}
    ')

    public function new()
	{
		super();
	}
}