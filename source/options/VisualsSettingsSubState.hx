package options;

import objects.Note;
import objects.StrumNote;
import objects.NoteSplash;
import objects.Alphabet;

class VisualsSettingsSubState extends BaseOptionsMenu
{
	var noteOptionID:Int = -1;
	var notes:FlxTypedGroup<StrumNote>;
	var scoreG:FlxTypedGroup<FlxText>;
	var splashes:FlxTypedGroup<NoteSplash>;
	var scoreTxt:FlxText;
	var noteY:Float = 90;
	public function new()
	{
		title = Language.getPhrase('visuals_menu', 'Appearance Settings');
		rpcTitle = 'Appearance Settings Menu'; //for Discord Rich Presence

		// for note skins and splash skins
		notes = new FlxTypedGroup<StrumNote>();
		splashes = new FlxTypedGroup<NoteSplash>();
		scoreG = new FlxTypedGroup<FlxText>();

		// scoreThing
		scoreTxt = new FlxText(0, 100, FlxG.width, (ClientPrefs.data.showNPS ? "NPS: 0 (Max: 0) " : "") +  (ClientPrefs.data.showScore ? "• Score: 0 " : "") + (ClientPrefs.data.showAcc ? "• Rank: -% (N/A) " : "") + (ClientPrefs.data.showMiss ? "• Combo Breaks: 0 [?]" : ""), 20);
		//scoreTxt = new FlxText(0, healthBar.y + 70, FlxG.width, (ClientPrefs.data.showNPS ? "NPS: 0 (Max: 0) • Score: 0 • Accuracy: -% (N/A) • Combo Breaks: 0 [?]" : "Score: 0 • Accuracy: -% (N/A) • Combo Breaks: 0 [?]"), 20);
		scoreTxt.setFormat(Paths.font("tbs.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = false;
		scoreG.add(scoreTxt);

		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = new StrumNote(370 + (560 / Note.colArray.length) * i, -200, i, 0);
			changeNoteSkin(note);
			notes.add(note);
			
			var splash:NoteSplash = new NoteSplash(0, 0, NoteSplash.defaultNoteSplash + NoteSplash.getSplashSkinPostfix());
			splash.inEditor = true;
			splash.babyArrow = note;
			splash.ID = i;
			splash.kill();
			splashes.add(splash);
		}

		// options
		var noteSkins:Array<String> = Mods.mergeAllTextsNamed('game/images/noteSkins/list.txt');

		var option:Option = new Option('Show NPS',
		'If checked, score will show "nps" which shows how many notes you press in the second.',
		'showNPS',
		BOOL);
	    addOption(option);
		option.onChange = scoreUpdate;

		var option:Option = new Option('Show Score',
		'If checked, score will show your "score".',
		'showScore',
		BOOL);
	    addOption(option);
		option.onChange = scoreUpdate;

		var option:Option = new Option('Show Misses',
		'If checked, score will show how many notes you missed.',
		'showMiss',
		BOOL);
	    addOption(option);
		option.onChange = scoreUpdate;

		var option:Option = new Option('Show Accuracy',
		'If checked, score will show your accuracy & rank.',
		'showAcc',
		BOOL);
	    addOption(option);
		option.onChange = scoreUpdate;
	
		var option:Option = new Option('Show MS Counter',
		    'If checked, an MS counter will show how early/late you\'re pressing.',
			'showMS',
			BOOL);
		addOption(option);

		var option:Option = new Option('Bump MS Counter',
		    'If checked, the MS counter will bump.',
			'bumpMS',
			BOOL);
		addOption(option);

		var option:Option = new Option('Sustain Position',
			"Where should long notes be placed?",
			'susPlace',
			STRING,
			['Under', 'Over']);
		addOption(option);
		
		var noteSplashes:Array<String> = Mods.mergeAllTextsNamed('images/game/noteSplashes/list.txt');
		if(noteSplashes.length > 0)
		{
			if(!noteSplashes.contains(ClientPrefs.data.splashSkin))
				ClientPrefs.data.splashSkin = ClientPrefs.defaultData.splashSkin; //Reset to default if saved splashskin couldnt be found

			noteSplashes.insert(0, ClientPrefs.defaultData.splashSkin); //Default skin always comes first
			var option:Option = new Option('Note Splashes:',
				"Select your prefered Note Splash variation.",
				'splashSkin',
				STRING,
				noteSplashes);
			addOption(option);
			option.onChange = onChangeSplashSkin;
		}

		var option:Option = new Option('Notes Opacity',
			'How much transparent should the Notes be.',
			'notesAlpha',
			PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.6;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		option.onChange = updateAlpha;

		var option:Option = new Option('Sustain Notes Opacity',
			'How much transparent should the Sustain Notes be.',
			'susAlpha',
			PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.3;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Note Splash Opacity',
			'How much transparent should the Note Splashes be.',
			'splashAlpha',
			PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);
		option.onChange = playNoteSplashes;

		var option:Option = new Option('Opponent Note Splash',
			'If Checked, Opponent Will Also Have Notes Splashes.',
			'oppsplash',
			BOOL);
		addOption(option);

		var option:Option = new Option('Note Hold Splash Opacity',
			'How much transparent should the Note Hold Splash be.\n0% disables it.',
			'holdSplashAlpha',
			PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		/*var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			BOOL);
		addOption(option);*/
		
		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			STRING,
			['Time Left', 'Time Elapsed'/*, 'Song Name', 'Disabled'*/]);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			BOOL);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			BOOL);
		addOption(option);

		var option:Option = new Option('Judgement Counter Type:',
			"What should the Judgement Counter display style should be?",
			'judType',
			STRING,
			['None', 'Left', 'Right']);
		addOption(option);

		var option:Option = new Option('Score Text Grow on Hit',
			"If unchecked, disables the Score text growing\neverytime you hit a note.",
			'scoreZoom',
			BOOL);
		addOption(option);

		var option:Option = new Option('Smooth Health',
			"If checked, health will move smoothly\nand not instant.",
			'smoothHealth',
			BOOL);
		addOption(option);

		var option:Option = new Option('Colored Health',
			"If unchecked, health will be colored in red & green instead of the icon color.",
			'coloredHP',
			BOOL);
		addOption(option);

		/*var option:Option = new Option('Health Bar Opacity',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);*/

		var option:Option = new Option('Score BG Opacity',
			'How much transparent should the score BG be.',
			'sbgAlpha',
			PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Icon Bops:',
			"How Should The Icons Bop?",
			'iconBopStyle',
			STRING,
			['On Beat', 'On Note Hit', 'Never']);
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			BOOL);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option('Show Subtitles',
		'If checked, subtitles will show what the character says.',
		'subsBool',
		BOOL);
	    addOption(option);
		
