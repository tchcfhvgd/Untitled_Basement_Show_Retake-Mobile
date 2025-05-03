import states.stages.Meme;
import flixel.math.FlxMath;
import backend.CoolUtil;
import backend.Paths;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import Main;
import backend.Conductor;
import backend.Achievements;
import objects.BGSprite;

var camOutside:FlxCamera = new FlxCamera();
var numbie:Float = 0;
var lTxt:FlxText;
var susImage:FlxSprite = new FlxSprite();
var rainbowShader;

function onCreatePost() {
    for (cam in [game.camGame, game.camBars, game.camHUD, game.camOther]) FlxG.cameras.remove(cam, false);
    for (cam in [camOutside, game.camGame, game.camBars, game.camHUD, game.camOther]) {cam.bgColor = 0x00000000; FlxG.cameras.add(cam, cam == camGame);}

    Meme.memeOld.cameras = [camOutside];

    game.scoreTxt.setFormat(Paths.font("impact.ttf"), 22, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    game.scoreTxt.borderSize = 2;
    game.scoreTxt.y += 5;

    game.timeTxt.font = Paths.font("impact.ttf");
    game.timeBar.scale.x = 0.5;
    game.judTxt.font = Paths.font("impact.ttf");

    Main.fpsVar.defaultTextFormat = new openfl.text.TextFormat(Paths.font("impact.ttf"), 12, FlxColor.fromRGB(game.dad.healthColorArray[0], game.dad.healthColorArray[1], game.dad.healthColorArray[2]));

    mfwsqewebg = new FlxSprite(-FlxG.width * FlxG.camera.zoom,-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF00B3FF);
    mfwsqewebg.scrollFactor.set();
    mfwsqewebg.cameras = [game.camBars];
    game.addBehindDad(mfwsqewebg);

    sus = new FlxSprite(-FlxG.width * FlxG.camera.zoom,-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFFFF0000);
    sus.scrollFactor.set();
    sus.alpha = 0;
    sus.cameras = [game.camHUD];
    game.add(sus);

    battlefield = new BGSprite('game/stages/meme/battlefield', 270, -850, 1,1);
    battlefield.scale.set(0.8,0.8);
    battlefield.alpha = 0;
    game.addBehindDad(battlefield);

    susImage.alpha = 0;
    susImage.cameras = [game.camOther];
    add(susImage);

    for (note in game.unspawnNotes) {
        if (ClientPrefs.data.diffTBS == 'Baby' && note.noteType == 'Blue Bone Note') {
            note.destroy();
        }
    }

    hudTxt = new FlxText(0, 300, FlxG.width, "Meme Mania\nBy: Breath_Sans");
    hudTxt.setFormat(Paths.font("arial.ttf"), 63, FlxColor.WHITE, "center");
    hudTxt.scale.set(0,0);
    hudTxt.alpha = 0;
    hudTxt.screenCenter();
    hudTxt.angle = 180;
    FlxTween.tween(hudTxt.scale, {x: 1, y: 1}, 3.8);
    FlxTween.tween(hudTxt, {angle: -720, alpha: 1}, 3.8);
    hudTxt.cameras = [game.camBars];
    add(hudTxt);
    game.camHUD.alpha = 0;

    game.showCombo = false;
    PlayState.uiPostfix = '-funny';

    died = new FlxSprite(400, 130);
	died.scale.set(0.9, 0.9);
    died.alpha = 0; died.y -= 20;
	died.scrollFactor.set();
	died.loadGraphic(Paths.image("game/stages/meme/bros-dead"));
	died.cameras = [camOther];
	add(died);

	PlayState.ratingStuff = [
        ['car crash and siren.wav', 0],
        ['-9999 auras', 0.1],
        ['vanishing', 0.2],
        ['pibby', 0.3], //From 0% to 19%
        ['hasta la vista', 0.4], //From 20% to 39%
        ['Ohio', 0.5], //From 40% to 49%
        ['Goon', 0.6], //From 50% to 59%
        ['FUNNI!!!', 0.69], //From 60% to 68%
        ['Sigma', 0.7], //69%
        ['Rizz!', 0.8], //From 70% to 79%
        ['Skibidi!', 0.9], //From 80% to 89%
        ['Rip SFC', 1], //From 90% to 99%
        ['Boom!!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

    new FlxTimer().start(8, function(tmr:FlxTimer){
        FlxTween.tween(hudTxt, {x: 1000}, 2, {onComplete: function(tween:FlxTween)
            {
                hudTxt.destroy();
            }});
        FlxTween.tween(mfwsqewebg, {alpha: 0}, 3.8, {onComplete: function(tween:FlxTween)
            {
                mfwsqewebg.destroy();
            }});
    });

    game.initLuaShader('rainbow');
    rainbowShader = game.createRuntimeShader('rainbow');
    
    game.scoreTxt.shader = rainbowShader;

    lTxt = new FlxText(game.subtlTxt.x, game.subtlTxt.y, FlxG.width, "");
    lTxt.setFormat(Paths.font("arial.ttf"), 28, FlxColor.fromRGB(game.dad.healthColorArray[0], game.dad.healthColorArray[1], game.dad.healthColorArray[2]), "center", FlxTextBorderStyle.SHADOW, FlxColor.WHITE);
    lTxt.borderSize = 2;
    lTxt.alpha = 0;
    lTxt.cameras = [game.camOther];
    add(lTxt);

    game.healthBar.x -= 20;

    Meme.memeOld.scale.set(0.75, 0.75);

    for (i in [game.healthBar,game.healthBar.bg,game.iconP1,game.iconP2, game.scoreTxt]) i.alpha = 0;

    game.grain.visible = false;
}

var scoreLerp;
var totalTime:Float = 0;
function onUpdatePost(elapsed) {
    Meme.memeOld.y = FlxMath.lerp(Meme.memeOld.y, 0, 0.08);

    Meme.funniNumber = FlxMath.lerp(Meme.funniNumber, 2, 0.01);
    Meme.funniNumber2 = FlxMath.lerp(Meme.funniNumber2, 2, 0.01);

    Meme.memeShader2.size.value = [Meme.funniNumber];
    Meme.memeShader2.dim.value = [Meme.funniNumber2];

    scoreLerp = FlxMath.lerp(scoreLerp, game.songScore, 0.108);

    if (curStep > 816 && curStep < 944) game.scoreTxt.text = 'Score: ' + game.songScore + ' | Misses: ' + game.songMisses + ' | Rating: ' + ratingName + ' (' + CoolUtil.floorDecimal(game.ratingPercent * 100, 0) + '%)';
    else game.scoreTxt.text = 'MLG Points: ' + Std.parseInt(scoreLerp) + ' - Homelessness Points: ' + game.songMisses + ' - Funni Numbers: ' + CoolUtil.floorDecimal(game.ratingPercent * 100, 2) + ' Which Means You\'ll Have A ' + ((game.songScore > 0) ? ratingName : 'Nothing (For Now)') + ((game.songScore >= 99999 && game.songMisses == 0) ? '\nNO WAY!!!! EPIK POINTS HAS BEEN EARNED!11!!!1!' : '');

    totalTime += elapsed;
    rainbowShader.setFloat('time', totalTime);

    if (curStep > 687 && curStep < 1078)  game.camHUD.x = Math.sin((Conductor.songPosition / 3000) * (Conductor.bpm / 80) * 3.0) * 15;

    if (game.songScore >= 99999 && game.songMisses == 0) {
        game.scoreTxt.shader = rainbowShader;
    }
    else {
        game.scoreTxt.shader = null;
    }
}

function onEvent(name:String, v1:String, v2:String) {
    if (name == 'Reactor Beep') {
        sus.alpha = 0.3;
        FlxTween.tween(sus, {alpha: 0}, 0.75, {ease: FlxEase.expoOut});
    }
    if (name == 'Sussy Event') {
        if (v1 == '') {
        susImage.alpha = 0;
        }
        else {
        susImage.alpha = 1;
        susImage.loadGraphic(Paths.image('game/stages/meme/' + v1));
        }
    }
}

function onStartCountdown() {
    game.skipCountdown = true;
}

function onBeatHit() {
    if (curBeat % 2 == 0) {
    Meme.memeOld.y = 50;
    game.iconP2.y += 10;
    if (game.health < 1.8) game.iconP2.flipX = true;
    }
    else if (curBeat % 2 == 1) {
    Meme.memeOld.y = -50;
    game.iconP2.y += 10;
    game.iconP2.flipX = false;
    }

    if (curStep > 687 && curStep < 1078) {
        if (curBeat % 2 == 0) {
            FlxTween.tween(game.camHUD, {angle: -0.3}, 0.5, {ease: FlxEase.expoOut});
        }
        else if (curBeat % 2 == 1) {
            FlxTween.tween(game.camHUD, {angle: 0.3}, 0.5, {ease: FlxEase.expoOut});
        }
    }
}

function onSongStart() {
    game.iconP2.y -= 40;
    for(i in 0...game.opponentStrums.members.length) {
        if (ClientPrefs.data.downScroll) {
        game.opponentStrums.members[i].y += 42;
        }
        else {
        game.opponentStrums.members[i].y -= 42;
        }
    }
    for(i in 0...game.playerStrums.members.length) {
        if (ClientPrefs.data.downScroll) {
        game.playerStrums.members[i].y += 42;
        }
        else {
        game.playerStrums.members[i].y -= 42;
        }
    }
}

function createSub(text:String, alpha:Float) {
   if (ClientPrefs.data.subsBool) {
   lTxt.text = text;
   FlxTween.tween(lTxt, {alpha: alpha}, 0.25);
   }

   if (alpha == 0 && text != "") {
   FlxTween.tween(game.camHUD, {alpha: 1}, 0.5);
   }
   else if (alpha > 1 && text != "(Meme Mouse explaining why TBS 2.6 is a very good update)"){
   FlxTween.tween(game.camHUD, {alpha: 0.5}, 0.5);
   }
}

function opponentNoteHit(note) {
    if (!note.isSustainNote && game.dad.curCharacter == 'MEME BOI-old') createReasons();
}

function createReasons() {
    var reasonswhytbslatestversionistheglowup:FlxSprite = new FlxSprite();
    reasonswhytbslatestversionistheglowup.loadGraphic(Paths.image('game/stages/meme/reasons/reason' + FlxG.random.int(1, 8)));
    reasonswhytbslatestversionistheglowup.screenCenter();
    reasonswhytbslatestversionistheglowup.x = game.dad.x;
    reasonswhytbslatestversionistheglowup.y = game.dad.y;
    reasonswhytbslatestversionistheglowup.acceleration.y = 550;
    reasonswhytbslatestversionistheglowup.velocity.y -= 240;
    reasonswhytbslatestversionistheglowup.velocity.x += 300;
    reasonswhytbslatestversionistheglowup.x += 650 + 170;
    reasonswhytbslatestversionistheglowup.scale.set(reasonswhytbslatestversionistheglowup.scale.x - 0.1, reasonswhytbslatestversionistheglowup.scale.y - 0.1);
    reasonswhytbslatestversionistheglowup.y += 500;
    game.addBehindDad(reasonswhytbslatestversionistheglowup);

    FlxTween.tween(reasonswhytbslatestversionistheglowup, {alpha: 0, angle: 10}, 1, {
        onComplete: function(tween:FlxTween)
        {
            reasonswhytbslatestversionistheglowup.destroy();
        }
    });
}
function onStepHit() {
    switch(curStep)
    {
    case 97:
    createSub("来追我呀，小猫咪\n(Come After Me, Pussycat)", 1);
    case 123: game.sendWindowsNotification('Meme Mouse', 'Come After Me, Pussycat >:3', true);
    case 127:
    FlxTween.tween(game.camHUD, {alpha: 1}, 0.25);
    createSub("来追我呀，小猫咪\n(Come After Me, Pussycat)", 0);
    case 192: for (i in [game.healthBar,game.healthBar.bg,game.iconP1,game.iconP2, game.scoreTxt]) FlxTween.tween(i, {alpha: 1}, 0.5);
    iconP1.offset.x = iconP2.offset.x = 20;
    case 656:
    createSub("谢谢你!\n(Thank You!)",1);
    case 672:
    createSub("谢谢你!\n(Thank You!)",0);
    case 688:
        game.defaultHUDZoom = 0.76;
        Meme.bg.alpha = 0;
        Meme.watchers.alpha = 0;
        Meme.chee.alpha = 0;
        game.startVideo('memes/among us', true, false, false, true, camOutside);
        game.videoCutscene.scale.y = 0.9;
    case 816:
        game.scoreTxt.font = Paths.font("vcr.ttf");
        game.timeTxt.font = Paths.font("vcr.ttf");
        game.judTxt.font = Paths.font("vcr.ttf"); game.judTxt.visible = game.scoreBG.visible = false;

        PlayState.uiPostfix = '';

        PlayState.ratingStuff = [
            ['You Suck!', 0.2], //From 0% to 19%
            ['Shit', 0.4], //From 20% to 39%
            ['Bad', 0.5], //From 40% to 49%
            ['Bruh', 0.6], //From 50% to 59%
            ['Meh', 0.69], //From 60% to 68%
            ['Nice', 0.7], //69%
            ['Good', 0.8], //From 70% to 79%
            ['Great', 0.9], //From 80% to 89%
            ['Sick!', 1], //From 90% to 99%
            ['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
        ];

        game.videoCutscene.alpha = 0;
        game.remove(sus);
        game.remove(susImage);
        Meme.memeOld.alpha = 1;
        camOutside.setFilters([new ShaderFilter(Meme.memeShader)]);
    case 882:
    createSub("(Meme Mouse explaining why TBS 2.6 is a very good update)",1);
    lTxt.setFormat(Paths.font("tbs.ttf"), 28, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    lTxt.borderSize = 2;
    case 944:
        game.scoreTxt.font = Paths.font("impact.ttf");
        game.timeTxt.font = Paths.font("impact.ttf");
        game.judTxt.font = Paths.font("impact.ttf"); game.judTxt.visible = game.scoreBG.visible = true;

        PlayState.uiPostfix = '-funny';

        PlayState.ratingStuff = [
            ['car crash and siren.wav', 0],
            ['-9999 auras', 0.1],
            ['vanishing', 0.2],
            ['pibby', 0.3], //From 0% to 19%
            ['hasta la vista', 0.4], //From 20% to 39%
            ['Ohio', 0.5], //From 40% to 49%
            ['Goon', 0.6], //From 50% to 59%
            ['FUNNI!!!', 0.69], //From 60% to 68%
            ['Sigma', 0.7], //69%
            ['Rizz!', 0.8], //From 70% to 79%
            ['Skibidi!', 0.9], //From 80% to 89%
            ['Rip SFC', 1], //From 90% to 99%
            ['Boom!!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
        ];
        createSub("(Meme Mouse explaining why TBS 2.6 is a very good update)",0);
        Meme.memeOld.alpha = 0;

        Meme.bg.alpha = 1;
        Meme.watchers.alpha = 1;
        Meme.chee.alpha = 1;
    case 1072:
        lTxt.setFormat(Paths.font("arial.ttf"), 28, FlxColor.fromRGB(game.dad.healthColorArray[0], game.dad.healthColorArray[1], game.dad.healthColorArray[2]), "center", FlxTextBorderStyle.SHADOW, FlxColor.WHITE);
        lTxt.borderSize = 2;
    createSub("奋住\n(Hold On)",1);
    game.camHUD.angle = 0; game.camHUD.x = 0;
    game.defaultHUDZoom = 0.8;
    case 1080:
    game.camHUD.angle = 0; game.camHUD.x = 0;
    createSub("我们能赢!\n(We Can Win!)",1);
    case 1091:
    createSub("我们能赢!\n(We Can Win!)",0);
    case 1232:
    Meme.bg.alpha = 0;
    Meme.watchers.alpha = 0;
    Meme.chee.alpha = 0;
    battlefield.alpha = 1;
    dad.y -= 280;
    dad.x += 500;
    case 1360:
    Meme.bg.alpha = 1;
    Meme.watchers.alpha = 1;
    Meme.chee.alpha = 1;
    battlefield.destroy();
    case 1856:
    createSub("救救我\n(Help Me)",1);
    case 1864:
    createSub("救救我\n(Help Me)",0);
    case 2128:
    createSub("再见，我的朋友-\n(Goodbye, My Friend-)",1);
    case 2144:
    FlxTween.tween(died, {alpha: 1}, 0.5);
    FlxTween.tween(died,{y: died.y + 20}, (Conductor.stepCrochet / 70) * 1, {ease: FlxEase.cubeOut});
    game.camHUD.alpha = 0;
    createSub("",0);
    case 2156:
    FlxTween.tween(died, {alpha: 0}, 0.5);
    FlxTween.tween(died,{y: died.y - 40}, (Conductor.stepCrochet / 70) * 1, {ease: FlxEase.cubeOut});
    case 2160:
    game.camGame.alpha = 0;
    game.startVideo('toothless', true, false, false, true);
    }
}

function onEndSong() {
    if (game.songMisses == 0)
    Achievements.unlock('mm_nomiss');
}