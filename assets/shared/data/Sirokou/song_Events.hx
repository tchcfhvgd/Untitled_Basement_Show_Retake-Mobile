import states.stages.Basement;
import psychlua.LuaUtils;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxGradient;
import openfl.filters.ShaderFilter;
import shaders.tbs.GlitchShake;
import objects.BGSprite;
import backend.Achievements;
import openfl.geom.ColorTransform;

// wow that's alot of mess, no wonder why is the song laggy asf

var particles:FlxTypedGroup<FlxSprite>;
var particleShit:Array<Int> = [];
var fireHUD:FlxSprite;
var heatwaveShader;
var redOverlay:FlxSprite;

var blackSpr:FlxSprite;
var jsImage:FlxSprite;
var fjsImage:FlxSprite;
var kn:FlxSprite;
var specialP:Bool = false;

var fakeBg:BGSprite;

var blackSpr1:FlxSprite;
var blackSpr2:FlxSprite;
var gradientBar:FlxSprite = new FlxSprite(-9000, 0).makeGraphic(FlxG.width + 1000, 1, 0xFFFFFFFF);

var localShader4:GlitchShake = new GlitchShake();
var camOutside:FlxCamera = new FlxCamera();
var camInside:FlxCamera = new FlxCamera();
var jerryThing:FlxSprite;

var bouncyBoi:Bool = false;
function onBeatHit() {
    if (fireHUD.y == 190) {
        if (curBeat % game.beatPerc == 0) redOverlay.alpha = 0.5;
    }
if (bouncyBoi) {
    if (curBeat % 2 == 0) {
        for (n in 1...4) {
            for (i in [game.opponentStrums.members[n],game.playerStrums.members[n]]) {
                i.scale.set(i.scale.x + 0.1, i.scale.y + 0.1);
                i.y += 20 * n;
                FlxTween.tween(i, {y: i.y - 20 * n}, 0.2);
                FlxTween.tween(i.scale, {x: i.scale.x - 0.1, y: i.scale.y - 0.1}, 0.2);
            }
        }
        for (i in [game.opponentStrums.members[0],game.playerStrums.members[0]]) {
            i.scale.set(i.scale.x + 0.1, i.scale.y + 0.1);
            i.y -= 20;
            FlxTween.tween(i, {y: i.y + 20}, 0.2);
            FlxTween.tween(i.scale, {x: i.scale.x - 0.1, y: i.scale.y - 0.1}, 0.2);
        }
        }
        else if (curBeat % 2 == 1) {
        for (n in 1...4) {
            for (i in [game.opponentStrums.members[n],game.playerStrums.members[n]]) {
                i.scale.set(i.scale.x + 0.1, i.scale.y + 0.1);
                i.y -= 20 * n;
                FlxTween.tween(i, {y: i.y + 20 * n}, 0.2);
                FlxTween.tween(i.scale, {x: i.scale.x - 0.1, y: i.scale.y - 0.1}, 0.2);
            }
        }
            for (i in [game.opponentStrums.members[0],game.playerStrums.members[0]]) {
                i.scale.set(i.scale.x + 0.1, i.scale.y + 0.1);
                i.y += 20;
                FlxTween.tween(i, {y: i.y - 20}, 0.2);
                FlxTween.tween(i.scale, {x: i.scale.x - 0.1, y: i.scale.y - 0.1}, 0.2);
            }
        }
}
}

function onCreate()
{
    blackSpr = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
        -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
    blackSpr.scrollFactor.set();
    game.addBehindGF(blackSpr);

	jsImage = new FlxSprite().loadGraphic(Paths.image('game/js/JS 3'));
    jsImage.cameras = [game.camOther];
    jsImage.alpha = 0;
	insert(5, jsImage);

    if (ClientPrefs.data.shaders) {
    loll = new FlxSprite().loadGraphic(Paths.image('game/backupvig'));
    loll.cameras = [game.camBars];
	insert(1, loll);
    }
}

