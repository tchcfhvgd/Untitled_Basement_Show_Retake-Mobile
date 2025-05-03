package states;

import states.TitleState;
import states.TitleState.TitleData;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import states.TitleState;
import openfl.filters.ShaderFilter;
import shaders.tbs.Monitor;

enum MainMenuColumn {
	LEFT;
	CENTER;
	RIGHT;
}

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var curColumn:MainMenuColumn = LEFT;
	var allowMouse:Bool = true; //Turn this off to block mouse movement in menus

	var cinematicBar1:FlxSprite;
	var cinematicBar2:FlxSprite;
	var monitor:Monitor = new Monitor();

	var char:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var leftItem:FlxSprite;
	var rightItem:FlxSprite;

	var descTxt:FlxText;

	var lolTxt:FlxText;

	var sTxt:FlxText;

	//Centered/Text options
	var optionShit:Array<String> = [
		'story_mode',
		//'freeplay',
		'credits',
		'options',
		'achievements'
	];

	var splashes:Array<String> = [
		"Semi-Official?",
		"I Wish I Added This In TBS 2.6 :(",
		"I. AM JERRY",
		"Imagine A Mobile Port",
		"I\"m a random text",
		"Will you be my vanishing?",
		"Only In Ohio",
		"MAX GET THE SWEET AND SOUR SAUCE NOT BARBECUE-",
		"error: Null Object Refrence",
		"zero on da bus go vanish vanish vanish",
		"Hey Max Can I Join TBS-",
		"IS THIS A MINECRAFT SPLASH REFRENCE?!!!!??!?",
		"Only A Silly Little Baby Will Fall For That Old Trick",
		"Lil' Bro Was Born In 2024",
		"The Basement Show, Avaible In PS4/5!",
		"Codename Engine My Beloved",
		"Did You Know That This Splash Is Random?",
		"Thug",
		"CoolSwag",
		"I Am Pressing Notes 'n Shit Cuz I'm In Fucking FNF",
		"<Insert Unfunny Quote Here>",
		"Chainsaw Maniac? More Like Aw Shucks!",
		"No Patrick, The Mod Is Not Discontinued",
		"เฉพาะเกมแม็กซ์เพลย์เท่านั้นที่สามารถอ่านข้อความนี้ได้",
		"فلسروي كاف",
		"Yo Soy Luigi, MamaMia, Luigi.exe, Soy Amigos De Mario Madneeess",
		"YOU'RE DOING THIS TILL YOU'RE 5AE0",
		"WHOA WHAT THE HECK IS THAT? SO SOY JERRY, MAMMAMIA-",
		"You've Found A Red Text\nNow You Get Nothing :)",
		"OMG MY KNIFE IS LIKE SHI-"
	];

	var camFollow:FlxObject;

	var modLogo:FlxSprite;

	static var showOutdatedWarning:Bool = true;
	override function create()
	{
		super.create();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("🗺️ - In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		openfl.Lib.application.window.title = "Untitled Basement Show Retake: Refreshed | Main Menu";

		var yScroll:Float = 0.25;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menus/menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll/3);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (num => option in optionShit)
		{
			var item:FlxSprite = createMenuItem(option, -520, (num * 350) + 90);
			item.y += (4 - optionShit.length) * 70; // Offsets for when you have anything other than 4 items
		}

		modLogo = new FlxSprite(600).loadGraphic(Paths.image('menus/loading_screen/icon'));
		modLogo.antialiasing = ClientPrefs.data.antialiasing;
		modLogo.scale.set(0.75, 0.75);
		modLogo.scrollFactor.set();
		modLogo.screenCenter(Y);
		add(modLogo);

		sTxt = new FlxText(0, 475, FlxG.width, splashes[FlxG.random.int(0, splashes.length - 1)], 12);
		sTxt.screenCenter(X);
		sTxt.x += 300;
		sTxt.scrollFactor.set();
		sTxt.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(sTxt);

		switch(sTxt.text)
		{
			case "You've Found A Red Text\nNow You Get Nothing :)": sTxt.color = FlxColor.RED;
			case "เฉพาะเกมแม็กซ์เพลย์เท่านั้นที่สามารถอ่านข้อความนี้ได้": sTxt.font = Paths.font("splashes/thai.ttf");
			case "فلسروي كاف": sTxt.font = Paths.font("splashes/arabic.ttf");
		}

		for (i in 0...2) {
			var cinematicBar = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			cinematicBar.scrollFactor.set();
			add(cinematicBar);
	
			cinematicBar.scale.set(FlxG.width, (FlxG.height/2) * 0.2);
			cinematicBar.updateHitbox();
	
			if (i == 1) cinematicBar2 = cinematicBar;
			else cinematicBar1 = cinematicBar;
		}

		for (bar in [cinematicBar1, cinematicBar2]) bar.updateHitbox();
		cinematicBar2.y = FlxG.height - cinematicBar2.height + 3;
		cinematicBar1.y = -2;

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Untitled Basement Show Retake: Cancelled Build", 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat(Paths.font("tbs.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Slop Engine 1.0.3 (Psych Engine Modified)", 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Paths.font("tbs.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem();

		descTxt = new FlxText(12, 20, FlxG.width, "", 12);
		descTxt.screenCenter(X);
		descTxt.scrollFactor.set();
		descTxt.setFormat(Paths.font("tbs.ttf"), 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(descTxt);

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		#if CHECK_FOR_UPDATES
		if (showOutdatedWarning && ClientPrefs.data.checkForUpdates && substates.OutdatedSubState.updateVersion != psychEngineVersion) {
			persistentUpdate = false;
			showOutdatedWarning = false;
			openSubState(new substates.OutdatedSubState());
		}
		#end

		lolTxt = new FlxText(12, 20, FlxG.width, "Congratulations!\nYou're Now Officialy A Dumbass Cheater.", 12);
		lolTxt.screenCenter();
		lolTxt.alpha = 0;
		lolTxt.scrollFactor.set();
		lolTxt.setFormat(Paths.font("vcr.ttf"), 45, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(lolTxt);

		FlxG.camera.follow(camFollow, null, 0.1);

		OptionsState.isPressed = false;
		OptionsState.ableSelect = true;

		if(ClientPrefs.data.shaders)
		{
		FlxG.camera.setFilters([new ShaderFilter(monitor)]);
		}
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite(x, y);
		menuItem.frames = Paths.getSparrowAtlas('menus/mainmenu/menu_$name');
		menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
		menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
		menuItem.scale.set(0.8, 0.8);
		menuItem.animation.play('idle');
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.antialiasing;
		menuItems.add(menuItem);
		return menuItem;
	}

	var selectedSomethin:Bool = false;
	var pressed:Bool = false;
	var fullyPressed:Bool = false;

	var timeNotMoving:Float = 0;
	var tottalTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			var allowMouse:Bool = allowMouse;
			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				allowMouse = false;
				FlxG.mouse.visible = true;
				timeNotMoving = 0;

				var selectedItem:FlxSprite;
						selectedItem = menuItems.members[curSelected];
				if(leftItem != null && FlxG.mouse.overlaps(leftItem))
				{
					allowMouse = true;
					if(selectedItem != leftItem)
					{
						curColumn = LEFT;
						changeItem();
					}
				}
				else if(rightItem != null && FlxG.mouse.overlaps(rightItem))
				{
					allowMouse = true;
					if(selectedItem != rightItem)
					{
						curColumn = RIGHT;
						changeItem();
					}
				}
				else
				{
					var dist:Float = -1;
					var distItem:Int = -1;
					for (i in 0...optionShit.length)
					{
						var memb:FlxSprite = menuItems.members[i];
						if(FlxG.mouse.overlaps(memb))
						{
							var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
							if (dist < 0 || distance < dist)
							{
								dist = distance;
								distItem = i;
								allowMouse = true;
							}
						}
					}

					if(distItem != -1 && selectedItem != menuItems.members[distItem])
					{
						curColumn = CENTER;
						curSelected = distItem;
						changeItem();
					}
				}
			}
			else
			{
				timeNotMoving += elapsed;
				if(timeNotMoving > 2) FlxG.mouse.visible = false;
			}

			switch(curColumn)
			{
				case CENTER:
					if(controls.UI_LEFT_P)
					{
						curColumn = LEFT;
					}
					else if(controls.UI_RIGHT_P)
					{
						curColumn = RIGHT;
					}

				case LEFT:
					if(controls.UI_RIGHT_P)
					{
						curColumn = CENTER;
						changeItem();
					}

				case RIGHT:
					if(controls.UI_LEFT_P)
					{
						curColumn = CENTER;
						changeItem();
					}
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
				TitleState.theEnd = true;
			}
			tottalTime += elapsed;
			modLogo.angle = Math.sin(tottalTime*2);
			sTxt.angle = Math.sin(tottalTime*4);

			switch(optionShit[curSelected]) {
				case 'story_mode':
					descTxt.text = 'Watch your favorite episodes in a new look!';
				//case 'freeplay':
			//		descTxt.text = 'Have fun with some new & old friends!';
				#if ACHIEVEMENTS_ALLOWED
				case 'achievements':
					descTxt.text = 'Look at your own new awards you\'ve got!';
				#end
				case 'credits':
					descTxt.text = 'Meet the person behind this!';
				case 'options':
					descTxt.text = 'Check your options. simple.';
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse))
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				selectedSomethin = true;
				FlxG.mouse.visible = false;

				var item:FlxSprite;
				var option:String;
				option = optionShit[curSelected];
				item = menuItems.members[curSelected];
				
				FlxTween.tween(FlxG.camera, {zoom: 2.1}, 2, {ease: FlxEase.expoInOut});

				FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					switch (option)
					{
						case 'story_mode':
							MusicBeatState.switchState(new StoryMenuState());
						case 'freeplay':
							MusicBeatState.switchState(new FreeplayState());

						#if MODS_ALLOWED
						case 'mods':
							MusicBeatState.switchState(new ModsMenuState());
						#end

						#if ACHIEVEMENTS_ALLOWED
						case 'achievements':
							MusicBeatState.switchState(new AchievementsMenuState());
						#end

						case 'credits':
							MusicBeatState.switchState(new TBSCreditsState());
						case 'options':
							MusicBeatState.switchState(new OptionsState());
							OptionsState.onPlayState = false;
							if (PlayState.SONG != null)
							{
								PlayState.SONG.arrowSkin = null;
								PlayState.SONG.splashSkin = null;
								PlayState.stageUI = 'normal';
							}
						case 'donate':
							CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
							selectedSomethin = false;
							item.visible = true;
						default:
							trace('Menu Item ${option} doesn\'t do anything');
							selectedSomethin = false;
							item.visible = true;
					}
				});
				
				for (memb in menuItems)
				{
					if(memb == item)
						continue;

					FlxTween.tween(memb, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				}
			}
			#if desktop
			if (controls.justPressed('debug_1') && ClientPrefs.data.cheatOn)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		if (char == 0) pressed = FlxG.keys.justPressed.S;
		if (char == 1) pressed = FlxG.keys.justPressed.I;
		if (char == 2) pressed = FlxG.keys.justPressed.G;
		if (char == 3) pressed = FlxG.keys.justPressed.M;
		if (char == 4) {
		fullyPressed = true;
		pressed = FlxG.keys.justPressed.A;
		}
		if (pressed) {
			char += 1;
		}
		if (fullyPressed && !ClientPrefs.data.cheatOn) {
			trace('Officialy A Cheater');
			lolTxt.alpha = 1;
			FlxTween.tween(lolTxt, {alpha: 0}, 4);
			ClientPrefs.data.cheatOn = true;
		}
	}

	function changeItem(change:Int = 0)
	{
		if(change != 0) curColumn = CENTER;
		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'));

		for (item in menuItems)
		{
			item.animation.play('idle');
			item.centerOffsets();
		}

		var selectedItem:FlxSprite;
				selectedItem = menuItems.members[curSelected];
		selectedItem.animation.play('selected');
		selectedItem.centerOffsets();
		camFollow.y = selectedItem.getGraphicMidpoint().y-40;
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	override function beatHit()
	{
		super.beatHit();

		sickBeats++;
		
		if (sickBeats % 4 == 0) {
			FlxTween.tween(sTxt.scale, {y: 1.2, x: 1.2}, 1, {ease: FlxEase.quadOut});
		}
		else if (sickBeats % 4 == 2) {
			FlxTween.tween(sTxt.scale, {y: 1, x: 1}, 1, {ease: FlxEase.quadOut});
		}

		modLogo.scale.set(0.8, 0.8);
		FlxTween.tween(modLogo.scale, {y: 0.75, x: 0.75}, 0.3, {ease: FlxEase.quadOut});
	}
}
