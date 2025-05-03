import objects.Bar;
import objects.Character;

var theTime:Float = 0;
var missedDodges:Int = 0;

var dodgeButton:FlxSprite;
var dodgeBar:Bar;
var altBF:Character;
var altDad:Character;

var dodgingTime:Float = 0.7;

var _onCoolDown:Bool = false;
var dodging:Bool = false;
var doingDodge:Bool = false;

function createPopup() {
    var dPop:FlxSprite = new FlxSprite().loadGraphic(Paths.image('game/ratings/default/dodge'));
    dPop.screenCenter();
    dPop.x = FlxG.width * 0.35 - 40;
    dPop.y -= 60;
    if (!ClientPrefs.data.simpleRatings) {
    dPop.acceleration.y = 550 * playbackRate * playbackRate;
    dPop.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
    dPop.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
    }
    dPop.x += game.comboOffset_X + 100;
    dPop.y += game.comboOffset_Y;
    game.insert(13,dPop);
    dPop.scale.set(0.7,0.7);
//dPop.setGraphicSize(Std.int(rating.width * 0.3));

	dPop.updateHitbox();
    FlxTween.tween(dPop, {alpha: 0}, 0.2 / playbackRate, {
        startDelay: Conductor.crochet * 0.001 / playbackRate,
        onComplete: function(tween:FlxTween)
		{
			dPop.destroy();
		},
    });
}

function checkDodge()
    {
        if (game.dad.curCharacter == 'mouse angry 2' || game.dad.curCharacter == 'mouse 3') {
        altDad.playAnim('attack', true);
        altDad.visible = true;
        game.dad.visible = false;
        altDad.animation.finishCallback = function(name:String)
        {
            if (name == 'attack') {
            altDad.visible = false;
            game.dad.visible = true;
            }
        }
    }
        if (dodging || game.cpuControlled)
        {
            FlxG.sound.play(Paths.sound('dodged'));
            altBF.playAnim('dodge', true);
            altBF.visible = true;
            game.boyfriend.visible = false;
            altBF.animation.finishCallback = function(name:String)
            {
                if (name == 'dodge') {
                altBF.visible = false;
                game.boyfriend.visible = true;
                }
            }
            if (!cpuControlled) createPopup();
            //game.dad.playAnim('fuck you', true);
            dodgeBar.leftBar.color = 0xFF00FF00;
            dodgeBar.updateBar();
        }
        else if (!dodging || !game.cpuControlled)
        {
            FlxG.sound.play(Paths.sound('dead'));
            dodgeBar.leftBar.color = FlxColor.RED;
            dodgeBar.updateBar();
            missedDodges += 1;
            game.health -= ClientPrefs.data.diffTBS == 'Hard' ? 2 : 0.98;
            altBF.playAnim('singDOWNmiss', true);
            game.boyfriend.visible = false;
            altBF.visible = true;
            altBF.animation.finishCallback = function(name:String)
            {
                if (name == 'singDOWNmiss') {
                altBF.visible = false;
                game.boyfriend.visible = true;
                }
            }
        }
    
        _onCoolDown = false;
        doingDodge = false;
}
    

function onCreatePost() {
    if (ClientPrefs.data.diffTBS == 'Baby') Function_StopHScript;
    game.camZooming = true;

    dodgeButton = new FlxSprite(260, 130);
    dodgeButton.frames = Paths.getSparrowAtlas('game/dodging/dodge_jerry');
    dodgeButton.screenCenter();
    dodgeButton.y -= 50;
    dodgeButton.alpha = 0;
    //dodgeButton.setGraphicSize(Std.int(dodgeButton.width / 2));
    dodgeButton.cameras = [camOther];
    dodgeButton.animation.addByPrefix('alert', 'spacebar', 12, true);
    dodgeButton.animation.play('alert', true);
    add(dodgeButton);

    dodgeBar = new Bar(200, 0, 'game/timeBar',  function() return theTime, 0, 1);
    dodgeBar.screenCenter();
    dodgeBar.y += 160;
    dodgeBar.scale.x = 0;
    dodgeBar.visible = !ClientPrefs.data.hideHud;
    dodgeBar.camera = game.camOther;
    dodgeBar.updateBar();
    add(dodgeBar);

    altBF = new Character(game.boyfriend.x,game.boyfriend.y, game.boyfriend.curCharacter, true);
    altBF.visible = false;
    altBF.shader = game.boyfriend.shader;
    game.insert(members.indexOf(game.boyfriend) + 12,altBF);

    altDad = new Character(game.dad.x,game.dad.y, 'mouse 3', false);
    altDad.visible = false;
    altDad.shader = game.dad.shader;
    game.insert(members.indexOf(game.boyfriend) + 12,altDad);
}

function onUpdatePost(elapsed) {
    if (!cpuControlled) {game.judTxt.text = game.judTxt.text + '\nMissed Dodges: ' + missedDodges;}
    
    if (FlxG.keys.justPressed.SPACE
        && !_onCoolDown
        && !dodging
        //&& !game.cpuControlled
        && !paused)
    {
        _onCoolDown = true;
        dodging = true;
        new FlxTimer().start(0.25, function(timer:FlxTimer)
        {
            _onCoolDown = false;
        });
        new FlxTimer().start(0.3, function(timer:FlxTimer)
        {
            dodging = false;
        });
    }
}

function onStepHit() {
    if (curStep == 2642 || curStep == 514) {
        altBF.shader = altDad.shader = game.dad.shader;
    }
}
function onEvent(name:String, v1:String, v2:String) {
    if (name == 'Change Character') {
        altDad.x = game.dad.x;
        altDad.y = game.dad.y;
        altDad.curCharacter = game.dad.curCharacter;
    }
    if (name == 'Event Trigger') {
        if (v1 == 'dodge' && ClientPrefs.data.diffTBS != 'Baby') {
            if (game.dad.curCharacter == 'mouse 3') altDad.playAnim('hey', true);
            altDad.visible = true;
            game.dad.visible = false;
            FlxG.sound.play(Paths.sound('DODGE'));
            dodgeBar.leftBar.color = FlxColor.WHITE;
            dodgeBar.updateBar();
            FlxTween.tween(dodgeButton, {alpha: 1}, 0.5, {ease: FlxEase.expoInOut});
            FlxTween.num(theTime, 1, dodgingTime - 0.13, {ease: FlxEase.quadInOut}, function(num) {theTime = num;});
            FlxTween.tween(dodgeBar.scale, {x: 1.3}, 0.5, {ease: FlxEase.expoInOut});
            dodgeBar.alpha = 1;
            
            new FlxTimer().start(dodgingTime, function(timer:FlxTimer)
            {
            FlxG.camera.shake(0.01, 0.2);
            checkDodge();
            FlxTween.tween(dodgeButton, {alpha: 0}, 0.5, {ease: FlxEase.expoInOut});
           // FlxTween.num(theTime, 0, 0.5, {ease: FlxEase.linear}, function(num) {theTime = num;});
            //FlxTween.tween(dodgeBar.scale, {x: 0}, 0.5, {ease: FlxEase.expoInOut});
            FlxTween.tween(dodgeBar, {alpha: 0}, .5, {
                onComplete: function(tween:FlxTween)
                {
                    theTime = 0;
                    dodgeBar.scale.x = 0;
                },
            });
            FlxTween.tween(dodgeBar, {alpha: 0}, 0.5, {ease: FlxEase.expoInOut});
            });
        }
    }
}

function onEndSong() {
    if (missedDodges == 0)
    Achievements.unlock('zerodg');
}