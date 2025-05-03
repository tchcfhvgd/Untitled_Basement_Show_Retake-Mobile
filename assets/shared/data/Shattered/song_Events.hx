import objects.Character;
import objects.BGSprite;
import states.stages.Train;

var trailBF:Character;

function onCreatePost() {
    game.camGame.visible = false;
    game.camHUD.alpha = 0;
    game.camGame.zoom = 0.8;
    game.cameraSpeed = 1000;
    game.boyfriend.cameraPosition[0] -= 150;
    game.health = 2;

    if (ClientPrefs.data.realMode) {
        game.dad.scale.set(game.dad.scale.x - 0.6, game.dad.scale.y - 0.6);
        game.dad.y += 150;
        game.dad.cameraPosition[1] -= 150;
    }

    for (strum in game.opponentStrums.members) {
        strum.color = 0xFF7F7FFF;
    }

    for (strum in game.playerStrums.members) {
        strum.color = 0xFF7F7FFF;
    }

    for (note in game.unspawnNotes)
        {
           if (!note.mustPress) {
           note.multSpeed = 0.5;
           }
            note.color = 0xFF5E5E5E;
        }

        if (!ClientPrefs.data.lowQuality) {
        trailBF = new Character(game.boyfriend.x,game.boyfriend.y + 300, game.boyfriend.curCharacter, true);
        trailBF.flipY = true;
        trailBF.scale.y = 0.5;
        trailBF.alpha = 0.15;
        addBehindBF(trailBF);

        trailDad = new Character(game.dad.x,game.dad.y + 310, game.dad.curCharacter, true);
        trailDad.flipY = true;
        trailDad.flipX = true;
        trailDad.scale.y = 0.5;
        trailDad.alpha = 0.15;
        addBehindDad(trailDad);

		var gd:BGSprite = new BGSprite('game/stages/train/gradient', -500, -10, 1, 1);
        gd.alpha = 0.6;
		addBehindBF(gd);
        }
}

function onUpdatePost(elapsed) {
    if (!ClientPrefs.data.lowQuality) {
    trailBF.animation.copyFrom(game.boyfriend.animation);
    trailDad.animation.copyFrom(game.dad.animation);
    }
}

function onSongStart() {
    game.camGame.visible = true;
}

function onStepHit() {
    switch(curStep)
    {
    case 128:
    game.boyfriend.cameraPosition[0] += 150;
    game.cameraSpeed = 1;
    game.camHUD.alpha = 1;
    case 512:
        FlxTween.tween(game.uiGroup, {alpha: 0}, 0.5);
        FlxTween.tween(game.dad, {alpha: 1}, 0.5);
        FlxTween.tween(game.boyfriend, {alpha: 0.5}, 0.5);
        if (!ClientPrefs.data.middleScroll) {
        for (strum in game.opponentStrums.members) {
            FlxTween.tween(strum, {x: strum.x - 550}, 0.5, {ease: FlxEase.circOut});
        }
    
        for (strum in game.playerStrums.members) {
            FlxTween.tween(strum, {x: strum.x - 320, angle: -360}, 0.5, {ease: FlxEase.circOut});
        } 
    }
    for (i in [game.boyfriend, game.dad]) {
    i.colorTransform.redOffset = i.colorTransform.greenOffset = i.colorTransform.blueOffset = 255;
    i.cameras = [game.camBars];
    }

    game.boyfriend.x -= 190; game.boyfriend.y -= 100; game.boyfriend.scale.set(0.7, 0.7);
    game.dad.x += 50; game.dad.y -= 100; game.dad.scale.set(0.9, 0.9);
    case 576, 704:
        FlxTween.tween(game.dad, {alpha: 0.5}, 0.5);
        FlxTween.tween(game.boyfriend, {alpha: 1}, 0.5);
    case 640:
        FlxTween.tween(game.dad, {alpha: 1}, 0.5);
        FlxTween.tween(game.boyfriend, {alpha: 0.5}, 0.5);
    case 768:
        FlxTween.tween(game.uiGroup, {alpha: 1}, 0.5);
        game.boyfriend.cameraPosition[0] -= 150;
        if (!ClientPrefs.data.middleScroll) {
        for (strum in game.opponentStrums.members) {
            FlxTween.tween(strum, {x: strum.x + 550}, 0.5, {ease: FlxEase.circOut});
        }
    
        for (strum in game.playerStrums.members) {
            FlxTween.tween(strum, {x: strum.x + 320, angle: 360}, 0.5, {ease: FlxEase.circOut});
        }
        }
        FlxTween.tween(game.dad, {alpha: 1}, 0.5);
        FlxTween.tween(game.boyfriend, {alpha: 1}, 0.5);
    for (i in [game.boyfriend, game.dad]) {
    i.colorTransform.redOffset = i.colorTransform.greenOffset = i.colorTransform.blueOffset = 0;
    i.cameras = [game.camGame];
    }
        
    game.boyfriend.x += 190; game.boyfriend.y += 100; game.boyfriend.scale.set(0.8, 0.8);
    game.dad.x -= 50; game.dad.y += 100; game.dad.scale.set(1, 1);
    case 896:
    game.boyfriend.cameraPosition[0] += 150;
    case 1152:
        for (i in [game.camGame, game.camHUD]){
            FlxTween.tween(i, {alpha: 0}, 7);
        }
        FlxTween.tween(game.camGame, {zoom: game.camGame.zoom - 1}, 30);
    case 1218:
        game.startVideo('W2 End', true, false, false, true);
    }
}

function goodNoteHit(note) {
    for (splash in game.grpNoteSplashes) {
        splash.color = 0xFFCCCCCC;
    }
}

function opponentNoteHit(note) {
    for (splash in game.grpNoteSplashes) {
        splash.color = 0xFFCCCCCC;
    }
}