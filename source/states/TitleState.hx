package states;

import backend.WeekData;

import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;
import flixel.addons.display.FlxBackdrop;
import openfl.filters.ShaderFilter;
import shaders.tbs.Monitor;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.MainMenuState;

typedef TitleData =
{
	var titlex:Float;
	var titley:Float;
	var startx:Float;
	var starty:Float;
	var gfx:Float;
	var gfy:Float;
	var backgroundSprite:String;
	var bpm:Float;
	
	@:optional var animation:String;
	@:optional var dance_left:Array<Int>;
	@:optional var dance_right:Array<Int>;
	@:optional var idle:Bool;
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var fadeScreen:FlxSprite;
	var rTxt:FlxText;
	var monitor:Monitor = new Monitor();

	var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxGroup = new FlxGroup();
	var blackScreen:FlxSprite;
	var credTextShit:Alphabet;
	var ngSpr:FlxSprite;

	var enterTxt:FlxText;

	var modBanner:FlxSprite;
	var modLogo:FlxSprite;
	var modLogo2:FlxSprite;
	var checker:FlxBackdrop;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	public static var theEnd:Bool = false;

	#if TITLE_SCREEN_EASTER_EGG
	final easterEggKeys:Array<String> = [
		'SHADOW', 'RIVEREN', 'BBPANZU', 'PESSY'
	];
	final allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		if(!initialized)
		{
			ClientPrefs.loadPrefs();
			Language.reloadPhrases();
		}

		curWacky = FlxG.random.getObject(getIntroTextShit());

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
			startIntro();
		#end
	}

	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		persistentUpdate = true;
		if (!initialized && FlxG.sound.music == null)
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);

		Conductor.bpm = 100;
		
		if(ClientPrefs.data.shaders)
		{
			swagShader = new ColorSwap();
		}


		var animFrames:Array<FlxFrame> = [];

		ClientPrefs.data.framerate = 60;

		blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width, FlxG.height);
		blackScreen.updateHitbox();
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('menus/titlescreen/newgrounds_logo'));
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		modBanner = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/titlescreen/modBanner'));
		modBanner.antialiasing = true;
		modBanner.screenCenter();

		modLogo = new FlxSprite(255, 300).loadGraphic(Paths.image('menus/titlescreen/TBSLogoBlank'));
		modLogo.y -= 1000;
		modLogo.scale.set(0.8, 0.8);
		modLogo.antialiasing = true;

		modLogo2 = new FlxSprite(255, 300).loadGraphic(Paths.image('menus/titlescreen/TBSLogoBlank'));
		modLogo2.scale.set(0.8, 0.8);
		modLogo2.antialiasing = true;
		modLogo2.visible = false;

		enterTxt = new FlxText(12, 20, FlxG.width, "Press Enter To Play", 12);
		enterTxt.screenCenter(X);
		enterTxt.setFormat(Paths.font("tbs.ttf"), 40, 0xFF883B00, CENTER);
		FlxTween.color(enterTxt, 2.6, 0xFF883B00, 0xFF484B7D, {type: PINGPONG});

		rTxt = new FlxText(12, 550, FlxG.width, "", 12);
		rTxt.screenCenter(X);
		rTxt.setFormat(Paths.font("tbs.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(modBanner);
		add(enterTxt);
		add(credGroup);

		checker = new FlxBackdrop(Paths.image('menus/checker'));
		checker.velocity.y = 28;
		checker.scrollFactor.set();
		checker.updateHitbox();
		checker.screenCenter();
        add(checker);
		add(textGroup);
		add(rTxt);
		add(ngSpr);

		var randomie:Array<String> = 
		[
			'Sigma Menu',
			'Random Text Menu',
			'Spitting Facts',
			'Skip If You Want',
			'Welcome In',
			'Waiting till Picking Ya Poison',
			'https://www.youtube.com/watch?v=H8ZH_mkfPUY',
			'GTFO I\'M PLAYING MINECRAFT',
			'Buy The House',
			'Sonic.exe But Replaced With Jerry',
			'You Should Play The Original Mod!',
			' E ',
			'5 Little Breath Sans Cousins Jumping On Da Bed',
			'Now Playing: Who asked - By: Nobody',
			'freddy fazebar',
			'This Mod Sure Has Game Crashing Oh Wait Fu-',
			'Touch Grass.',
			'Pear Jerry Is Coming...',
			'I ate your doorframe.',
			'I Am Jerry. I Am Murderous',
			'That Is So Funkin.avi',
			'Y\'all remember that show that\'s called "Jom & Terry", right?',
			'TileState.hx',
			'Title Menu',
			'-ƧꓭT nioႱ I nɒƆ'
		];
		openfl.Lib.application.window.title = 'Untitled Basement Show Retake: Refreshed | ' + randomie[FlxG.random.int(0,randomie.length-1)]+ '';

		if (openfl.Lib.application.window.title == 'Untitled Basement Show Retake: Refreshed | Pear Jerry Is Coming...') {
			var daPear:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/titlescreen/thepeakestimageinexistence'));
			daPear.antialiasing = true;
			daPear.screenCenter();
			daPear.alpha = 0;
			add(daPear);
			new FlxTimer().start(2, function(tmr:FlxTimer){
			FlxG.sound.play(Paths.sound('VineBoom'));
			});
			FlxTween.tween(daPear, {alpha: 1}, 2, {ease: FlxEase.sineInOut, startDelay: 2, type: FlxTweenType.BACKWARD});
		}

		if (openfl.Lib.application.window.title == 'Untitled Basement Show Retake: Refreshed | This Mod Sure Has Game Crashing Oh Wait Fu-') {
			new FlxTimer().start(1, function(tmr:FlxTimer){
	      	Sys.exit(0);
			});
		}

		if (initialized) {
			skipIntro();
		}
		else {initialized = true;}

		// credGroup.add(credTextShit);

		add(modLogo);
		add(modLogo2);

		fadeScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		fadeScreen.alpha = 0;
		fadeScreen.scrollFactor.set();
		add(fadeScreen);

		if(ClientPrefs.data.shaders)
		{
		FlxG.camera.setFilters([new ShaderFilter(monitor)]);
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
			}
			
			if(pressedEnter)
			{

				FlxTween.tween(fadeScreen, {alpha: 1}, 1);
				FlxTween.tween(FlxG.camera, {zoom: 2}, 1);
				FlxTween.tween(FlxG.camera.scroll, {y: FlxG.camera.scroll.y + 120}, 1);
				FlxG.camera.flash(0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(2.5, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
			#if TITLE_SCREEN_EASTER_EGG
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if(allowedKeys.contains(keyName)) {
					easterEggKeysBuffer += keyName;
					if(easterEggKeysBuffer.length >= 32) easterEggKeysBuffer = easterEggKeysBuffer.substring(1);
					//trace('Test! Allowed Key pressed!!! Buffer: ' + easterEggKeysBuffer);

					for (wordRaw in easterEggKeys)
					{
						var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
						if (easterEggKeysBuffer.contains(word))
						{
							//trace('YOOO! ' + word);
							if (FlxG.save.data.psychDevsEasterEgg == word)
								FlxG.save.data.psychDevsEasterEgg = '';
							else
								FlxG.save.data.psychDevsEasterEgg = word;
							FlxG.save.flush();

							FlxG.sound.play(Paths.sound('secret'));

							var black:FlxSprite = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
							black.scale.set(FlxG.width, FlxG.height);
							black.updateHitbox();
							black.alpha = 0;
							add(black);

							FlxTween.tween(black, {alpha: 1}, 1, {onComplete:
								function(twn:FlxTween) {
									FlxTransitionableState.skipNextTransIn = true;
									FlxTransitionableState.skipNextTransOut = true;
									MusicBeatState.switchState(new TitleState());
								}
							});
							FlxG.sound.music.fadeOut();
							if(FreeplayState.vocals != null)
							{
								FreeplayState.vocals.fadeOut();
							}
							closedState = true;
							transitioning = true;
							playJingle = true;
							easterEggKeysBuffer = '';
							break;
						}
					}
				}
			}
			#end
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			FlxTween.tween(modLogo, {y: modLogo.y + 1000}, 0.5, {ease: FlxEase.quadOut});
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i => text in textArray) {
			if (text == "" || text == null) continue;
			var money = new FlxText(0, (i * 90) + 200, FlxG.width, text, 19, true);
			money.setFormat(Paths.font("tbs.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			money.scrollFactor.set();
			money.borderSize = 3;
			money.screenCenter(X);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText = new FlxText(0, (textGroup.length * 90) + 200, FlxG.width, text, 19, true);
		coolText.setFormat(Paths.font("tbs.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		coolText.scrollFactor.set();
		coolText.borderSize = 3;
		coolText.screenCenter(X);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		sickBeats++;

	    if (sickBeats > 17 || modLogo2.visible == true || fadeScreen.alpha < 0) {
			if (sickBeats % 2 == 1) {
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.05}, 0.3, {ease: FlxEase.quadOut, type: FlxTweenType.BACKWARD});
			}
			else if (sickBeats % 2 == 0) {
			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.15}, 0.3, {ease: FlxEase.quadOut, type: FlxTweenType.BACKWARD});
			}
		}

		FlxTween.tween(modLogo2.scale, {y: 0.9, x: 0.9}, 0.3, {ease: FlxEase.quadOut, type: FlxTweenType.BACKWARD});
		FlxTween.tween(modLogo.scale, {y: 0.9, x: 0.9}, 0.3, {ease: FlxEase.quadOut, type: FlxTweenType.BACKWARD});
	}

	override function stepHit()
		{
			super.stepHit();
	
			if (!closedState)
			{
				switch (curStep)
				{
					case 4:
						createCoolText(['Mod By']);
					// credTextShit.visible = true;
					case 12:
						addMoreText('MrSropical');
					// credTextShit.text += '\npresent...';
					// credTextShit.addText();
					case 16:
						deleteCoolText();
					// credTextShit.visible = false;
					// credTextShit.text = 'In association \nwith';
					// credTextShit.screenCenter();
					case 20:
						createCoolText(['Originally Created By']);
					case 28:
						addMoreText('TBS TEAM');
					// credTextShit.text += '\nNewgrounds';
					case 31:
						addMoreText('(too lazy to add them :()');
					case 32:
						deleteCoolText();
					// credTextShit.visible = false;
	
					// credTextShit.text = 'Shoutouts Tom Fulp';
					// credTextShit.screenCenter();
					case 36:
						createCoolText([curWacky[0]]);
					// credTextShit.visible = true;
					case 44:
						addMoreText(curWacky[1]);
					// credTextShit.text += '\nlmao';
					case 48:
						deleteCoolText();
					// credTextShit.visible = false;
					// credTextShit.text = "Friday";
					// credTextShit.screenCenter();
					case 52:
						if (!skippedIntro) FlxTween.tween(modLogo, {y: modLogo.y + 800}, 0.5, {ease: FlxEase.quadOut});
					case 60:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.1}, 0.5, {ease: FlxEase.expoOut});
						rTxt.text += 'Re';
					case 62:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.1}, 0.5, {ease: FlxEase.expoOut});
						rTxt.text += 'Ta';
					case 64:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.1}, 0.5, {ease: FlxEase.expoOut});
						rTxt.text += 'Ke';
					case 68:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.3}, 0.5, {ease: FlxEase.expoOut});
						skipIntro();
				}
			}
		}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		FlxTween.tween(modLogo, {y: modLogo.y + 1000}, 0.5, {ease: FlxEase.quadOut});
		textGroup.visible = false;
		checker.destroy();
		rTxt.destroy();

		modLogo.visible = false;
		modLogo2.visible = true;

		if (!skippedIntro)
		{
			FlxTween.tween(modLogo, {y: modLogo.y + 200}, 0.5, {ease: FlxEase.quadOut});
			#if TITLE_SCREEN_EASTER_EGG
			if (playJingle) //Ignore deez
			{
				playJingle = false;
				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();

				var sound:FlxSound = null;
				switch(easteregg)
				{
					case 'RIVEREN':
						sound = FlxG.sound.play(Paths.sound('JingleRiver'));
					case 'SHADOW':
						FlxG.sound.play(Paths.sound('JingleShadow'));
					case 'BBPANZU':
						sound = FlxG.sound.play(Paths.sound('JingleBB'));
					case 'PESSY':
						sound = FlxG.sound.play(Paths.sound('JinglePessy'));

					default: //Go back to normal ugly ass boring GF
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 2);
						skippedIntro = true;

						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						return;
				}

				transitioning = true;
				if(easteregg == 'SHADOW')
				{
					new FlxTimer().start(3.2, function(tmr:FlxTimer)
					{
						remove(ngSpr);
						remove(credGroup);
						FlxG.camera.flash(FlxColor.WHITE, 0.6);
						transitioning = false;
					});
				}
				else
				{
					remove(ngSpr);
					remove(credGroup);
					FlxG.camera.flash(FlxColor.WHITE, 3);
					sound.onComplete = function() {
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxG.sound.music.fadeIn(4, 0, 0.7);
						transitioning = false;
						#if ACHIEVEMENTS_ALLOWED
						if(easteregg == 'PESSY') Achievements.unlock('pessy_easter_egg');
						#end
					};
				}
			}
			else #end //Default! Edit this one!!
			{
				if (theEnd) FlxTween.tween(modLogo, {y: modLogo.y + 1000}, 0.5, {ease: FlxEase.quadOut});
				remove(ngSpr);
				remove(credGroup);
				FlxG.camera.flash(FlxColor.WHITE, 4);

				theEnd = true;

				var easteregg:String = FlxG.save.data.psychDevsEasterEgg;
				if (easteregg == null) easteregg = '';
				easteregg = easteregg.toUpperCase();
				#if TITLE_SCREEN_EASTER_EGG
				if(easteregg == 'SHADOW')
				{
					FlxG.sound.music.fadeOut();
					if(FreeplayState.vocals != null)
					{
						FreeplayState.vocals.fadeOut();
					}
				}
				#end
			}
			skippedIntro = true;
		}
	}
}
