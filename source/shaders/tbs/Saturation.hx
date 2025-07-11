package shaders.tbs;

import flixel.system.FlxAssets.FlxShader;

class Saturation extends FlxShader
{
	@:glFragmentSource('
// SHADER BY LUNAR
#pragma header

uniform float sat;

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

void main(void)
{ 
    gl_FragColor = saturationMatrix(sat) * flixel_texture2D(bitmap, openfl_TextureCoordv);
}
    ')

    public function new()
	{
		super();
	}
}