function onCreatePost() {
    for (i in [game.scoreTxt, game.iconP1, game.iconP2, game.healthBar, game.healthBar.bg]) {
        i.alpha = 0;
    }
    Basement.fire.y += 500;
    game.addCharacterToList('mouse 3', 'dad');
    Basement.blackScreen.visible = game.comboGroup.visible = false;
    game.boyfriend.cameras = game.dad.cameras = [camOther];
    game.boyfriend.y -= 370; game.dad.y -= 350;
    game.dad.x -= 50;
    game.gf.alpha = game.camHUD.alpha = game.boyfriend.alpha = game.dad.alpha = 0;
    camGame.zoom = 1.15;
    PlayState.instance.boyfriend.colorTransform.blueOffset = PlayState.instance.boyfriend.colorTransform.redOffset = PlayState.instance.boyfriend.colorTransform.greenOffset = 255;
    PlayState.instance.dad.colorTransform.blueOffset = PlayState.instance.dad.colorTransform.redOffset = PlayState.instance.dad.colorTransform.greenOffset = 255;

    particles = new FlxTypedGroup();
    game.add(particles);

    gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00000000,0xAAFFFFFF], 1, 90, true);
    gradientBar.y = 800;
    gradientBar.x -= 4000;
    gradientBar.scale.y = 3.3;
    gradientBar.scale.x = 40;
    gradientBar.scrollFactor.set();
    gradientBar.updateHitbox();
    game.add(gradientBar);

    fakeBg = new BGSprite('game/stages/basement/basementhell', -600, -200, 1, 1);

    for (cam in [game.camGame, game.camBars, game.camHUD, game.camOther]) FlxG.cameras.remove(cam, false);
    for (cam in [game.camGame, camInside, game.camBars, game.camHUD, camOutside, game.camOther]) {cam.bgColor = 0x00000000; FlxG.cameras.add(cam, cam == camGame);}

    localShader4.iMouseX.value = [630];
    localShader4.NUM_SAMPLES.value = [12];

    if (ClientPrefs.data.shaders) {
    camOutside.setFilters([new ShaderFilter(localShader4)]);
    }
    camOutside.alpha = 0;

	fjsImage = new FlxSprite().loadGraphic(Paths.image('game/js/JS 4'));
    fjsImage.cameras = [camOutside];
	add(fjsImage);

    kn = new FlxSprite().loadGraphic(Paths.image('game/daKnife'));
    kn.screenCenter();
    kn.alpha = 0;
    kn.scale.set(0.6, 0.6);
    kn.cameras = [camOther];
	add(kn);

    for (note in game.unspawnNotes) {
        if (ClientPrefs.data.diffTBS == 'Baby' && note.noteType == 'knife') {
            note.destroy();
        }
    }

    fireHUD = new FlxSprite(370, 190);
    fireHUD.y += 1300;
    fireHUD.frames = Paths.getSparrowAtlas('game/stages/basement/fire_hud');
    fireHUD.animation.addByPrefix('fire', 'fire', 60, true);
    fireHUD.scrollFactor.set();
    fireHUD.color = 0xFFFF9B9B;
    fireHUD.camera = camInside;
    fireHUD.blend = LuaUtils.blendModeFromString('screen');
    fireHUD.animation.play('fire');
    fireHUD.scale.set(4,4);
    game.add(fireHUD);


    redOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
    redOverlay.alpha = 0;
    redOverlay.scrollFactor.set();
    redOverlay.blend = LuaUtils.blendModeFromString('multiply');
    redOverlay.cameras = [game.camHUD];
    game.add(redOverlay);

    jerryThing = new FlxSprite().loadGraphic(Paths.image('game/icons/iconThing'));
    jerryThing.cameras = [game.camHUD];
    jerryThing.alpha = 0;
    game.add(jerryThing);

    game.initLuaShader('heatwave'); // i love sunday's desolation
    heatwaveShader = game.createRuntimeShader('heatwave'); // and yes it's a shader.

    heatwaveShader.setFloat('strength', 0.4);
    heatwaveShader.setFloat('speed', 2);
}

var totalTime:Float = 0;