		var option:Option = new Option('Pause Music:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			STRING,
			['None', 'Tea Time', 'Breakfast', 'Breakfast (Pico)']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		#if DISCORD_ALLOWED
		var option:Option = new Option('Discord Rich Presence',
			"Uncheck this to prevent accidental leaks, it will hide the Application from your \"Playing\" box on Discord",
			'discordRPC',
			BOOL);
		addOption(option);
		#end

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			BOOL);
		addOption(option);

		var option:Option = new Option('Simple Rating Movements',
			"If checked, Ratings and Combo will not bump.",
			'simpleRatings',
			BOOL);
		addOption(option);

		super();
		add(notes);
		add(splashes);
		add(scoreG);
	}

	var notesShown:Bool = false;
	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		
		switch(curOption.variable)
		{
			case 'showScore', 'showNPS', 'showMiss', 'showAcc': scoreTxt.visible = true;
			case 'noteSkin', 'splashSkin', 'splashAlpha', 'oppsplashAlpha', 'notesAlpha':
				if(!notesShown)
				{
					for (note in notes.members)
					{
						note.alpha = ClientPrefs.data.notesAlpha;
						FlxTween.cancelTweensOf(note);
						FlxTween.tween(note, {y: noteY}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
					}
				}
				scoreTxt.visible = false;
				notesShown = true;
				if(curOption.variable.startsWith('splash') && Math.abs(notes.members[0].y - noteY) < 25) playNoteSplashes();

			default:
				if(notesShown) 
				{
					for (note in notes.members)
					{
						FlxTween.cancelTweensOf(note);
						FlxTween.tween(note, {y: -200}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
					}
				}
				scoreTxt.visible = false;
				notesShown = false;
		}
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
	}

	function onChangeNoteSkin()
	{
		notes.forEachAlive(function(note:StrumNote) {
			changeNoteSkin(note);
			note.centerOffsets();
			note.centerOrigin();
		});
	}

	function updateAlpha() {
		notes.forEachAlive(function(note:StrumNote) {
			note.alpha = ClientPrefs.data.notesAlpha;
			updateTheAlpha(note);
		});
	}

	function updateTheAlpha(note:StrumNote) note.alpha = ClientPrefs.data.notesAlpha;

	function changeNoteSkin(note:StrumNote)
	{
		var skin:String = Note.defaultNoteSkin;
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		note.texture = skin; //Load texture and anims
		note.reloadNote();
		note.playAnim('static');
	}

	function onChangeSplashSkin()
	{
		var skin:String = NoteSplash.defaultNoteSplash + NoteSplash.getSplashSkinPostfix();
		for (splash in splashes)
			splash.loadSplash(skin);

		playNoteSplashes();
	}

	function scoreUpdate()
	{
		scoreTxt.text = (ClientPrefs.data.showNPS ? 'NPS: 0 (Max: 0) ' : '') + (ClientPrefs.data.showScore ? (ClientPrefs.data.showNPS ? ' •' : '') +  'Score: 0 ' : '') + (ClientPrefs.data.showAcc ? (ClientPrefs.data.showScore ? '• ' : '') + ' Rank: -% (N/A) ' : '') + (ClientPrefs.data.showMiss ? (ClientPrefs.data.showAcc ? '• ' : '') + ' Combo Breaks: 0 [?]' : '');
	}

	function playNoteSplashes()
	{
		var rand:Int = 0;
		if (splashes.members[0] != null && splashes.members[0].maxAnims > 1)
			rand = FlxG.random.int(0, splashes.members[0].maxAnims - 1); // For playing the same random animation on all 4 splashes

		for (splash in splashes)
		{
			splash.revive();

			splash.spawnSplashNote(0, 0, splash.ID, null, false);
			if (splash.maxAnims > 1)
				splash.noteData = splash.noteData % Note.colArray.length + (rand * Note.colArray.length);

			var anim:String = splash.playDefaultAnim();
			var conf = splash.config.animations.get(anim);
			var offsets:Array<Float> = [0, 0];

			var minFps:Int = 22;
			var maxFps:Int = 26;
			if (conf != null)
			{
				offsets = conf.offsets;

				minFps = conf.fps[0];
				if (minFps < 0) minFps = 0;

				maxFps = conf.fps[1];
				if (maxFps < 0) maxFps = 0;
			}

			splash.offset.set(10, 10);
			if (offsets != null)
			{
				splash.offset.x += offsets[0];
				splash.offset.y += offsets[1];
			}

			if (splash.animation.curAnim != null)
				splash.animation.curAnim.frameRate = FlxG.random.int(minFps, maxFps);
		}
	}

	override function destroy()
	{
		if(changedMusic && !OptionsState.onPlayState) FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
		Note.globalRgbShaders = [];
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
	#end
}
