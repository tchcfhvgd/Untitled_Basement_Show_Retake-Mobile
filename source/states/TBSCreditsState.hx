package states;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import states.CreditsState;
import openfl.filters.ShaderFilter;
import shaders.tbs.Monitor;

class TBSCreditsState extends MusicBeatState
{
	var curSelected:Int = 1;
	var defaultList:Array<Array<Dynamic>> = [ //Name - Icon name - Description - Link - BG Color
		["Mr Sropical",		 "sropical",	"Former Owner, Mod Creator",	         "Kind Of Expected Huh, Anyway Thank You For Playing The Mod, And Hope You Enjoyed This Little Project, And I Sure Hope You Did, If Else...I Won\'t Do Anything About It\'s Your Opinion.","https://ko-fi.com/shadowmario"],
		["Juki-erik",        "juki",		        "Owner, Future Updates Maker",	     "He May Did Nothing In This Update, But He'll Do In The Next Updates More After My Retiring",				                                                                               "https://ko-fi.com/shadowmario"]
	];
	
	var creditGuys:FlxSpriteGroup = new FlxSpriteGroup();

    var monitor:Monitor = new Monitor();
	
	var back:FlxSprite;
	var weird:FlxSprite;
	var effect1:FlxSprite;
	var effect2:FlxSprite;
	var effect3:FlxSprite;
	var button1:FlxSprite;
	var button2:FlxSprite;
	
	var nameTxt:FlxText;
	var roleTxt:FlxText;
	var descTxt:FlxText;
	var secTxt:FlxText;

	var grid:FlxBackdrop;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		weird = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/menuDesat'));
		weird.alpha = 0.5;
		weird.antialiasing = ClientPrefs.data.antialiasing;
		add(weird);

		grid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x1AFFFFFF, 0x0));
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		grid.velocity.set(40, 10);
		add(grid);
	
		back = new FlxSprite(90,-2).loadGraphic(Paths.image('menus/credits/backBG'));
		back.antialiasing = ClientPrefs.data.antialiasing;
		back.scale.set(1.6,1.58);
		add(back);
	
		add(creditGuys);
	
		for (i in 0...defaultList.length) {
		var creditGuy:FlxSprite = new FlxSprite(150, 200).loadGraphic(Paths.image('credits/' + defaultList[i][1]));
		creditGuy.antialiasing = true;
		creditGuy.screenCenter(Y);
		creditGuy.ID = i;
		creditGuy.alpha = 0;
		creditGuy.scale.set(1.5,1.5);
		creditGuys.add(creditGuy);
		}
	
		button1 = new FlxSprite(230, 80).loadGraphic(Paths.image('menus/story_mode/button'));
		add(button1);
	
		button2 = new FlxSprite(230, 580).loadGraphic(Paths.image('menus/story_mode/button'));
		button2.angle = 180;
		add(button2);
	
		secTxt = new FlxText(100, 25, FlxG.width, "< Section 1: UBSR Credits >");
		secTxt.setFormat(Paths.font("tbs.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		secTxt.borderSize = 1.25;
		secTxt.screenCenter(X);
		secTxt.alpha = 0.6;
		add(secTxt);
	
		nameTxt = new FlxText(660, 125, 1000, "Mr Sropical");
		nameTxt.setFormat(Paths.font("tbs.ttf"), 58, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nameTxt.borderSize = 2;
		add(nameTxt);
	
		roleTxt = new FlxText(660, 185, 1000, "Former Owner, Mod Creator");
		roleTxt.setFormat(Paths.font("tbs.ttf"), 38, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		roleTxt.borderSize = 2;
		add(roleTxt);
	
		descTxt = new FlxText(660, 245, 600, '"Kind Of Expected Huh, Anyway Thank You For Playing The Mod, And Hope You Enjoyed This Little Project, And I Sure Hope You Did, If Else...I Won\'t Do Anything About It\'s Your Opinion."');
		descTxt.setFormat(Paths.font("tbs.ttf"), 38, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descTxt.borderSize = 2;
		add(descTxt);
	
		effect1 = new FlxSprite().loadGraphic(Paths.image("menus/credits/light"));
		add(effect1);
		effect2 = new FlxSprite().loadGraphic(Paths.image("menus/credits/vignette"));
		add(effect2);

		changeSelection(1);

		super.create();

        if(ClientPrefs.data.shaders)
        {
        FlxG.camera.setFilters([new ShaderFilter(monitor)]);
        }
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

        if (controls.UI_LEFT_P || controls.UI_RIGHT_P) MusicBeatState.switchState(new CreditsState());

		if (controls.UI_DOWN_P) {
			button2.scale.set(1.35, 1.35);
			button2.color = FlxColor.WHITE;
			changeSelection(-1);
		}
		if (controls.UI_UP_P) {
			button1.scale.set(1.35, 1.35);
			button1.color = FlxColor.WHITE;
			changeSelection(1);
		}

		openfl.Lib.application.window.title = "Untitled Basement Show Retake: Refreshed | Credits Menu - Looking At " + defaultList[curSelected][0] + " From Credits";
	
		nameTxt.text = defaultList[curSelected][0];
		roleTxt.text = defaultList[curSelected][2];
		descTxt.text = '"' + defaultList[curSelected][3] + '"';

		if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
	
		creditGuys.forEach(function(spr:FlxSprite)
			{
				spr.alpha = FlxMath.lerp(spr.alpha, 0, 0.1);
	
				if (spr.ID == curSelected)
				{
				spr.alpha = FlxMath.lerp(spr.alpha, 1, 0.1);
				}
			});

		super.update(elapsed);

		button1.scale.y = button1.scale.x = FlxMath.lerp(button1.scale.x, 1, 0.2);
		button1.color = FlxColor.interpolate(button1.color, FlxColor.GRAY, 0.2);

		button2.scale.y = button2.scale.x = FlxMath.lerp(button2.scale.x, 1, 0.2);
		button2.color = FlxColor.interpolate(button2.color, FlxColor.GRAY, 0.2);
	}

	function changeSelection(change:Int)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected = FlxMath.wrap(curSelected + change, 0, defaultList.length-1);
	}
}
