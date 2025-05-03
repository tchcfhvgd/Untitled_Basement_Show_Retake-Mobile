import flixel.math.FlxMath;
import shaders.tbs.GlitchShake;
import states.stages.Freeze;

var lightingShaderd;
var lightingShader;
var blackSpr:FlxSprite;

var numbie:Float = 0;
var localShader4:GlitchShake = new GlitchShake();

function onCreatePost() {
    game.camMoveOff = 5;
    localShader4.iMouseX.value = [numbie];
    localShader4.NUM_SAMPLES.value = [12];

    game.initLuaShader('lighting'); // i love sunday's desolation
    lightingShader = game.createRuntimeShader('lighting'); // and yes it's a shader.

    lightingShader.setFloatArray('overlayColor', [1, 0, 0, 0]);
    lightingShader.setFloatArray('satinColor', [0.3, 0.3, 0.5, 0.7]);
    lightingShader.setFloatArray('innerShadowColor', [0.6, 0.6, 0.1, 0.2]);
    lightingShader.setFloat('innerShadowAngle', 3);
    lightingShader.setFloat('innerShadowDistance', 60);

    lightingShaderd = game.createRuntimeShader('lighting'); // and yes it's a shader.

    lightingShaderd.setFloatArray('overlayColor', [1, 0, 0, 0]);
    lightingShaderd.setFloatArray('satinColor', [0.7, 0.7, 1, 0.7]);
    lightingShaderd.setFloatArray('innerShadowColor', [0.8, 0.8, 0.1, 0.2]);
    lightingShaderd.setFloat('innerShadowAngle', 0);
    lightingShaderd.setFloat('innerShadowDistance', 60);

    game.dad.shader = lightingShaderd;
    game.boyfriend.shader = lightingShader;
    game.camHUD.alpha = 0;
    game.isCameraOnForcedPos = true;

    blackSpr = new FlxSprite(-110, -100).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.WHITE);
    blackSpr.scrollFactor.set();
    blackSpr.color = FlxColor.BLACK;
    blackSpr.cameras = [game.camBars];
    game.add(blackSpr);

    game.camGame.zoom += 3;

	snowBG = new FlxSprite().loadGraphic(Paths.image("game/stages/snow/events/snow3"));
	snowBG.alpha = 0;
	snowBG.cameras = [game.camOther];
	game.add(snowBG);

	snowBG2 = new FlxSprite().loadGraphic(Paths.image("game/stages/snow/events/snow2"));
	snowBG2.alpha = 0;
	snowBG2.cameras = [game.camOther];
	game.add(snowBG2);

	socool = new FlxSprite().loadGraphic(Paths.image("game/stages/snow/events/cold"));
	socool.alpha = 0;
	socool.cameras = [game.camOther];
	game.add(socool);

    game.cameraSpeed = 1000;

    for (note in game.unspawnNotes) {
        if (ClientPrefs.data.diffTBS == 'Baby' && note.noteType == 'snow') {
            note.destroy();
        }
    }

    if (ClientPrefs.data.realMode) {
        game.dad.scale.set(game.dad.scale.x - 0.32, game.dad.scale.y - 0.32);
        game.dad.y += 100;
        game.dad.cameraPosition[1] -= 150;
    }
}

var totalTime:Float = 0;
function onUpdatePost(elapsed) {
    if (curStep > 1 && curStep < 191) {
    game.camGame.zoom =  FlxMath.lerp(game.camGame.zoom, 0.6, 0.0012);
    blackSpr.alpha = FlxMath.lerp(blackSpr.alpha, 0, 0.001);
    }

    totalTime += elapsed;
    localShader4.iMouseX.value = [numbie];

    localShader4.iTime.value = [totalTime];
    localShader4.glitchMultiply.value = [FlxG.random.float(0.2,0.3)];

    if (curStep > 1312 && curStep < 1822)  {
    game.camHUD.x = Math.sin((Conductor.songPosition / 3000) * (Conductor.bpm / 80) * 3) * 7;
    game.camHUD.angle = Math.sin((Conductor.songPosition / 3000) * (Conductor.bpm / 80) * 2) * 0.7;
    }
}

function goodNoteHit(note) {
    if (!note.isSustainNote && note.noteType == 'snow') {
    game.camGame.shake(0.01, 0.02);
    game.camHUD.shake(0.01, 0.02);
    game.health -= 0.04;
    FlxTween.tween(snowBG, {alpha: ClientPrefs.data.diffTBS == 'Hard' ? snowBG.alpha + 0.4 : snowBG.alpha + 0.25}, 0.27, {ease: FlxEase.expoOut});
    //snowBG.alpha += ClientPrefs.data.diffTBS == 'Hard' ? 0.4 : 0.15;
    new FlxTimer().start(1 * (ClientPrefs.data.diffTBS == 'Hard' ? 3 : 2), function(tmr:FlxTimer){
    FlxTween.tween(snowBG, {alpha: 0}, 0.5);
    });
    var freezes = Achievements.addScore("snowHit");
    }
}

function onSongStart() {
    game.isCameraOnForcedPos = true;
}