function goodNoteHit(note) {
    if (!note.isSustainNote && note.noteType == 'knife') {
    camOutside.alpha = 1;
    var kills = Achievements.addScore("js");
    FlxTween.tween(camOutside, {alpha: 0}, 0.5, {startDelay: ((ClientPrefs.data.diffTBS == 'Normal') ? 0.15 : 3)});
    }
}

function onUpdatePost(elapsed) {
    totalTime += elapsed;

    heatwaveShader.setFloat('time', totalTime);

    fjsImage.setPosition(FlxG.random.float(-10, 10),FlxG.random.float(-10, 10));

    if (curStep >= 1840) game.camHUD.angle =  Math.sin((Conductor.songPosition / 3000) * (Conductor.bpm / 150) * 3.0);

    localShader4.iTime.value = [totalTime];
    localShader4.glitchMultiply.value = [FlxG.random.float(-0.2, 0.5)];

    if (fireHUD.y == 190) {
        redOverlay.alpha = FlxMath.lerp(redOverlay.alpha, 0.07, 0.05);
    }

if (specialP) {
    for (i in 0...particles.members.length){
        particles.members[i].angle = particles.members[i].angle + Math.sin(Conductor.songPosition / Conductor.crochet * Math.PI / 2) * particleShit[i];
    }
    game.timeTxt.text = '8'; // vcr doesn't have the infinity symbol so yeah.
    game.timeTxt.angle = 90;
}
if (specialP) {
game.songLength = FlxG.random.int(0, 222000);
}
else {
game.songLength = FlxG.sound.music.length;
game.timeTxt.angle = 0;
}

if (game.dad.curCharacter == 'mouse 3') {
//too lazy to type the actual thing
var scaley = FlxMath.bound(1 + (0.25 * FlxMath.fastSin((Conductor.songPosition / 1000) * (Conductor.bpm / 60)/2 + (1 * (Conductor.stepCrochet / 1000)))), 1, 999);
jerryThing.angle += 3;
jerryThing.setPosition(game.iconP2.x - 20, game.iconP2.y);
jerryThing.scale.set(scaley, scaley);
jerryThing.alpha = FlxMath.lerp(jerryThing.alpha, (game.health > 1.6 ? game.iconP2.alpha * 0.3 : 0), 0.1);
}
}

var particleSpawm:Bool = false;

