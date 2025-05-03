package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;

import objects.MenuItem;
import objects.MenuCharacter;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import flixel.addons.display.FlxBackdrop;
import openfl.filters.ShaderFilter;
import shaders.tbs.Monitor;

import backend.StageData;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;
	var monitor:Monitor = new Monitor();

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var checker:FlxBackdrop;

	var sign1:FlxSprite;
	var sign2:FlxSprite;

	var isInSub:Bool = false;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var button1:FlxSprite;
	var button2:FlxSprite;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	var rTxt:FlxText;
	var dTxt:FlxText;
	var eTxt:FlxText;

	var wantedState:String = 'story';

	var buttonD:FlxSprite;
	var buttonU:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		openfl.Lib.application.window.title = "Untitled Basement Show Retake: Refreshed | Story Menu";

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR STORY MODE\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		if(curWeek >= WeekData.weeksList.length) curWeek = 0;

		scoreText = new FlxText(0, 670, FlxG.width, Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]), 36);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 2;
		scoreText.screenCenter(X);

		isInSub = false;

		var ui_tex = Paths.getSparrowAtlas('menus/story_mode/campaign_menu_UI_assets');
		var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgSprite = new FlxSprite();

		grpWeekText = new FlxTypedGroup<MenuItem>();

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();

		var num:Int = 0;
		var itemTargetY:Float = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, WeekData.weeksList[i]);
				weekThing.y += ((weekThing.height + 20) * num);
				weekThing.ID = num;
				weekThing.targetY = itemTargetY;
				itemTargetY += Math.max(weekThing.height, 110) + 10;
				grpWeekText.add(weekThing);

				weekThing.screenCenter(X);
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = ui_tex;
					lock.scale.set(0,0);
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();

		Difficulty.resetList();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		add(bgSprite);

		checker = new FlxBackdrop(Paths.image('menus/checker'), Y, 0, 0);
        checker.color = 0xFFB0B0B0;
		checker.velocity.y = 28;
        add(checker);

		rTxt = new FlxText(12, 20, FlxG.width, "", 12);
		rTxt.screenCenter(X);
		rTxt.x += 5;
		rTxt.setFormat(Paths.font("tbs.ttf"), 42, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(rTxt);

		eTxt = new FlxText(12, 75, FlxG.width, "", 12);
		eTxt.screenCenter(X);
		eTxt.x += 5;
		eTxt.setFormat(Paths.font("tbs.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(eTxt);

		dTxt = new FlxText(5, 140, 760, "", 12);
		dTxt.setFormat(Paths.font("tbs.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(dTxt);

		button1 = new FlxSprite(950, 40).loadGraphic(Paths.image('menus/story_mode/button'));
		add(button1);

		button2 = new FlxSprite(950, 540).loadGraphic(Paths.image('menus/story_mode/button'));
		button2.angle = 180;
		add(button2);

		var vig:FlxSprite = new FlxSprite(-5).loadGraphic(Paths.image('menus/story_mode/vignette'));
		vig.antialiasing = ClientPrefs.data.antialiasing;
		vig.updateHitbox();
		vig.screenCenter();
		add(vig);

		var cinematicBar = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		cinematicBar.scrollFactor.set();
		cinematicBar.alpha = 0.6;
		add(cinematicBar);

		cinematicBar.scale.set(FlxG.width, (FlxG.height/2) * 0.2);
		cinematicBar.updateHitbox();

		cinematicBar.updateHitbox();
		cinematicBar.y = FlxG.height - cinematicBar.height + 3;

		cinematicBar.scale.y = (FlxG.height/2) * 0.2;
		cinematicBar.updateHitbox();

		add(scoreText);

		changeWeek();

		super.create();

		
		if(ClientPrefs.data.shaders)
		{
		FlxG.camera.setFilters([new ShaderFilter(monitor)]);
		}

		sign1 = new FlxSprite(-20 + 50, -70).loadGraphic(Paths.image('menus/story_mode/sign_story'));
		sign1.scale.set(0.7, 0.7);
		sign1.updateHitbox();
		sign1.y -= 1000;
		sign1.antialiasing = true;
		add(sign1);

		sign2 = new FlxSprite(620 + 100, -70).loadGraphic(Paths.image('menus/story_mode/sign_freeplay'));
		sign2.scale.set(0.7, 0.7);
		sign2.updateHitbox();
		sign2.y -= 1000;
		sign2.antialiasing = true;
		add(sign2);

		FlxG.mouse.visible = true;
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
		{
			if (controls.BACK && !movedBack && !selectedWeek)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				movedBack = true;
				MusicBeatState.switchState(new MainMenuState());
			}
			super.update(elapsed);
			return;
		}

		FreeplayState.wantedWeek = WeekData.weeksList[curWeek];

		// scoreText.setFormat(Paths.font("vcr.ttf"), 32);
		if(intendedScore != lerpScore)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
			if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
	
			scoreText.text = Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]);
		}

		scoreText.alpha = FlxMath.lerp(scoreText.alpha, (loadedWeeks[curWeek].menuType == 'freeplay' ? 0 : 1), 0.15);

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var changeDiff = false;
			if (controls.UI_UP_P && !isInSub)
			{
				button1.scale.set(1.35, 1.35);
				button1.color = FlxColor.WHITE;
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P && !isInSub)
			{
				button2.scale.set(1.35, 1.35);
				button2.color = FlxColor.WHITE;
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if(FlxG.mouse.wheel != 0 && !isInSub)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
			}

			if(FlxG.keys.justPressed.CONTROL && ClientPrefs.data.cheatOn)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET && !isInSub)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			/*else if (controls.ACCEPT) {
				switch (WeekData.weeksList[curWeek].menuType)
				{
				case 'freeplay': selectWeek('freeplay');
				case 'story': selectWeek('story');
				default: selectWeek('default');
				}
			}*/
		}

		if (controls.ACCEPT && !isInSub) {
			FlxG.sound.play(Paths.sound('confirmMenu'));
			setSelectType();
		}

		if (controls.BACK && !movedBack && !selectedWeek && !isInSub)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.BACK && isInSub)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			isInSub = false;
			FlxTween.tween(sign1, {y: sign1.y - 1000}, 1, {ease: FlxEase.sineInOut});
			FlxTween.tween(sign2, {y: sign2.y - 1000}, 1, {ease: FlxEase.sineInOut});
		}

		rTxt.text = loadedWeeks[curWeek].weekName + ' : ' + loadedWeeks[curWeek].storyName;
		dTxt.text = loadedWeeks[curWeek].desc;
	    eTxt.text = 'VS ' + loadedWeeks[curWeek].oppName;

		super.update(elapsed);

		button1.scale.y = button1.scale.x = FlxMath.lerp(button1.scale.x, 1, 0.2);
		button1.color = FlxColor.interpolate(button1.color, FlxColor.GRAY, 0.2);

		button2.scale.y = button2.scale.x = FlxMath.lerp(button2.scale.x, 1, 0.2);
		button2.color = FlxColor.interpolate(button2.color, FlxColor.GRAY, 0.2);
		
		var offY:Float = grpWeekText.members[curWeek].targetY;
		for (num => item in grpWeekText.members)
			item.y = FlxMath.lerp(item.targetY - offY + 480, item.y, Math.exp(-elapsed * 10.2));

		for (num => lock in grpLocks.members)
			lock.y = grpWeekText.members[lock.ID].y + grpWeekText.members[lock.ID].height/2 - lock.height/2;

		if (FlxG.mouse.overlaps(sign1)) {
			wantedState = 'story';
			sign1.scale.x = sign1.scale.y = FlxMath.lerp(sign1.scale.x, 0.8, FlxMath.bound(elapsed*8.2, 0, 1));
			if (FlxG.mouse.justPressed) {
				selectWeek();
			}
		}
		else {
			sign1.scale.x = sign1.scale.y = FlxMath.lerp(sign1.scale.x, 0.7, FlxMath.bound(elapsed*8.2, 0, 1));
		}

		if (FlxG.mouse.overlaps(sign2)) {
			wantedState = 'freeplay';
			sign2.scale.x = sign2.scale.y = FlxMath.lerp(sign2.scale.x, 0.8, FlxMath.bound(elapsed*8.2, 0, 1));
			if (FlxG.mouse.justPressed) {
				selectWeek();
			}
		}
		else {
			sign2.scale.x = sign2.scale.y = FlxMath.lerp(sign2.scale.x, 0.7, FlxMath.bound(elapsed*8.2, 0, 1));
		}
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function setSelectType() {
		isInSub = true;
		switch (loadedWeeks[curWeek].menuType)
		{
		case 'freeplay': wantedState = 'freeplay'; selectWeek();
		case 'story': wantedState = 'story'; selectWeek();
		default:
		FlxTween.tween(sign1, {y: sign1.y + 1000}, 1, {ease: FlxEase.sineInOut});
		FlxTween.tween(sign2, {y: sign2.y + 1000}, 1, {ease: FlxEase.sineInOut});
		}
	}

	function selectWeek()
	{
		
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			FlxG.mouse.visible = false;
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				selectedWeek = true;
	
				var diffic = Difficulty.getFilePath(2);
				if(diffic == null) diffic = '';
	
				PlayState.storyDifficulty = curDifficulty;
	
				Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-hard', PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return;
			}
			
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].isFlashing = true;
				for (char in grpWeekCharacters.members)
				{
					if (char.character != '' && char.hasConfirmAnimation)
					{
						char.animation.play('confirm');
					}
				}
				stopspamming = true;
			}

			var directory = StageData.forceNextDirectory;
			LoadingState.loadNextDirectory();
			StageData.forceNextDirectory = directory;

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			LoadingState.prepareToSong();
			switch(wantedState)
			{
			case 'story':
				#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
				FlxTween.tween(FlxG.camera, {zoom: 1.5, alpha: 0}, 1.4, {ease: FlxEase.sineInOut});
				FlxTween.tween(FlxG.sound.music,{pitch: 0.2},2,{ease: FlxEase.sineInOut,
					onComplete: function(twn){
						LoadingState.loadAndSwitchState(new PlayState(), true);
						FreeplayState.destroyFreeplayVocals();
					}
				});
			default:
			MusicBeatState.switchState(new FreeplayState());
		    }
			
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getString(curDifficulty, false);
		var newImage:FlxGraphic = Paths.image('menus/story_mode/menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Mods.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - sprDifficulty.height + 50;

			FlxTween.cancelTweensOf(sprDifficulty);
			FlxTween.tween(sprDifficulty, {y: sprDifficulty.y + 30, alpha: 1}, 0.07);
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 49324858;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = Language.getPhrase('storyname_${leWeek.fileName}', leWeek.storyName);

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (num => item in grpWeekText.members)
		{
			item.alpha = 0.6;
			if (num - curWeek == 0 && unlocked)
				item.alpha = 1;
		}

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			bgSprite.loadGraphic(Paths.image('menus/story_mode/menubackgrounds/' + assetName));
		}
		PlayState.storyWeek = curWeek;

		Difficulty.loadFromWeek();

		if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
