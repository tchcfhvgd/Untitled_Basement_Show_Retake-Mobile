package states.stages;

import states.stages.objects.*;
import openfl.filters.ShaderFilter;
import shaders.tbs.Monitor;
import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;

class Freeze extends BaseStage
{
    public static var bg:BGSprite;
	public static var fg:BGSprite;
	public static var snow:FlxSprite;
    public static var snowHUD:FlxSprite;
    public static var snowStorm:FlxSprite;

	public static var canTrigger:Bool = true; // so you won't get snow in the start of the song/a special event

    public static var shader2:Monitor = new Monitor();

	override function create()
	{
		bg = new BGSprite('game/stages/snow/freezebg back', -200, 150, 0.8, 1);
		bg.scale.set(1.48, 1.48);
		add(bg);

		fg = new BGSprite('game/stages/snow/freezebg front', -200, 150, 1, 1);
        fg.scale.set(1.48, 1.48);
		add(fg);

        if (ClientPrefs.data.shaders) game.camGame.setFilters([new ShaderFilter(shader2)]);
	}

	override function createPost() {
		snow = new FlxSprite(370, 190);
		snow.frames = Paths.getSparrowAtlas('game/stages/snow/snow_heavy');
		snow.animation.addByPrefix('snow_heavy idle', 'snow_heavy idle', 24, true);
		snow.scrollFactor.set();
		snow.blend = SCREEN;
		snow.scale.set(4,4);
		snow.angle += 20;
		snow.animation.play('snow_heavy idle');
		game.add(snow);
	
		snowStorm = new FlxBackdrop(Paths.image('game/stages/snow/storm'));
		snowStorm.alpha = 0;
		snowStorm.velocity.x = 998;
		game.add(snowStorm);
	
		snowHUD = new FlxSprite(330, 190);
		snowHUD.frames = Paths.getSparrowAtlas('game/stages/snow/snow_heavier');
		snowHUD.animation.addByPrefix('snow_heavy idle', 'snow_heavy idle', 60, true);
		snowHUD.scrollFactor.set();
		snowHUD.alpha = 0;
		snowHUD.blend = SCREEN;
		snowHUD.scale.set(6,6);
		snowHUD.animation.play('snow_heavy idle');
		game.add(snowHUD);
	}

	override function beatHit() {
		if (curStep > 192 && curBeat % FlxG.random.int(66,90) == FlxG.random.int(0,4) && snowHUD.alpha == 0 && canTrigger)
		{
			//trace('snowstrom incoming');
			FlxTween.tween(snowHUD, {alpha: 1}, 0.5);
			FlxTween.tween(snowStorm, {alpha: 1}, 0.5);
			new FlxTimer().start(3, function(tmr:FlxTimer){
				FlxTween.tween(snowHUD, {alpha: 0}, 1);
				FlxTween.tween(snowStorm, {alpha: 0}, 1);
			});
		}
	}
}