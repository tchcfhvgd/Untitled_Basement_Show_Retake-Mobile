package options;

import haxe.display.Display.Package;
import states.MainMenuState;
import backend.StageData;
import flixel.addons.display.FlxBackdrop;
import openfl.filters.ShaderFilter;
import shaders.tbs.Monitor;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Note Colors',
		'Controls',
		'Gameplay',
		'Graphics',
		'Appearance'
		#if TRANSLATIONS_ALLOWED , 'Language' #end
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var isPressed:Bool = false;
	public static var onPlayState:Bool = false;

	public static var popTxt:FlxText;
	public static var dTxt:FlxText;
	public static var cinematicBar1:FlxSprite;

	public static var ableSelect:Bool = true;
	public static var monitor:Monitor = new Monitor();

	function openSelectedSubstate(label:String) {
		switch(label)
		{
			case 'Note Colors':
				openSubState(new options.NotesColorSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Appearance':
				openSubState(new options.VisualsSettingsSubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Language':
				openSubState(new options.LanguageSubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("⚙️ - Options Menu", null);
		#end

		ableSelect = true;

		var checker:FlxBackdrop = new FlxBackdrop(Paths.image('menus/checker'));
		checker.velocity.y = 28;
		checker.scrollFactor.set();
		checker.updateHitbox();
		checker.screenCenter();
        add(checker);

		cinematicBar1 = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		cinematicBar1.scrollFactor.set();
		cinematicBar1.alpha = 0.6;
		add(cinematicBar1);
	
		cinematicBar1.scale.set(FlxG.width, (FlxG.height/2) * 0.25);
		cinematicBar1.updateHitbox();

		for (bar in [cinematicBar1]) bar.updateHitbox();
		cinematicBar1.y = -2;

		popTxt = new FlxText(0, 20, FlxG.width, 'Appearance Settings', 20);
		popTxt.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		popTxt.borderSize = 2.2;
		popTxt.scrollFactor.set();
		popTxt.screenCenter(X);
		add(popTxt);

		dTxt = new FlxText(0, 50, FlxG.width, 'Edit The Way The Game Looks To Be The Best For You In The Game Like HUD, Notes...', 20);
		dTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dTxt.borderSize = 2.2;
		dTxt.scrollFactor.set();
		dTxt.screenCenter(X);
		add(dTxt);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (num => option in options)
		{
			var optionText:Alphabet = new Alphabet(0, 0, Language.getPhrase('options_$option', option), true);
			optionText.screenCenter();
			optionText.y += (92 * (num - (options.length / 2))) + 65;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		openfl.Lib.application.window.title = "Untitled Basement Show Retake: Refreshed | Options Menu - In " + options[curSelected];

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else MusicBeatState.switchState(new MainMenuState());
		}
		else if (controls.ACCEPT && !isPressed) {
		ableSelect = false;
		FlxTween.tween(FlxG.camera.scroll, {x: 1000}, 0.3, {ease: FlxEase.quadOut});
		isPressed = true;
		new FlxTimer().start(0.5, function(tmr:FlxTimer){
		openSelectedSubstate(options[curSelected]);
		});
		}

		popTxt.text = options[curSelected] + ' Settings';

		switch(options[curSelected])
		{
			case 'Note Colors':
				dTxt.text = 'Not Liking Your Notes Color? Change Them.';
			case 'Controls':
				dTxt.text = 'Edit The Ways Of Travelling In The Game.';
			case 'Graphics':
				dTxt.text = 'If Having A Bad PC, Change Some Performance To Make It Compatble With Your PC...';
			case 'Appearance':
                dTxt.text = 'Edit The Way The Game Looks To Be The Best For You In The Game Like HUD, Notes...';
			case 'Gameplay':
				dTxt.text = 'Edit The Style You Want To Play The Game Like Downscroll, Scroll Speed...';
		}

		if(ClientPrefs.data.shaders)
		{
		FlxG.camera.setFilters([new ShaderFilter(monitor)]);
		}
		else {
		FlxG.camera.setFilters([]);
		}
	}
	
	function changeSelection(change:Int = 0)
	{
	if (ableSelect) {
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}