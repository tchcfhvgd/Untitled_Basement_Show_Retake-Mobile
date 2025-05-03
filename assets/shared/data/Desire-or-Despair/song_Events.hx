import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import objects.Bar;
import objects.BGSprite;
import states.stages.FamishedBG;
import flixel.math.FlxMath;
import backend.CoolUtil;
import flixel.addons.text.FlxTypeText;

var hudTxt:FlxText;
var hudTxt2:FlxText;
var canDo:Bool = true;
var despairBar;
var dbg:FlxSprite;
var blackJumpscare:FlxSprite;
var bbd:BGSprite;

function onStartCountdown() {
    game.skipCountdown = true;
}

function onEvent(name:String, value1:String, value2:String){
    if (name == 'Event Trigger') {
        if (value1 == 'changePos') {
            game.dad.cameraPosition[1] = game.dad.cameraPosition[1] + Std.parseFloat(value2);
        }
    }
}

function onCreatePost() {
    game.camGame.visible = false;
    game.camHUD.y -= 1000;
    game.camZooming = true;

    FamishedBG.dadZoom = 0.9;
    FamishedBG.bfZoom = 1;

    game.healthBar.angle = 90;
    game.timeBar.angle = 180;

    game.healthBar.setPosition(-160, 270);



    hudTxt = new FlxText(0, 300, FlxG.width, "Desire or Despair");
    hudTxt.setFormat(Paths.font("vcr.ttf"), 63, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    hudTxt.borderSize = 1.25;
    hudTxt.cameras = [game.camBars];
    add(hudTxt);

    hudTxt2 = new FlxText(0, hudTxt.y + 70, FlxG.width, "By: Rhodes_W");
    hudTxt2.setFormat(Paths.font("vcr.ttf"), 53, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    hudTxt2.borderSize = 1.25;
    hudTxt2.alpha = 0;
    new FlxTimer().start(2, function(tmr:FlxTimer){
    hudTxt2.alpha = 1;
    });
    new FlxTimer().start(4, function(tmr:FlxTimer){
    for (i in [hudTxt, hudTxt2]) {
    FlxTween.tween(i, {alpha: 0}, 2.5);
    }
    });
    new FlxTimer().start(8, function(tmr:FlxTimer){
    game.skipCountdown = true;
    game.camGame.visible = true;
    game.camHUD.y += 1000;
    canPass = true;
    });
    hudTxt2.cameras = [game.camBars];
    add(hudTxt2);

    healthBar.setColors(0xFF6B5276,0xFF7e7e7e);

    despairBar = new Bar(984, 70, 'game/timeBar',  function() return game.currentBarPorcent, 0, 1);
    despairBar.scrollFactor.set();
    despairBar.visible = !ClientPrefs.data.hideHud;
    despairBar.camera = game.camHUD;
    despairBar.angle = -90;
    despairBar.scale.set(0.7, 1.3);
    despairBar.setColors(0x060214, 0x5B40C0);
    despairBar.updateBar();
    add(despairBar);

    game.timeBar.scale.x = 0.5;

    dbg = new FlxSprite(1143, -70, Paths.image('despairBar'));
    dbg.antialiasing = ClientPrefs.data.antialiasing;
    dbg.cameras = [game.camHUD];
    dbg.scrollFactor.set();
    game.add(dbg);

    blackJumpscare = new FlxSprite(-FlxG.width * FlxG.camera.zoom,-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
    blackJumpscare.scrollFactor.set();
    blackJumpscare.alpha = 0;
    game.addBehindDad(blackJumpscare);

    game.iconP1.y = 505; game.iconP2.y = (ClientPrefs.data.downScroll ? -95 : -25);
    game.healthBar.scale.x = 0.8;

    bbd = new BGSprite('game/stages/alley/despair', 0,0, 0, 0);
    bbd.cameras = [game.camHUD];
    bbd.screenCenter();
    bbd.scale.set(1.3, 1.3);
    bbd.alpha = 0;
    add(bbd);

    for (note in game.unspawnNotes)
        {
            if (!note.mustPress) {
            note.noteSplashData.disabled = true;
            }
        }

    var idots:Array<FlxSprite> = [game.timeTxt, game.timeBar, game.timeBar.bg];
    
    if (ClientPrefs.data.downScroll) {
    game.timeTxt.y -= 370;
    }
    else {
    game.timeTxt.y += 370;
    }
    for(i in idots) {
        if (ClientPrefs.data.downScroll) {
        i.y -= 393;
        }
        else {
        i.y += 393;
        }
    }

    for (note in game.unspawnNotes)
        {
            if (!note.mustPress) {
            note.visible = false;
            }
        }

    game.judTxt.x -= 30;
    game.camHUD.x -= 20;
}

function onUpdatePost(elapsed) {
    game.iconP1.x = game.iconP2.x = 100;

    PlayState.instance.scoreTxt.text = 'Losses: ' + PlayState.instance.songMisses + '                              Survive Rate: ' + CoolUtil.floorDecimal(game.ratingPercent * 100, 2) + '%';
}

function opponentNoteHit(note:Note) {
    if (game.currentBarPorcent > 0) { 
        if (game.amountOfIntense > 0)  {
        game.currentBarPorcent -= 0.0050 * game.amountOfIntense;
        if (ClientPrefs.data.diffTBS != 'Baby') bbd.alpha += (ClientPrefs.data.diffTBS == 'Hard' ? 0.0080 : 0.0050) * game.amountOfIntense;
        }
        else {
        game.currentBarPorcent -= 0.0050;
        if (ClientPrefs.data.diffTBS != 'Baby') bbd.alpha += (ClientPrefs.data.diffTBS == 'Hard' ? 0.0080 : 0.0050);
        }
    }
}

function goodNoteHit(note:Note) {
    if (game.currentBarPorcent <= 1) {
    if (game.amountOfIntense > 0)  {
    game.currentBarPorcent += 0.0050 * game.amountOfIntense;
    if (ClientPrefs.data.diffTBS != 'Baby') bbd.alpha -= (ClientPrefs.data.diffTBS == 'Hard' ? 0.0080 : 0.0050) * game.amountOfIntense;
    }
    else {
    game.currentBarPorcent += 0.0050;
    if (ClientPrefs.data.diffTBS != 'Baby') bbd.alpha -= (ClientPrefs.data.diffTBS == 'Hard' ? 0.0080 : 0.0050);
    }
    }
}

function onGameOver()
{
    if (game.currentBarPorcent == 0 || despairBar.percent == 0) Achievements.unlock('despair');
}    

function onSongStart() {
    for(i in 0...game.playerStrums.members.length) {
        if (ClientPrefs.data.downScroll) {
        game.playerStrums.members[i].y += 72;
        }
        else {
        game.playerStrums.members[i].y -= 72;
        }
    }

    for (i in game.opponentStrums.members) {
        i.downScroll = false;
        i.x += 540;
        i.y -= (ClientPrefs.data.downScroll ? 550 : 0);
        i.scrollFactor.set(1,1);
        i.camera = game.camGame;
        game.remove(i, true); //game.insert(0, i);
    }
    for (i in 0...2) {
        game.playerStrums.members[i].x = 265 + i * 112;
    }
    for (i in 2...4) {
        game.playerStrums.members[i].x -= (ClientPrefs.data.middleScroll ? -150 : 90);
    }
}

function onStepHit() {
    if (game.health > 0.2 && canDo && ClientPrefs.data.diffTBS != 'Baby') {
    game.health -= 0.0027 * game.amountOfIntense;
    }
    switch(curStep)
    {
    case 640:
        canDo = false;
        FlxTween.tween(game.camHUD, {alpha: 0}, 0.5);
        FlxTween.tween(blackJumpscare, {alpha: 0.5}, 0.5);

        if (ClientPrefs.data.subsBool) {
        sbTxt = new FlxTypeText(0, 0, FlxG.width, "It's Better To Meet Them In Another World Than Spend Your Rest Of Your Life In Despair.", 20);
        sbTxt.setFormat(Paths.font('vcr.ttf'), 19, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        sbTxt.alpha = 0;
        FlxTween.tween(sbTxt, {alpha: 1}, 0.25);
        sbTxt.camera = game.camOther;
        sbTxt.borderSize = 1.5;
        sbTxt.screenCenter();
        sbTxt.y += FlxG.height / 2.23;
        add(sbTxt);
    
        sbTxt.start(0.065, false, false, [], function()
            {
                new FlxTimer().start(0.8, function(timer:FlxTimer)
                {
                FlxTween.tween(sbTxt, {alpha: 0}, 0.25, {ease: FlxEase.expoOut, onComplete: function(tween:FlxTween)
                    {
                        sbTxt.destroy();
                    }});
                    });
                });
            }
    case 714:
        if (ClientPrefs.data.subsBool) {
        sbTxt2 = new FlxTypeText(0, 0, FlxG.width, "COME ON SPIKE! Make Your Choice!\nI'm The Disaster Itself!", 20);
        sbTxt2.setFormat(Paths.font('vcr.ttf'), 19, FlxColor.RED, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        sbTxt2.camera = game.camOther;
        sbTxt2.borderSize = 1.5;
        sbTxt2.alpha = 0;
        FlxTween.tween(sbTxt2, {alpha: 1}, 0.25);
        sbTxt2.screenCenter();
        sbTxt2.y += FlxG.height / 2.23;
        add(sbTxt2);
    
        sbTxt2.start(0.08, false, false, [], function()
            {
                new FlxTimer().start(0.8, function(timer:FlxTimer)
                {
                FlxTween.tween(sbTxt2.scale, {x: 0, y: 0}, 0.6, {onComplete: function(tween:FlxTween)
                    {
                        sbTxt2.destroy();
                    }});
                    });
                });
            }
    case 759:
        canDo = true;
        FlxTween.tween(game.camHUD, {alpha: 1}, 0.5);
    case 896:
        FlxTween.tween(blackJumpscare, {alpha: 0}, 0.25);
    case 1408:
        FamishedBG.bfZoom = 1.3;
        game.boyfriend.cameraPosition[1] += 20;
        FlxTween.tween(blackJumpscare, {alpha: 0.4}, 0.75);
    case 1632:
        FamishedBG.bfZoom = 0.6;
        FamishedBG.dadZoom = 0.6;
        game.boyfriend.cameraPosition[1] -= 20;
        FlxTween.tween(blackJumpscare, {alpha: 0.5}, 0.15);
    case 1984:
        FamishedBG.bfZoom = 1;
        FamishedBG.dadZoom = 0.9;
        FlxTween.tween(game, {currentBarPorcent: 1}, 0.5);
        FlxTween.tween(bbd, {alpha: 0}, 0.5);
        FlxTween.tween(blackJumpscare, {alpha: 0}, 0.5, {ease: FlxEase.circInOut});
    case 2256:
        FlxTween.tween(game.camHUD, {alpha: 0}, 0.5);
    }
}

function onEndSong() {
    if (game.songMisses == 0 && ClientPrefs.data.diffTBS == 'Hard')
    Achievements.unlock('dod_nomiss');
}