function onStepHit() {
    if (particleSpawm) {
    if (curStep > 2639) {
        if (curStep % 3 == 0) {
        spawnParticle(FlxG.random.int(-1,1));
        }
    }
    else {
        spawnParticle(FlxG.random.int(-1,1));
    }
    }
    switch(curStep)
    {
        case 1:
        game.enableTrail = false;
        game.boyfriend.danceEveryNumBeats =  game.dad.danceEveryNumBeats = 4;
        FlxTween.tween(game.dad, {alpha: 1}, 0.5);
        FlxTween.tween(game.dad, {x: game.dad.x + 160}, 5.8);
        case 64:
        FlxTween.tween(game.dad, {alpha: 0}, 0.5);
        FlxTween.tween(game.boyfriend, {alpha: 1}, 0.5);
        FlxTween.tween(game.boyfriend, {x: game.boyfriend.x - 160}, 4.3);
        case 96: FlxTween.tween(game.boyfriend, {alpha: 0}, 0.5);
        case 112:
        game.boyfriend.cameraPosition[0] -= 150;
        game.boyfriend.danceEveryNumBeats =  game.dad.danceEveryNumBeats = 2;
        FlxTween.tween(kn, {alpha: 2}, 0.6, {ease: FlxEase.quadOut, type: LuaUtils.getTweenTypeByString('backward')});
        case 119:
            FlxTween.tween(game.boyfriend, {alpha: 1}, 0.5);
            FlxTween.tween(game.dad, {alpha: 1}, 0.5);
            FlxTween.tween(game.camHUD, {alpha: 1}, 0.5);
            game.boyfriend.cameras = game.dad.cameras = [camGame];
            game.boyfriend.y += 370; game.dad.y += 350;
            game.dad.x += 50 - 160;
            game.boyfriend.x -= 160;
            game.boyfriend.x += 1000;
        case 192, 208, 224, 240: FlxTween.num(game.dad.cameraPosition[1], game.dad.cameraPosition[1] + 20, 0.4, {ease: FlxEase.sinInOut}, function(num) {game.dad.cameraPosition[1] = num;});
        case 256:
        game.dad.cameraPosition[1] -= 20 * 4;
        case 496:
            for (i in game.opponentStrums.members) {
                i.color = 0xffaa8282;
                i.rgbShader.r = 0xFFFF3D47;
                i.rgbShader.b = 0xFF4A0000;
            }
        
            for (note in game.unspawnNotes)
            {
                if (!note.mustPress) {
                note.rgbShader.r = 0xFFB72930;
                note.rgbShader.b = 0xFF4A0000;
                note.noteSplashData.r = 0xFFB72930;
                note.noteSplashData.g = 0xFF6C0000;
                }
            }
            pissYourself("JS 3", 1);
        case 512:
        game.boyfriend.cameraPosition[0] += 150;
        jsImage.alpha = 0;
        Basement.blackScreen.visible = game.comboGroup.visible = true;
            for (i in [game.scoreTxt, game.iconP1, game.iconP2, game.healthBar, game.healthBar.bg]) {
                i.alpha = 1;
            }
            game.gf.alpha = 1;
            game.boyfriend.x -= 730;
            blackSpr.alpha = 0;
        case 795:
            pissYourself("JS 3", 0.3);
        case 800, 864, 992, 1024 : jsImage.alpha = 0; if (curStep == 800) {
        FlxTween.tween(fireHUD, {y: fireHUD.y - 1300}, 0.5, {ease: FlxEase.quadInOut});
        
        if (ClientPrefs.data.shaders) {
        game.camGame.setFilters([new ShaderFilter(heatwaveShader)]);
        game.camHUD.setFilters([new ShaderFilter(heatwaveShader)]);
        }
        }
        case 976, 1108, 1244: 
        pissYourself("JS 1", 0.6);
        game.isCameraOnForcedPos = true;
        camFollow.setPosition(game.dad.getMidpoint().x + 150 + game.dad.cameraPosition[0] + opponentCameraOffset[0], game.dad.getMidpoint().y - 100 + game.dad.cameraPosition[1] + game.opponentCameraOffset[1]);
        case 984, 1017, 1116:
        pissYourself("JS 2", 0.6);
        game.isCameraOnForcedPos = true;
        camFollow.setPosition(game.boyfriend.getMidpoint().x - 100 - game.boyfriend.cameraPosition[0] - game.boyfriendCameraOffset[0], game.boyfriend.getMidpoint().y - 100 + game.boyfriend.cameraPosition[1] - game.boyfriendCameraOffset[1]);
        case 1024, 1120, 1248: pissYourself("JS 2", 0);
        case 1312:
        if (ClientPrefs.data.shaders) {
        game.camGame.setFilters([]);
        game.camHUD.setFilters([]);
        }
        FlxTween.tween(fireHUD, {y: fireHUD.y + 1300}, 0.5, {ease: FlxEase.quadInOut});
        case 1431:
            redOverlay.alpha = 0;
            game.gf.alpha = 0.5;
            for (i in [game.dad, game.boyfriend, game.gf]) {
                i.shader = null;
                i.colorTransform.color = (i == game.dad ? 0xFFC92020: FlxColor.fromRGB(i.healthColorArray[0], i.healthColorArray[1], i.healthColorArray[2]));
            }
            Basement.spotlight.visible = false;
            Basement.bg.alpha = 0.45;
            game.defaultCamZoom = 0.75;
            FlxTween.tween(game.camHUD, {alpha: 1}, 0.5);
            game.cameraSpeed = 1;
            FlxTween.tween(game.camGame, {alpha: 1}, 0.5);
        case 1568:
            for (i in [game.dad, game.boyfriend, game.gf]) {
                i.shader = Basement.charShader;
                i.setColorTransform();
            }
        Basement.spotlight.visible = true;
        Basement.bg.alpha = 1;
        case 1760: game.gf.shader = game.dad.shader = game.boyfriend.shader = null; Basement.bg.alpha = game.gf.alpha = 0.5; Basement.spotlight.visible = false;
        case 1824:
            game.cinematicChange(0.83, 0.8);
            FlxTween.tween(game.timeTxt.scale, {x: 1.63, y: 1.63}, 0.8);
            FlxTween.tween(game.timeTxt, {y: (ClientPrefs.data.downScroll ? game.timeTxt.y - 340 : game.timeTxt.y + 340)}, 0.8);
            FlxTween.tween(game, {songLength: 222222000}, 10);
        case 1968:
            FlxTween.tween(game.camFollow, {x: game.camFollow.x + 1200}, 1);
            FlxTween.tween(Basement.aSpotlight, {x: Basement.aSpotlight.x + 1200}, 1);
        case 2080: pissYourself("JS 3", 1);
        case 2096:
            gradientBar.colorTransform.color = 0xFFFFA3A3;
            FlxTween.tween(Basement.aSpotlight, {x: Basement.aSpotlight.x - 1200}, 1);
            game.isCameraOnForcedPos = false;
            game.cameraSpeed = 1;
            game.defaultCamZoom = 0.55;
            pissYourself("JS 3", 0);
        case 2224, 2480:
            FlxTween.tween(Basement.aSpotlight, {x: Basement.aSpotlight.x + 1200}, 1);
        case 2352: 
            game.camGame.flash(0xFFFF0000, 0.5, null, false);
            gradientBar.colorTransform.color = 0xFFFF4343;
            if (ClientPrefs.data.shaders) {
            game.camGame.setFilters([new ShaderFilter(heatwaveShader)]);
            game.camHUD.setFilters([new ShaderFilter(heatwaveShader)]);
            }
             FlxTween.tween(fireHUD, {y: fireHUD.y - 1300}, 0.5, {ease: FlxEase.quadInOut});
            game.isCameraOnForcedPos = true;
            game.camFollow.setPosition(900, 700);
            FlxTween.tween(Basement.aSpotlight, {x: Basement.aSpotlight.x - 1200}, 1);
        case 2608:
            FlxTween.tween(Basement.aSpotlight, {x: Basement.aSpotlight.x - 1200}, 1);
            FlxTween.tween(Basement.aSpotlight, {alpha: 0}, 0.5);
        case 2640:
            game.camFollow.setPosition(650, 450);
            game.camGame.shake(0.002, 99);
            game.camHUD.shake(0.002, 99);

            Basement.spotlight.visible = Basement.blackScreen.visible = false;
            //game.triggerEvent('Event Trigger', 'changeBG', 'basementhell');
            //Basement.bg.loadGraphic(Paths.image('stages/basement/basementhell'));
            game.initLuaShader('lighting'); // i love sunday's desolation
            var lightingShader = game.createRuntimeShader('lighting'); // and yes it's a shader.
    
            lightingShader.setFloatArray('overlayColor', [1, 0, 0, 0]);
            lightingShader.setFloatArray('satinColor', [0.1, 0, 0, 0.8]);
            lightingShader.setFloatArray('innerShadowColor', [0.8, 0, 0, 0.2]);
            lightingShader.setFloat('innerShadowAngle', 4);
            lightingShader.setFloat('innerShadowDistance', 80);
    
            game.dad.shader = lightingShader;
            game.boyfriend.shader = game.gf.shader = lightingShader;

            for (i in [game.healthBar, game.healthBar.bg, game.iconP1, game.iconP2]) {
                FlxTween.tween(i, {alpha: 1}, 0.5);
            }
            FlxTween.tween(game.scoreTxt, {y: game.scoreTxt.y + (ClientPrefs.data.downScroll ? 40 : 0)}, 0.5);

            specialP = false;
            bouncyBoi = true;
            game.remove(particles);
            game.remove(gradientBar);

            game.remove(blackSpr1);
            game.remove(blackSpr2);

            if (!ClientPrefs.data.middleScroll) {
                for (strum in game.opponentStrums.members) {
                    FlxTween.tween(strum, {x: strum.x + 550}, 0.5, {ease: FlxEase.circOut});
                }
            
                for (strum in game.playerStrums.members) {
                    FlxTween.tween(strum, {x: strum.x + 320, angle: strum.angle + 360}, 0.5, {ease: FlxEase.circOut});
                }
            }
            game.remove(blackSpr); blackSpr.destroy();
            game.insert(members.indexOf(Basement.bg),Basement.fire);
            game.insert(members.indexOf(Basement.bg),Basement.redScreen);
            game.insert(members.indexOf(Basement.bg),fakeBg);
            FlxTween.tween(Basement.fire, {y: Basement.fire.y - 500}, 0.7, {ease: FlxEase.quadInOut});
            game.gf.visible = true;
            game.gf.alpha = 1;
            game.timeBar.alpha = game.timeBar.bg.alpha = 1;
            game.boyfriend.x -= 500;
            game.defaultHUDZoom = 0.7;
            game.scaredGF = false;
            game.gf.playAnim('scared', true);
            game.gf.specialAnim = true;
            PlayState.instance.boyfriend.colorTransform.blueOffset = PlayState.instance.boyfriend.colorTransform.redOffset = PlayState.instance.boyfriend.colorTransform.greenOffset = 0;
            PlayState.instance.dad.colorTransform.blueOffset = PlayState.instance.dad.colorTransform.redOffset = PlayState.instance.dad.colorTransform.greenOffset = 0;
            case 2864:
                game.defaultHUDZoom = 1;
                game.startVideo('Lyrics', true, false, false, true, game.camBars);
                game.cinematicChange(0, 0.5);
                game.camGame.visible = false;
                bouncyBoi = false;
                for (i in [game.healthBar, game.healthBar.bg, game.iconP1, game.iconP2, game.timeTxt, game.timeBar, game.timeBar.bg, game.scoreTxt, game.judTxt]) {
                    FlxTween.tween(i, {alpha: 0}, 0.5);
                }
                for (i in game.opponentStrums.members) {
                    FlxTween.tween(i, {angle: 180}, 3.5);
                    FlxTween.tween(i, {y: i.y + 1000}, 4.5, {ease: FlxEase.backInOut});
                    }
                    for (i in game.playerStrums.members) {
                    FlxTween.tween(i, {angle: 180}, 3.5);
                    FlxTween.tween(i, {y: i.y + 1000}, 4.5, {ease: FlxEase.backInOut});
                    }
    }
}

