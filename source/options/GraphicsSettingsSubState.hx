package options;

import options.OptionsState;
import objects.Character;
import openfl.filters.ShaderFilter;
import shaders.tbs.Monitor;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var antialiasingOption:Int;
	var boyfriend:Character = null;
	public function new()
	{
		title = Language.getPhrase('graphics_menu', 'Graphics Settings');
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		boyfriend = new Character(650, 140, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.holdTimer = 4;
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing',
			BOOL);
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		antialiasingOption = optionsArray.length-1;

		var option:Option = new Option('Intense Shaders', //Name
		"If unchecked, disables intense shaders.\nIt's used for some visual effects, and affects cpu more than the regular ones which gives you less fps.", //Description
		'ishaders',
		BOOL);
	    addOption(option);
 

		var option:Option = new Option('Shaders', //Name
			"If unchecked, disables shaders.\nIt's used for some visual effects, and also CPU intensive for weaker PCs.", //Description
			'shaders',
			BOOL);
		option.onChange = shaderChange;
		addOption(option);

		var option:Option = new Option('Trails', //Name
		'If checked, some elements of the game will have trails.', //Description
		'leTrail', //Save data variable name
		BOOL); //Variable type
	    addOption(option);

		var option:Option = new Option('GPU Caching', //Name
			"If checked, allows the GPU to be used for caching textures, decreasing RAM usage.\nDon't turn this on if you have a shitty Graphics Card.", //Description
			'cacheOnGPU',
			BOOL);
		addOption(option);

		super();
		insert(1, boyfriend);
	}

	function shaderChange() {
		if(ClientPrefs.data.shaders)
		{
		FlxG.camera.setFilters([new ShaderFilter(OptionsState.monitor)]);
		}
	    else {
		FlxG.camera.setFilters([]);
		}
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.justPressed('note_left'))
			{
				boyfriend.playAnim('singLEFT');
			}
			if (controls.justPressed('note_down'))
			{
				boyfriend.playAnim('singDOWN');
			}
			if (controls.justPressed('note_up'))
			{
			boyfriend.playAnim('singUP');
			}
			if (controls.justPressed('note_right'))
			{
			boyfriend.playAnim('singRIGHT');
			}
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}
}