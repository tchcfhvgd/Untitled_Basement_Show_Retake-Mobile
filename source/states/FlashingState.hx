package states;

import flixel.text.FlxText;
import flixel.FlxSubState;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

import flixel.effects.FlxFlicker;
import lime.app.Application;
import options.FlashingOptionsState;
import flixel.addons.display.FlxBackdrop;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var whiteBG:FlxSprite;
	var clarification:FlxText;
	var warnTxt:FlxText;
	var enterTxt:FlxText;
	var oTxt:FlxText;

	var canEnter:Bool = false;
	var checker:FlxBackdrop;

	override function create()
	{
		super.create();

		whiteBG = new FlxSprite(500).makeGraphic(500, 1000, FlxColor.WHITE);
		whiteBG.screenCenter(X);
		whiteBG.alpha = 0;
		FlxTween.tween(whiteBG ,{alpha: 1}, 1, {startDelay: 3});
		add(whiteBG);
	
		clarification = new FlxText(0, 70, 500, "Hello Player, Before Playing The Mod I Must Clarify For You Some Things:\n\n\n1 - This Is A Cancelled Build Of An Old TBS Modification Called \"Untitled Basement Show Retake\" Due The Creator Becoming An Official TBS Member, But Don't Worry Tho (Even Tho You Won't), The Mod Is Still Gonna Get Updated By The New Owner \"Juki\"\n\n\n2 - This Mod Is Not Official TBS (Obvious), But You May See Some Effects From Here In The Official Build\n\n\n3 - The Mod Has Some High CPU Usage Songs That Migh Kill Low-end PCs, So If You Have That Case Then I Highly Suggest For You To Play The Mod In The Lowwest FPS Cap That's Good For Your PC\n\n\n4 - The Mod Has Some Alot Of Effects Such As Flashing Lights, Screen Shakes & More That May Cause Epilepsy For Some Kind Of People\n\n\n5 - The Mod May Have Some Disturbing Content, So There's Some Chances That You May Get Uncomfortable, So You May Quit And Delete The Mod And Never Come Back If You Can't Take It.\n\n\n6 - The Next Menu Uses Shaders, So If You Don't Want Your Peformance To Get Low, I Highly Suggest To You Entering The Options By Pressing The \"O\" Key\n\n\n7 - You Should Check The Original Mod Incase You Have No Idea What's This Based From\n\n\n8 - Big Shoutout For JerryWannaRat, ChallsonOldWood, Maxplay Games & The Rest Of The TBS Team Members For The Original Project.\n\n\n\n\n        Thank You For Playing UBSR\n               Enjoy The Show\n\n\n                                - Mr Sropical");
		clarification.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		clarification.borderSize = 1.15;
		clarification.alpha = 0;
		FlxTween.tween(clarification,{alpha: 1}, 1, {startDelay: 3});
		clarification.screenCenter(X);
		add(clarification);
	
		warnTxt = new FlxText(0, 0, FlxG.width, "README");
		warnTxt.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnTxt.borderSize = 1.15;
		warnTxt.scale.set(3, 3);
		warnTxt.angle = -5;
		warnTxt.y = -720;
		warnTxt.screenCenter(X);
		add(warnTxt);
	
		enterTxt = new FlxText(0, 700, FlxG.width, "Up/Down = Moving\nEnter = Play");
		enterTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		enterTxt.scrollFactor.set();
		enterTxt.borderSize = 1.15;
		add(enterTxt);
	
		oTxt = new FlxText(0, 750, FlxG.width, '"O" Key  = Options');
		oTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		oTxt.scrollFactor.set();
		oTxt.borderSize = 1.15;
		add(oTxt);
	
		FlxTween.tween(enterTxt,{y: 690}, 1, {startDelay: 3});
		FlxTween.tween(oTxt,{y: 660}, 1, {startDelay: 3});
		
		FlxTween.tween(warnTxt,{y: 320}, 2, {ease: FlxEase.backInOut});
		FlxTween.tween(warnTxt,{y: 0}, 1, {startDelay: 3});
		FlxTween.tween(warnTxt,{angle: 5}, 3, {type: PINGPONG, startDelay: 2});
		FlxTween.color(warnTxt, 2.6, FlxColor.WHITE, FlxColor.RED, {type: PINGPONG, startDelay: 2});
		FlxTween.tween(warnTxt.scale,{x: 1, y: 1}, 1, {startDelay: 3});

		checker = new FlxBackdrop(Paths.image('menus/checker'));
		checker.velocity.y = 28;
		checker.scrollFactor.set();
		checker.alpha = 0;
		checker.updateHitbox();
		checker.screenCenter();
        add(checker);
	}

	var intese:Float = 1;
	override function update(elapsed:Float)
	{
		if(leftState) {
			super.update(elapsed);
			return;
		}

		oTxt.alpha = enterTxt.alpha = FlxMath.lerp(oTxt.alpha, (FlxG.camera.scroll.y < 260 ? 0.3 : 1), 0.1);

		if (oTxt.alpha > 0.9) {
			canEnter = true;
		}
		else {
			canEnter = false;
		}

		intese = (FlxG.keys.pressed.SHIFT ? 3 : 1);
		if (FlxG.keys.pressed.DOWN && FlxG.camera.scroll.y < 280) {
			FlxG.camera.scroll.y += 1 * intese;
		}
		if (FlxG.keys.pressed.UP && FlxG.camera.scroll.y > 0) {
			FlxG.camera.scroll.y -= 1 * intese;
		}

		if (FlxG.keys.pressed.O && canEnter) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingOptionsState());
			}
			if (controls.ACCEPT && canEnter) {
				FlxTween.tween(checker, {alpha: 1}, 1);
				ClientPrefs.data.fromFlash = false;
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				ClientPrefs.saveSettings();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxFlicker.flicker(clarification, 1, 0.1, false, true, function(flk:FlxFlicker) {
					new FlxTimer().start(0.5, function (tmr:FlxTimer) {
						FlxTween.tween(warnTxt, {alpha: 0}, 0.2, {
							onComplete: (_) -> MusicBeatState.switchState(new TitleState())
						});
					});
				});
			}

			super.update(elapsed);
}
}