function onStepHit() {
    switch(curStep) {
        case 1, 1184, 2208:
            game.isCameraOnForcedPos = true;
            game.camFollow.setPosition(game.dad.getMidpoint().x + 355 + game.dad.cameraPosition[0] + game.opponentCameraOffset[0],game.dad.getMidpoint().y - 100 + game.dad.cameraPosition[1] + game.opponentCameraOffset[1]);
            if (curStep == 1) {game.camFollow.x -= 750; game.camFollow.y -= 280; game.beatPerc = 9999;}
        case 64:
            FlxTween.tween(game.camFollow, {x: game.camFollow.x + 750, y: game.camFollow.y + 280}, 9.6);
            game.cameraSpeed = 1;
            FlxTween.tween(game.camGame, {zoom: game.camGame.zoom - 1.93}, 9.6);
            game.camOther.flash(0x33FFFFFF, 0.5, null, false);
            blackSpr.alpha -= 0.45; 
            //game.camGame.zoom -= 1.75;
        case 192:
            blackSpr.alpha = 0;
            game.isCameraOnForcedPos = false;
            game.camHUD.alpha = 1;
        case 448:
            FlxTween.tween(game.camHUD, {alpha: 0}, 0.5);
        case 464:
            game.cinematicChange(0.74, 1.3, 'circInOut');
            FlxTween.num(numbie, 790, 1.3, {ease: FlxEase.circInOut}, function(num) {numbie = num;});
            game.camGame.pushFilter('glitch', new ShaderFilter(localShader4));

            for (i in game.opponentStrums.members) {
                i.rgbShader.r = 0xFF98E7FF;
                i.rgbShader.b = 0xFF026380;
            }
        
            for (note in game.unspawnNotes)
            {
                if (!note.mustPress) {
                    note.noteSplashData.texture = 'game/noteSplashes/custom/noteSplashes-ice';
					note.rgbShader.r = 0xFF98E7FF;
                    note.rgbShader.b = 0xFF026380;
					note.noteSplashData.r = 0xFF37D2FF;
                }
            }
            FlxTween.tween(game, {defaultCamZoom: 1.5}, 1.25);
            FlxTween.tween(blackSpr, {alpha: 0.9}, 1.25);
        case 480:
            game.cinematicChange(0, 1, 'backOut');
            game.camGame.removeFilter('glitch');
            game.camHUD.alpha = 1;
            numbie = 0;
            FlxTween.tween(game, {defaultCamZoom: 0.85}, 0.01);
            FlxTween.tween(blackSpr, {alpha: 0}, 0.01);
        case 736:
            blackSpr.cameras = [game.camGame];
            game.remove(blackSpr, true); game.addBehindBF(blackSpr);
            game.defaultCamZoom += 0.2;
            game.boyfriend.cameraPosition[0] -= 40; game.boyfriend.cameraPosition[1] += 45;
            game.cinematicChange(0.3, 0.5);
            FlxTween.tween(blackSpr, {alpha: 0.7}, 0.5);
        case 792:
            game.cinematicChange(0, 1.4, 'circInOut');
            FlxTween.tween(blackSpr, {alpha: 0}, 0.5);
            FlxTween.tween(game, {defaultCamZoom: game.defaultCamZoom - 0.2}, 0.5);
            game.boyfriend.cameraPosition[0] += 40; game.boyfriend.cameraPosition[1] -= 45;
        case 800:
            game.remove(blackSpr, true);
        case 1567:
        for (cold in [socool, snowBG2]) FlxTween.tween(cold, {alpha: 0}, 0.5);
        case 1824:
        game.cinematicChange(0, 1, 'backOut');
        game.camGame.removeFilter('glitch');
        numbie = 0;
        FlxTween.tween(game, {defaultCamZoom: 0.85}, 0.01);
        game.enableTrail = Freeze.canTrigger = true;
        game.defaultHUDZoom = 1;
        game.camHUD.x = 0;
        game.camHUD.angle = 0;
        game.dad.shader = lightingShaderd;
        game.boyfriend.shader = lightingShader;
        blackSpr.kill();
        FlxTween.tween(Freeze.snow, {alpha: 1}, 0.5);
        for (i in [game.boyfriend, game.dad]) {
        i.setColorTransform();
        }
        case 1808:
            game.cinematicChange(0.74, 1.3, 'circInOut');
            FlxTween.num(numbie, 790, 1.3, {ease: FlxEase.circInOut}, function(num) {numbie = num;});
            game.camGame.pushFilter('glitch', new ShaderFilter(localShader4));
            FlxTween.tween(game, {defaultCamZoom: 1.5}, 1.25);
        case 1312, 2336: game.isCameraOnForcedPos = false;
        if (curStep == 1312) {
            game.defaultCamZoom += 0.2;
            game.defaultHUDZoom = 0.9;
            game.enableTrail = Freeze.canTrigger = false;
            game.dad.shader = null;
            game.boyfriend.shader = null;
            blackSpr.color = 0xFF001C51;
            game.addBehindDad(blackSpr);
            FlxTween.tween(Freeze.snow, {alpha: 0}, 0.5);
            FlxTween.tween(blackSpr, {alpha: 1}, 0.5);
            for (cold in [socool, snowBG2]) FlxTween.tween(cold, {alpha: 1}, 15.5);
            for (i in [game.boyfriend, game.dad]) {
            i.colorTransform.color = 0xFF98F6FF;
            }
        }
        if (curStep == 2336) {
        game.beatPerc = 4; game.defaultCamZoom += 0.2; game.boyfriend.cameraPosition[1] += 20; game.boyfriend.cameraPosition[1] += 25; game.dad.cameraPosition[1] += 25;}
    }
}

function onEvent(name:String, v1:String, v2:String){
    if (name == 'Change Character') {
        game.dad.shader = lightingShaderd;

        if (ClientPrefs.data.realMode) {
            game.dad.scale.set(game.dad.scale.x - 0.32, game.dad.scale.y - 0.32);
            game.dad.y += 100;
            game.dad.cameraPosition[1] -= 150;
        }
    }
}

function onEndSong() {
    if (game.songMisses == 0 && ClientPrefs.data.diffTBS == 'Hard')
    Achievements.unlock('fb_nomiss');
}