function onEvent(name:String, value1:String, value2:String)
{    
if (name == 'Change Character') {
    if (ClientPrefs.data.realMode) {
        game.dad.scale.set(game.dad.scale.x - 0.45, game.dad.scale.y - 0.45);
        game.dad.y += 150;
        game.dad.cameraPosition[1] -= 150;
    }
}
if (name == 'Event Trigger') {
    if (value1 == 'alpha') {
        blackSpr.cameras = [game.camBars];
        blackSpr.alpha = Std.parseFloat(value2);
    }
    if (value2 == 'specialPart') {
        //blackSpr.alpha = 1;

        specialP = particleSpawm = true;

        for (i in [game.healthBar, game.healthBar.bg, game.iconP1, game.iconP2]) {
            FlxTween.tween(i, {alpha: 0}, 0.5);
        }

        FlxTween.tween(game.scoreTxt, {y: game.scoreTxt.y - (ClientPrefs.data.downScroll ? 40 : 0)}, 0.5);

        blackSpr1 = new FlxSprite(game.dad.x + 380, game.dad.y + 750).makeGraphic(460, 1000, FlxColor.GRAY);
        blackSpr1.shader = Basement.charShader;
        game.addBehindDad(blackSpr1);
    
        blackSpr2 = new FlxSprite(game.boyfriend.x + 690, game.boyfriend.y + 400).makeGraphic(460, 1000, FlxColor.GRAY);
        blackSpr2.shader = Basement.charShader;
        game.addBehindDad(blackSpr2);

        game.cinematicChange(0.2);
        game.timeTxt.scale.set(1,1); game.timeTxt.y += (ClientPrefs.data.downScroll ? 340 : -340);
    
        Basement.aSpotlight.setPosition(Basement.aSpotlight.x + 70, Basement.aSpotlight.y + 300);

        game.timeBar.alpha = game.timeBar.bg.alpha = 0;
    
        game.defaultCamZoom += 0.2;
        game.isCameraOnForcedPos = true;
        Basement.aSpotlight.visible = true;
        game.camFollow.setPosition(Basement.aSpotlight.getMidpoint().x, Basement.aSpotlight.getMidpoint().y + 200);
        game.cameraSpeed = 1000;
        FlxTween.tween(gradientBar, {y: -260}, 1);
    
        Basement.blackScreen.visible = Basement.bg.visible = game.gf.visible = false;
        game.dad.shader = game.boyfriend.shader = null;
        game.boyfriend.x += 500;
        PlayState.instance.boyfriend.colorTransform.blueOffset = PlayState.instance.boyfriend.colorTransform.redOffset = PlayState.instance.boyfriend.colorTransform.greenOffset = 255;
        PlayState.instance.dad.colorTransform.blueOffset = PlayState.instance.dad.colorTransform.redOffset = PlayState.instance.dad.colorTransform.greenOffset = 255;

        if (!ClientPrefs.data.middleScroll) {
            for (strum in game.opponentStrums.members) {
                FlxTween.tween(strum, {x: strum.x - 550}, 1.5, {ease: FlxEase.circInOut});
            }
        
            for (strum in game.playerStrums.members) {
                FlxTween.tween(strum, {x: strum.x - 320, angle: strum.angle - 360}, 1.5, {ease: FlxEase.circInOut});
            } 
        }
    }
}
}

