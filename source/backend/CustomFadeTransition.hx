package backend;

// it's from WI so stfu.

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import openfl.filters.ShaderFilter;
import shaders.TransShader;

class CustomFadeTransition extends MusicBeatSubstate
{
	public static var finishCallback:Void->Void;

	private var leTween:FlxTween = null;

	var shader:TransShader = new TransShader();

	var from:Float = 0;

	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	var transitionSprite:FlxSprite;

	public function new(duration:Float, isTransIn:Bool)
	{
		super();

		this.isTransIn = isTransIn;

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];

		var width:Int = Std.int(FlxG.width);
		var height:Int = Std.int(FlxG.height);

		transitionSprite = new FlxSprite(width + -1845, height + -1610);
		transitionSprite.frames = Paths.getSparrowAtlas('kevin_normal');
		transitionSprite.animation.addByPrefix('transition', 'kevin_normal', 48, false);
		transitionSprite.scrollFactor.set(0, 0);
		add(transitionSprite);

		if (isTransIn)
			{
				transitionSprite.visible = true;
				transitionSprite.animation.play('transition', true, true, 28);
				transitionSprite.animation.callback = function(anim, framenumber, frameindex)
				{
					if (framenumber == 0)
						close();
				}
			}
			else
			{
				transitionSprite.animation.play('transition', true);
				transitionSprite.animation.callback = function(anim, framenumber, frameindex)
				{
					if (finishCallback != null && framenumber == 28)
					{
						finishCallback();
					}
				}
			}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function destroy()
	{
		if (leTween != null)
		{
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}