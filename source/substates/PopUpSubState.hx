package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import flixel.math.FlxMath;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;
import flixel.util.FlxGradient;
import openfl.ui.Mouse;

class PopUpSubState extends MusicBeatSubstate
{
	var whiteBG:FlxSprite;
	var grayBG:FlxSprite;
	var bTxt:FlxText;
	var popTxt:FlxText;
	var popupChoice:FlxSprite;
	var popupChoice2:FlxSprite;

	var curSelected:Int = 0;

	override function create()
	{
		super.create();

        PlayState.loserCounts = 0;
		whiteBG = new FlxSprite().makeGraphic(700, 400, FlxColor.WHITE);
		whiteBG.updateHitbox();
		whiteBG.scrollFactor.set();
		whiteBG.screenCenter();
		add(whiteBG);

		grayBG = FlxGradient.createGradientFlxSprite(700, 40, [0xFF045AEA, 0xFF0040AE, 0xFF002668], 1, 90, true);
		grayBG.updateHitbox();
		grayBG.scrollFactor.set();
		grayBG.screenCenter();
		grayBG.y -= 200;
		add(grayBG);
	
		bTxt = new FlxText(-535, 50, 680, 'Local-Losers-Helper.exe', 20);
		bTxt.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, LEFT);
		bTxt.borderSize = 2.2;
		bTxt.scrollFactor.set();
		bTxt.screenCenter();
		bTxt.y -= 200;
		add(bTxt);
	
		popTxt = new FlxText(-535, 50, 680, 'Hello Loser, As I Can See You\'re Quite Seemed To Be Strugling Alot In This Song Due To Your Skill Issue Level, But No Problem! You Can Enable The SHITTY And STUPID Baby Mode To Lose You\'re Whole Dignity, So Yeah, The Choice Is Yours.', 20);
		popTxt.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		popTxt.borderSize = 2.2;
		popTxt.scrollFactor.set();
		popTxt.screenCenter();
		popTxt.y -= 30;
		add(popTxt);
	
		popupChoice2 = new FlxSprite(560, 520).loadGraphic(Paths.image('menus/no'));
		popupChoice2.scrollFactor.set();
		add(popupChoice2);
	
		popupChoice = new FlxSprite(360, 480).loadGraphic(Paths.image('menus/yes'));
		popupChoice.scrollFactor.set();
		add(popupChoice);

		FlxG.mouse.visible = true;
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		popupChoice.alpha = FlxMath.lerp(popupChoice.alpha, (curSelected == 0 ? 1 : 0.6), 30 * elapsed);
		popupChoice2.alpha = FlxMath.lerp(popupChoice2.alpha, (curSelected == 1 ? 1 : 0.6), 30 * elapsed);

    if (FlxG.mouse.overlaps(popupChoice)){
		curSelected = 0;
		if (FlxG.mouse.justPressed) {
			ClientPrefs.data.diffTBS = 'Baby';
			pressingThing();
		}
    }

	if(controls.UI_DOWN_P)
	{
		curSelected = 1;
	}

	if(controls.UI_UP_P)
	{
		curSelected = 0;
	}

	if (controls.ACCEPT) {
		pressingThing();
	}

    if (FlxG.mouse.overlaps(popupChoice2)){
		curSelected = 1;
		if (FlxG.mouse.justPressed) {
			pressingThing();
		}
    }
	}

	function pressingThing() {
		restartSong();
		if (curSelected == 0) {
			ClientPrefs.data.diffTBS = 'Baby';
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	override function destroy()
	{
		super.destroy();
	}
}
