package options;

import states.FlashingState;
import backend.StageData;

class FlashingOptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Controls',
		'Accecability'
		#if TRANSLATIONS_ALLOWED , 'Language' #end
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;

	function openSelectedSubstate(label:String) {
		switch(label)
		{
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Accecability':
				openSubState(new options.AccessSubState());
			case 'Language':
				openSubState(new options.LanguageSubState());
		}
	}

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("First Time Mod", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xff000000;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (num => option in options)
		{
			var optionText:Alphabet = new Alphabet(0, 0, Language.getPhrase('options_$option', option), true);
			optionText.screenCenter(Y);
			optionText.y += (100 * (num - (options.length / 2))) + 50;
			optionText.x -= 1000;
			FlxTween.tween(optionText, {x: optionText.x + 1010}, 1, {ease: FlxEase.elasticInOut});
			grpOptions.add(optionText);
		}

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

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.BACK)
		{
        MusicBeatState.switchState(new FlashingState());
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelected;
			item.color = FlxColor.WHITE;
			if (item.targetY == 0)
			{
				item.color = FlxColor.YELLOW;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}