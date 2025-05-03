#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float time;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

void mainImage()
{
    vec2 xy = fragCoord.xy / iResolution.xy;//Condensing this into one line
    vec4 texColor = texture(iChannel0,xy);//Get the pixel at xy from iChannel0

    texColor.r *= abs(sin(time * 5.0));
    texColor.b *= abs(sin(time * 5.0 + 1.0));
    texColor.g *= abs(sin(time * 5.0 + 2.0));
    
    fragColor = texColor;//Set the screen pixel to that color
}

// https://www.shadertoy.com/view/dssXRl