function pissYourself(image:String, alpha:Float) {
jsImage.loadGraphic(Paths.image('game/js/' + image));
jsImage.alpha = alpha;
}

function spawnParticle(thiss:Int) {
    if (curStep > 2639) {
        var randoNum3 = FlxG.random.float(0.3,1);
        var particle = new FlxSprite(FlxG.random.float(-1400,2200),1500).loadGraphic(Paths.image('bparticle'));
        if (thiss == 1) {
        particle.scale.set(FlxG.random.float(1,2.6),FlxG.random.float(1,2.6));
        particles.add(particle);
        }
        else {
        particle.scale.set(FlxG.random.float(0.7,1.6),FlxG.random.float(0.7,1.6));
        game.addBehindDad(particle);
        }
        var randoNum = FlxG.random.int(-3,3);
        particleShit.push(randoNum);
        var randoNum2 = FlxG.random.int(5,15);
    
        FlxTween.tween(particle.scale, {x: 0.2}, randoNum2);
        FlxTween.tween(particle.scale, {y: 0.2}, randoNum2);
        FlxTween.tween(particle, {y: -500}, FlxG.random.int(7,17), {ease: FlxEase.circOut}, {
            onComplete: function(tween:FlxTween){
                particle.kill();
            }
        });
    }
    else {
    var randoNum3 = FlxG.random.float(0.3,1);
    var particle = new FlxSprite(FlxG.random.float(-1400,2200),1500).loadGraphic(Paths.image('particle'));
    particle.scale.set(randoNum3,randoNum3);
    if (thiss == 1) {
    particle.scale.set(FlxG.random.float(1,1.5),FlxG.random.float(1,1.5));
    particles.add(particle);
    }
    else {
    particle.scale.set(FlxG.random.float(0.7,1),FlxG.random.float(0.7,1));
    game.insert(0,particle);
    }
    var randoNum = FlxG.random.int(-3,3);
    particleShit.push(randoNum);
    var randoNum2 = FlxG.random.int(5,15);

    if (curStep > 2090 && curStep < 2351) particle.color = 0xFFFFA3A3;
    if (curStep > 2351 && curStep > 2659) particle.color = 0xFFFF2A2A;

    FlxTween.tween(particle, {alpha: 0}, FlxG.random.int(7,10));
    FlxTween.tween(particle.scale, {x: 0.2}, randoNum2);
    FlxTween.tween(particle.scale, {y: 0.2}, randoNum2);
    FlxTween.tween(particle, {y: -500}, FlxG.random.int(7,17), {ease: FlxEase.circOut}, {
        onComplete: function(tween:FlxTween){
            particle.kill();
        }
    });
    }
}