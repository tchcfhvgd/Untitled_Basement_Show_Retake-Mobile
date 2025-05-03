package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import tjson.TJSON;
import flixel.math.FlxMath;

import flixel.util.FlxStringUtil;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxText>;
	var item:FlxText;
	var bbg:FlxSprite;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Bio', 'Options', 'Exit to menu'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var box:FlxSprite;
	var bioBox:FlxSprite;
	var bioBox2:FlxSprite;
	var arrow:FlxSprite;
	var mTxt:FlxText;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:FlxText;
	var curTime:Float = Math.max(0, Conductor.songPosition);

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var boiTxt:FlxText;
	var bTxt:FlxText;

	public static var char1:FlxSprite;
	public static var char2:FlxSprite;
	public static var char3:FlxSprite;

	var mechTxt:FlxText;

	var bioData:Array<String> = ['The Mod', ''];

	var isInDesc:Bool = false;

	public static var songName:String = null;

	override function create()
	{
		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		} else if(PlayState.instance.practiceMode && !PlayState.instance.startingSong)
			menuItemsOG.insert(3, 'Skip Time');
		menuItems = menuItemsOG;

		for (i in 0...Difficulty.list.length) {
			var diff:String = Difficulty.getString(i);
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound();
		try
		{
			var pauseSong:String = getPauseSong();
			if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		}
		catch(e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		switch(PlayState.SONG.song)
		{
		case 'House-for-Sale', 'Sirokou':
			bioData = ['Tom\'s Basement', 'https://www.youtube.com/watch?v=gOo9Nzhou8E'];
		case 'Desire or Despair':
			bioData = ['Starved Eggman', 'https://www.youtube.com/watch?v=y5riYxJmZIg'];
		case 'Meme Mania':
			bioData = ['The Mod', ''];
		case 'Frozen Bell':
			bioData = ['Tom And Jerry: The Night Before Christmas & "TBS" OC', 'https://www.youtube.com/watch?v=a0BKpKixEow'];
		case 'Shattered':
			bioData = ['Blue Cat Blues', 'https://www.youtube.com/watch?v=WOlJOa8-Psk'];
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, (PlayState.SONG.song != 'Meme Mania' ? FlxColor.BLACK : 0xFF00AEFF));
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		char1 = new FlxSprite();
		char1.alpha = 0;

		char2 = new FlxSprite(519, -55).loadGraphic(Paths.image('game/pause/right'));
		char2.alpha = 0;
		char2.scale.set(0.5, 0.5);

		char3 = new FlxSprite(569, -245);
		char3.alpha = 0;
		char3.scale.set(0.5, 0.5);

		add(char1);
		add(char3);
		add(char2);

	    box = new FlxSprite(0, (PlayState.chartingMode ? 100 : 110)).loadGraphic(Paths.image('game/pause/box'));
		box.scale.set((PlayState.chartingMode ? 0.62 : 0.6), 0);
		box.screenCenter(X);
	
		FlxTween.tween(box.scale, {y: (PlayState.chartingMode ? 1.3 : 0.66)}, 0.5, {ease: FlxEase.bounceInOut});

		arrow = new FlxSprite(519).loadGraphic(Paths.image('game/pause/arrow'));
		arrow.alpha = 0;
		FlxTween.tween(arrow, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
		arrow.scale.set(0.07, 0.07);
		if (PlayState.SONG.song != 'Meme Mania') {
		add(arrow);
		add(box);
		}

		FlxTween.tween(char1, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
		FlxTween.tween(char2, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
		FlxTween.tween(char3, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});
		FlxTween.tween(arrow, {alpha: 1}, 0.4, {ease: FlxEase.sineInOut});

		switch(PlayState.SONG.song)
		{
			case 'House-for-Sale':
				char1.loadGraphic(Paths.image('game/pause/left'));
				char1.x -= 220;
				char1.y += 50;
				char3.loadGraphic(Paths.image('game/pause/right2'));
				FlxTween.tween(char1, {x: -20}, 0.2, {ease: FlxEase.sineInOut});
				FlxTween.tween(char2, {x: 319}, 0.2, {ease: FlxEase.sineInOut});
				FlxTween.tween(char3, {x: 369}, 0.2, {ease: FlxEase.sineInOut});
			case 'Sirokou':
				char1.loadGraphic(Paths.image('game/pause/left1'));
				char1.x -= 280;
				char1.scale.set(0.8, 0.8);
				char1.y += 120;
				char3.loadGraphic(Paths.image('game/pause/right2'));
				FlxTween.tween(char1, {x: -55}, 0.2, {ease: FlxEase.sineInOut});
				FlxTween.tween(char2, {x: 319}, 0.2, {ease: FlxEase.sineInOut});
				FlxTween.tween(char3, {x: 369}, 0.2, {ease: FlxEase.sineInOut});
			case 'Blue', 'Tragical Comedy', 'Shattered':
				char1.loadGraphic(Paths.image('game/pause/left3'));
				char1.scale.set(0.8, 0.8);
				char1.x -= 280;
				char1.y += 125;
				char3.visible = false;
				FlxTween.tween(char2, {x: 319},0.2, {ease: FlxEase.sineInOut});
				FlxTween.tween(char1, {x: -80}, 0.2, {ease: FlxEase.sineInOut});
			case 'Desire or Despair':
				char1.loadGraphic(Paths.image('game/pause/left10'));
				char1.x -= 60;
				char2.scale.set(0.55, 0.55);
				char1.y += 50;
				char2.loadGraphic(Paths.image('game/pause/right5'));
				char2.y += 5;
				char2.x -= 330;
				char3.visible = false;
			case 'Meme Mania':
				char1.loadGraphic(Paths.image('game/pause/left9'));
				char1.y += 75;
				char1.x -= 50;
				char2.loadGraphic(Paths.image('game/pause/right'));
				char2.x = 319;
				char3.visible = false;
				char1.scale.x = char2.scale.x = char2.scale.y = char2.scale.y = 0;
				char1.angle = char2.angle = 180;
				FlxTween.tween(char2, {angle: 0},0.7, {ease: FlxEase.sineInOut});
				FlxTween.tween(char1, {angle: 0},0.7, {ease: FlxEase.sineInOut});
				FlxTween.tween(char1.scale, {x: 1, y: 1}, 0.7, {ease: FlxEase.sineInOut});
				FlxTween.tween(char2.scale, {x: 0.5, y: 0.5}, 0.7, {ease: FlxEase.sineInOut});
			default:
				char2.visible = false;
				char3.visible = false;
				char1.visible = false;
		}

		var data = TJSON.parse(File.getContent(Paths.getPath('data/'+ Paths.formatToSongPath(PlayState.SONG.song.toLowerCase()) + '/cardData.json', TEXT, null, true)));

		var levelInfo:FlxText = new FlxText(20, 15, FlxG.width, PlayState.SONG.song + ' - ' + data.composer + '\n' + Language.getPhrase("blueballed", "Deaths: {1}", [PlayState.deathCounter]), 32);
		levelInfo.scrollFactor.set();
		levelInfo.screenCenter(X);
		levelInfo.x -= 10;
		levelInfo.setFormat(Paths.font("tbs.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelInfo.updateHitbox();
		add(levelInfo);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 34, 0, Language.getPhrase("blueballed", "Deaths: {1}", [PlayState.deathCounter]), 32);
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('tbs.ttf'), 32);
		blueballedTxt.updateHitbox();
		//add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, Language.getPhrase("Practice Mode").toUpperCase(), 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('tbs.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, Language.getPhrase("Charting Mode").toUpperCase(), 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('tbs.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		missingTextBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		missingTextBG.scale.set(FlxG.width, FlxG.height);
		missingTextBG.updateHitbox();
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();

		if (PlayState.SONG.song == 'Meme Mania') {
	    var bd:BGSprite = new BGSprite('border', 0,0, 0, 0);
        add(bd);
		}

		bbg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bbg.scale.set(FlxG.width, FlxG.height);
		bbg.updateHitbox();
		bbg.alpha = 0;
		bbg.scrollFactor.set();
		add(bbg);

	    bioBox = new FlxSprite(-600).loadGraphic(Paths.image('game/pause/bio_box'));
		add(bioBox);

		//1820
		bioBox2 = new FlxSprite(820).loadGraphic(Paths.image('game/pause/bio_box'));
		bioBox2.x += 1000;
		add(bioBox2);

		bTxt = new FlxText(-535, 50, 400, 'Based From: ' + bioData[0] + (bioData[1] != '' ? '\n(Press C To Watch)' : ''), 20);
		bTxt.setFormat(Paths.font("tbs.ttf"), 34, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		bTxt.borderSize = 2.2;
		add(bTxt);

		boiTxt = new FlxText(-535, 200, 400, '"' + (PlayState.SONG.bio != null ? PlayState.SONG.bio : 'Bio Unfinished.') + '"', 20);
		boiTxt.setFormat(Paths.font("tbs.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		boiTxt.borderSize = 1.25;
		add(boiTxt);

		//1869
		mTxt = new FlxText(860, 60, 400, 'In This Song There Is:', 20);
		mTxt.setFormat(Paths.font("tbs.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		mTxt.x += 1000;
		mTxt.borderSize = 1.25;
		add(mTxt);

		mechTxt = new FlxText(860, 180, 400, (PlayState.SONG.mechs != null ? PlayState.SONG.mechs : 'No Mechanics.'), 20);
		mechTxt.setFormat(Paths.font("tbs.ttf"), (PlayState.SONG.song != 'Sirokou' ? 30 : 26), FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		mechTxt.x += 1000;
		mechTxt.applyMarkup(
            (PlayState.SONG.mechs != null ? PlayState.SONG.mechs : 'No Mechanics.'),
            [
                new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED), "*")
            ]
        );
		mechTxt.borderSize = 1.25;
		add(mechTxt);
	}
	
	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if(formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if(controls.BACK)
		{
			if (isInDesc) {
				FlxTween.tween(bioBox, {x: -600}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(boiTxt, {x: -535}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(bioBox2, {x: 1820}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(mechTxt, {x: 1860}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(mTxt, {x: 1860}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(bTxt, {x: -535}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(bbg, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
				isInDesc = false;
			}
			else {
			close();
			return;
			}
		}

		grpMenuShit.forEach(function(spr:FlxText)
			{
				spr.screenCenter(X);
	
			});	

		if(FlxG.keys.justPressed.F5)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			PlayState.nextReloadAll = true;
			MusicBeatState.resetState();
		}

		updateSkipTextStuff();
		if (controls.UI_UP_P && !isInDesc)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P && !isInDesc)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		var lerpVal:Float = elapsed * 18.6;

		arrow.y = FlxMath.lerp(arrow.y, curSelected * 52 - 1 - (PlayState.chartingMode ? 120 : 0), lerpVal);
	    arrow.x = FlxMath.lerp(arrow.x, 120, lerpVal);

		grpMenuShit.forEach(function(spr:FlxText)
			{
				spr.alpha = FlxMath.lerp(spr.alpha, 0.4, lerpVal);
	
				if (spr.ID == curSelected)
				{
					spr.alpha = FlxMath.lerp(spr.alpha, 1, lerpVal);
				}
			});

		if (FlxG.keys.pressed.C && isInDesc && bioData[1] != '') {
			CoolUtil.browserLoad(bioData[1]);
		}

		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode) && !isInDesc)
		{
			if (menuItems == difficultyChoices)
			{
				var songLowercase:String = Paths.formatToSongPath(PlayState.SONG.song);
				var poop:String = Highscore.formatSong(songLowercase, curSelected);
				try
				{
					if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected))
					{
						Song.loadFromJson(poop, songLowercase);
						PlayState.storyDifficulty = curSelected;
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
						PlayState.changedDifficulty = true;
						PlayState.chartingMode = false;
						return;
					}
				}
				catch(e:haxe.Exception)
				{
					trace('ERROR! ${e.message}');
	
					var errorStr:String = e.message;
					if(errorStr.startsWith('[lime.utils.Assets] ERROR:')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
					else errorStr += '\n\n' + e.stack;

					missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
					missingText.screenCenter(Y);
					missingText.visible = true;
					missingTextBG.visible = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));

					super.update(elapsed);
					return;
				}


				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Bio':
					FlxTween.tween(bioBox, {x: 0}, 0.4, {ease: FlxEase.quartInOut});
					FlxTween.tween(boiTxt, {x: 65}, 0.4, {ease: FlxEase.quartInOut});
					FlxTween.tween(bioBox2, {x: 820}, 0.4, {ease: FlxEase.quartInOut});
					FlxTween.tween(mechTxt, {x: 860}, 0.4, {ease: FlxEase.quartInOut});
					FlxTween.tween(mTxt, {x: 860}, 0.4, {ease: FlxEase.quartInOut});
					FlxTween.tween(bTxt, {x: 65}, 0.4, {ease: FlxEase.quartInOut});
					FlxTween.tween(bbg, {alpha: 0.7}, 0.4, {ease: FlxEase.quartInOut});
					isInDesc = true;
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case 'End Song':
					close();
					PlayState.instance.notes.clear();
					PlayState.instance.unspawnNotes = [];
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case 'Options':
					PlayState.instance.paused = true; // For lua
					PlayState.instance.vocals.volume = 0;
					PlayState.instance.canResync = false;
					MusicBeatState.switchState(new OptionsState());
					if(ClientPrefs.data.pauseMusic != 'None')
					{
						FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
						FlxG.sound.music.time = pauseMusic.time;
					}
					OptionsState.onPlayState = true;
				case "Exit to menu":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					PlayState.instance.canResync = false;
					Mods.loadTopMod();
					if(PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else 
						MusicBeatState.switchState(new FreeplayState());

					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		MusicBeatState.resetState();
	}

	override function destroy()
	{
		pauseMusic.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		missingText.visible = false;
		missingTextBG.visible = false;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {

				item = new FlxText(0, (i * 52), 0, menuItems[i]);
				item.y += (PlayState.chartingMode ? 120: 250);
				item.ID = i;
				item.alpha = 0;
				item.setFormat(Paths.font((PlayState.SONG.song != 'Meme Mania' ? "tbs.ttf" : "arial.ttf")), (PlayState.SONG.song != 'Meme Mania' ? 36 : 46), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				grpMenuShit.add(item);

				FlxTween.tween(item, {alpha: 1}, (i * 0) + 0.1, {ease: FlxEase.sineInOut});

				skipTimeText = new FlxText(0, 50, 0, '', 64);
				skipTimeText.setFormat(Paths.font("tbs.ttf"), 44, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				//skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = PlayState.chartingMode;
	}

	function updateSkipTimeText()
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' - ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
}
