package shaders.tbs;

import flixel.system.FlxAssets.FlxShader;

class ChromWarp extends FlxShader
{
	@:glFragmentSource('
#pragma header

//uniform float iTime;
uniform float distortion;

vec2 PincushionDistortion(in vec2 uv, float strength) {
	vec2 st = uv - 0.5;
    float uvA = atan(st.x, st.y);
    float uvD = dot(st, st);
    return 0.5 + vec2(sin(uvA), cos(uvA)) * sqrt(uvD) * (1.0 - strength * uvD);
}

vec4 ChromaticAbberation(sampler2D tex, in vec2 uv) 
{
	float rChannel = texture2D(tex, PincushionDistortion(uv, 0.3 * distortion)).r;
	float gChannel = texture2D(tex, PincushionDistortion(uv, 0.15 * distortion)).g;
	float bChannel = texture2D(tex, PincushionDistortion(uv, 0.075 * distortion)).b;
	float aChannel = texture2D(tex, PincushionDistortion(uv, 0.15 * distortion)).a;
	vec4 retColor = vec4(rChannel, gChannel, bChannel, aChannel);
	return retColor;
}

void main(){
	vec2 uv = openfl_TextureCoordv;
	vec4 col = ChromaticAbberation(bitmap, uv);
	
	gl_FragColor = col;
}
    ')

    public function new()
	{
		super();
	}
}