package states;

import flixel.FlxObject;
import flixel.util.FlxSort;
import objects.Bar;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

#if ACHIEVEMENTS_ALLOWED
class AchievementsMenuState extends MusicBeatState
{
	public var curSelected:Int = 0;

	public var options:Array<Dynamic> = [];
	public var grpOptions:FlxSpriteGroup;
	public var textGroup:FlxSpriteGroup;
	public var nameText:FlxText;
	public var percBar:Bar;
	public var descText:FlxText;
	var percentTxt:FlxText;
	public var progressTxt:FlxText;
	public var progressBar:Bar;
	var gradientBar:FlxSprite = new FlxSprite(-9000, 0).makeGraphic(FlxG.width + 1000, 1, 0xFFFFFFFF);

	var camFollow:FlxObject;

	var MAX_PER_ROW:Int = 1;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		// prepare achievement list
		for (achievement => data in Achievements.achievements)
		{
			var unlocked:Bool = Achievements.isUnlocked(achievement);
			if(data.hidden != true || unlocked)
				options.push(makeAchievement(achievement, data, unlocked, data.mod));
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/menuBlack'));
		menuBG.antialiasing = ClientPrefs.data.antialiasing;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.2));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.scrollFactor.set(0,0.04);
		add(menuBG);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.scrollFactor.set(0, 0.04);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00000000,0xAAFFFFFF], 1, 90, true);
		gradientBar.y = 800;
		gradientBar.scrollFactor.set();
		gradientBar.updateHitbox();
		add(gradientBar);
		FlxTween.tween(gradientBar, {y: 250}, 1);

		grpOptions = new FlxSpriteGroup();
		grpOptions.scrollFactor.x = 0;

		openfl.Lib.application.window.title = "Untitled Basement Show Retake: Refreshed | Achievements Menu";
	
		textGroup = new FlxSpriteGroup();
		textGroup.scrollFactor.x = 0;

		options.sort(sortByID);
		for (option in options)
		{
			var hasAntialias:Bool = ClientPrefs.data.antialiasing;
			var graphic = null;
			if(option.unlocked)
			{
				#if MODS_ALLOWED Mods.currentModDirectory = option.mod; #end
				var image:String = 'achievements/' + option.name;
				if(Paths.fileExists('images/$image-pixel.png', IMAGE))
				{
					graphic = Paths.image('$image-pixel');
					hasAntialias = false;
				}
				else graphic = Paths.image(image);

				if(graphic == null) graphic = Paths.image('unknownMod');
			}
			else graphic = Paths.image('achievements/lockedachievement');

			var spr:FlxSprite = new FlxSprite(0, 70 + Math.floor(grpOptions.members.length / MAX_PER_ROW) * 180).loadGraphic(graphic);
			//spr.x += 180 * ((grpOptions.members.length % MAX_PER_ROW) - MAX_PER_ROW/2) + spr.width / 2 + 15;
			spr.ID = grpOptions.members.length;
			spr.antialiasing = hasAntialias;
			grpOptions.add(spr);

			var nameText:FlxText = new FlxText(spr.x + 240, 120 + Math.floor(textGroup.members.length / MAX_PER_ROW) * 180, FlxG.width, option.displayName , 32);
			nameText.setFormat(Paths.font("tbs.ttf"), 46, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			nameText.ID = textGroup.members.length;
			nameText.borderSize = 2;
			textGroup.add(nameText);
		}
		#if MODS_ALLOWED Mods.loadTopMod(); #end

		add(grpOptions);
		add(textGroup);

		var box:FlxSprite = new FlxSprite(0, 640).makeGraphic(1, 1, FlxColor.BLACK);
		box.scale.set(FlxG.width, FlxG.height - box.y);
		box.updateHitbox();
		box.alpha = 0.6;
		box.scrollFactor.set();
		add(box);

		FlxG.camera.zoom = 1.3;

		descText = new FlxText(50, box.y + 10, FlxG.width - 100, "", 32);
		descText.setFormat(Paths.font("tbs.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();

		nameText = new FlxText(50, descText.y + 38, FlxG.width - 100, "", 24);
		nameText.setFormat(Paths.font("tbs.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nameText.scrollFactor.set();

		progressBar = new Bar(0, 550);
		progressBar.screenCenter(X);
		progressBar.scrollFactor.set();
		progressBar.enabled = false;
		
		progressTxt = new FlxText(50, progressBar.y + 16, FlxG.width - 100, "", 32);
		progressTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		progressTxt.scrollFactor.set();
		progressTxt.borderSize = 2;

		var theNumb:Float = 0;
		for (i in 0...Achievements.achievementsUnlocked.length) {
		theNumb = 7.14 * i;
		}

		percBar = new Bar(610, 20, 'game/timeBar',  function() return ((theNumb == 0) ? theNumb : theNumb + 0.03 + 7.15) / 100, 0, 1);
		percBar.scale.set(1.45, 1.25);
		percBar.setColors(0xFFFFFFFF, 0x00000000);
		percBar.scrollFactor.set();
		add(percBar);

		percentTxt = new FlxText(150, percBar.y - 2, FlxG.width - 100, 'Achievents Completed: ' + Achievements.achievementsUnlocked.length + ' - ' + grpOptions.members.length + ' (' + ((theNumb == 0) ? theNumb : theNumb + 0.03 + 7.15 /**i love math**/) + '%)', 32);
		percentTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		percentTxt.scrollFactor.set();
		percentTxt.borderSize = 2;
		add(percentTxt);

		add(progressBar);
		add(progressTxt);
		add(descText);
		add(nameText);
		
		_changeSelection();
		super.create();
		
		FlxG.camera.follow(camFollow, null, 0.15);
		FlxG.camera.scroll.y = -FlxG.height;
	}

	function makeAchievement(achievement:String, data:Achievement, unlocked:Bool, mod:String = null)
	{
		return {
			name: achievement,
			displayName: unlocked ? Language.getPhrase('achievement_$achievement', data.name) : '???',
			description: Language.getPhrase('description_$achievement', data.description),
			rarity: data.rarity,
			curProgress: data.maxScore > 0 ? Achievements.getScore(achievement) : 0,
			maxProgress: data.maxScore > 0 ? data.maxScore : 0,
			decProgress: data.maxScore > 0 ? data.maxDecimals : 0,
			unlocked: unlocked,
			ID: data.ID,
			mod: mod
		};
	}

	public static function sortByID(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.ID, Obj2.ID);

	var colory:Int;
	var goingBack:Bool = false;
	override function update(elapsed:Float) {
		if(!goingBack && options.length > 1)
		{
			var add:Int = 0;
			if (controls.UI_LEFT_P) add = -1;
			else if (controls.UI_RIGHT_P) add = 1;

			if(add != 0)
			{
				var oldRow:Int = Math.floor(curSelected / MAX_PER_ROW);
				var rowSize:Int = Std.int(Math.min(MAX_PER_ROW, options.length - oldRow * MAX_PER_ROW));
				
				curSelected += add;
				var curRow:Int = Math.floor(curSelected / MAX_PER_ROW);
				if(curSelected >= options.length) curRow++;

				if(curRow != oldRow)
				{
					if(curRow < oldRow) curSelected += rowSize;
					else curSelected = curSelected -= rowSize;
				}
				_changeSelection();
			}

			if(options.length > MAX_PER_ROW)
			{
				var add:Int = 0;
				if (controls.UI_UP_P) add = -1;
				else if (controls.UI_DOWN_P) add = 1;

				if(add != 0)
				{
					var diff:Int = curSelected - (Math.floor(curSelected / MAX_PER_ROW) * MAX_PER_ROW);
					curSelected += add * MAX_PER_ROW;
					//trace('Before correction: $curSelected');
					if(curSelected < 0)
					{
						curSelected += Math.ceil(options.length / MAX_PER_ROW) * MAX_PER_ROW;
						if(curSelected >= options.length) curSelected -= MAX_PER_ROW;
						//trace('Pass 1: $curSelected');
					}
					if(curSelected >= options.length)
					{
						curSelected = diff;
						//trace('Pass 2: $curSelected');
					}

					_changeSelection();
				}
			}
			
			if(controls.RESET && (options[curSelected].unlocked || options[curSelected].curProgress > 0))
			{
				openSubState(new ResetAchievementSubstate());
			}
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			goingBack = true;
		}
		super.update(elapsed);

		switch(options[curSelected].rarity) {
			case "Doable":
			colory = FlxColor.LIME;
			case "Mid":
			colory = FlxColor.ORANGE;
			case "Hard":
			colory = FlxColor.RED;
			case "Insane":
			colory = 0xFF6A0000;
			case "Impossible":
			colory = 0xFF390075;
		}

		nameText.applyMarkup(
            'Difficulty: *' + options[curSelected].rarity + '*',
            [
                new FlxTextFormatMarkerPair(new FlxTextFormat(colory), "*")
            ]
        );
	}

	public var barTween:FlxTween = null;
	function _changeSelection()
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		var hasProgress = options[curSelected].maxProgress > 0;
		descText.text = options[curSelected].description;
		progressTxt.visible = progressBar.visible = hasProgress;

		if(barTween != null) barTween.cancel();

		if(hasProgress)
		{
			var val1:Float = options[curSelected].curProgress;
			var val2:Float = options[curSelected].maxProgress;
			progressTxt.text = CoolUtil.floorDecimal(val1, options[curSelected].decProgress) + ' - ' + CoolUtil.floorDecimal(val2, options[curSelected].decProgress);

			barTween = FlxTween.tween(progressBar, {percent: (val1 / val2) * 100}, 0.5, {ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween) progressBar.updateBar(),
				onUpdate: function(twn:FlxTween) progressBar.updateBar()
			});
		}
		else progressBar.percent = 0;

		var maxRows = Math.floor(grpOptions.members.length / MAX_PER_ROW);
        camFollow.setPosition(grpOptions.members[curSelected].getGraphicMidpoint().x - 100, grpOptions.members[curSelected].getGraphicMidpoint().y - 50);

		grpOptions.forEach(function(spr:FlxSprite) {
			spr.alpha = 0.6;
			spr.x = 130;
			if(spr.ID == curSelected) {
			spr.alpha = 1;
			spr.x = 160;
			}
		});

		textGroup.forEach(function(spr:FlxSprite) {
			spr.alpha = 0.6;
			spr.x = 280;
			if(spr.ID == curSelected) {
			spr.alpha = 1;
			spr.x = 310;
			}
		});
	}
}

class ResetAchievementSubstate extends MusicBeatSubstate
{
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		var text:Alphabet = new Alphabet(0, 180, Language.getPhrase('reset_achievement', 'Reset Achievement:'), true);
		text.screenCenter(X);
		text.scrollFactor.set();
		add(text);
		
		var state:AchievementsMenuState = cast FlxG.state;
		var text:FlxText = new FlxText(50, text.y + 90, FlxG.width - 100, state.options[state.curSelected].displayName, 40);
		text.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.scrollFactor.set();
		text.borderSize = 2;
		add(text);
		
		yesText = new Alphabet(0, text.y + 120, Language.getPhrase('Yes'), true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		yesText.scrollFactor.set();
		for(letter in yesText.letters) letter.color = FlxColor.RED;
		add(yesText);
		noText = new Alphabet(0, text.y + 120, Language.getPhrase('No'), true);
		noText.screenCenter(X);
		noText.x += 200;
		noText.scrollFactor.set();
		add(noText);
		updateOptions();
	}

	override function update(elapsed:Float)
	{
		if(controls.BACK)
		{
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		super.update(elapsed);

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			onYes = !onYes;
			updateOptions();
		}

		if(controls.ACCEPT)
		{
			if(onYes)
			{
				var state:AchievementsMenuState = cast FlxG.state;
				var option:Dynamic = state.options[state.curSelected];

				Achievements.variables.remove(option.name);
				Achievements.achievementsUnlocked.remove(option.name);
				option.unlocked = false;
				option.curProgress = 0;
				option.name = '???';
				if(option.maxProgress > 0) state.progressTxt.text = '0 - ' + option.maxProgress;
				state.grpOptions.members[state.curSelected].loadGraphic(Paths.image('achievements/lockedachievement'));
				state.grpOptions.members[state.curSelected].antialiasing = ClientPrefs.data.antialiasing;

				if(state.progressBar.visible)
				{
					if(state.barTween != null) state.barTween.cancel();
					state.barTween = FlxTween.tween(state.progressBar, {percent: 0}, 0.5, {ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween) state.progressBar.updateBar(),
						onUpdate: function(twn:FlxTween) state.progressBar.updateBar()
					});
				}
				Achievements.save();
				FlxG.save.flush();

				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			close();
			return;
		}
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
#end