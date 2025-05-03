import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

var cinematicBarTween1:FlxTween = null;
var cinematicBarTween2:FlxTween = null;

var cinematicBar1:FlxSprite;
var cinematicBar2:FlxSprite;

var blackSpr:FlxSprite;

function onCreatePost() {
    game.camZooming = true;
    game.camHUD.alpha = 0;

    blackSpr = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
    blackSpr.scrollFactor.set();
    blackSpr.camera = game.camBars;
    game.add(blackSpr);
    game.defaultCamZoom = 1.5;

    if (ClientPrefs.data.realMode) {
        game.dad.scale.set(game.dad.scale.x - 0.45, game.dad.scale.y - 0.45);
        game.dad.y += 150;
        game.dad.cameraPosition[1] -= 130;
    }

    for (i in 0...2) {
        var cinematicBar = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        cinematicBar.scrollFactor.set();
        add(cinematicBar);

        cinematicBar.scale.set((FlxG.width/2) * 0.19, FlxG.height);
        cinematicBar.updateHitbox();
        cinematicBar.camera = game.camBars;

        if (i == 1) cinematicBar2 = cinematicBar;
        else cinematicBar1 = cinematicBar;
    }
}

function onSongStart() {
    for(i in game.playerStrums.members) {
        i.x -= 52;
    }

    for (i in game.opponentStrums.members) {
        i.x += 52;
    }
    FlxTween.tween(game, {defaultCamZoom: 0.75}, 10);
    FlxTween.tween(blackSpr, {alpha: 0}, 10);
}

function onUpdatePost(elapsed) {
    if (cinematicBarTween2 != null && cinematicBarTween2.active && cinematicBarTween1 != null && cinematicBarTween1.active) {
        for (bar in [cinematicBar1, cinematicBar2]) bar.updateHitbox();
    }
    cinematicBar2.x = FlxG.width - cinematicBar2.width + 13;
}

function onStepHit() {
    if (curStep == 128) {
        for(i in game.playerStrums.members) {
            FlxTween.tween(i, {x: i.x + 52}, 0.5, {ease: FlxEase.quadOut});
        }
    
        for (i in game.opponentStrums.members) {
            FlxTween.tween(i, {x: i.x - 52}, 0.5, {ease: FlxEase.quadOut});
        }
        FlxTween.tween(game.camHUD, {alpha: 1}, 0.5);
        for (twn in [cinematicBarTween1, cinematicBarTween2])
            if (twn != null) twn.cancel();
    
        for (bar in [cinematicBar1, cinematicBar2]) {
            var tween:FlxTween = FlxTween.tween(bar.scale, {x: 0}, 0.5);
            if (bar == cinematicBar1) cinematicBarTween1 = tween;
            else cinematicBarTween2 = tween;
        }
}
}