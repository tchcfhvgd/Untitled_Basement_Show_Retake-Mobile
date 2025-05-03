package states.stages;

import openfl.filters.ShaderFilter;
import shaders.tbs.CharShadow;
import shaders.tbs.Monitor;
import shaders.tbs.ChromWarp;

import flixel.math.FlxMath;
import openfl.display.BlendMode;
import psychlua.LuaUtils;
import objects.Character;
import cutscenes.CutsceneHandler;

class Basement extends BaseStage
{
    public static var charShader:CharShadow;
    var monitor:Monitor;
    public static var bg:BGSprite;
    public static var blackScreen:FlxSprite;
    public static var spotlight:BGSprite;
    public static var aSpotlight:BGSprite;
    public static var fire:FlxSprite;
    public static var redScreen:FlxSprite;
    public static var chromatic:ChromWarp = new ChromWarp();
    public static var intense:Float = 0;

	override function create()
	{
        intense = 0;
        if (PlayState.SONG.song == 'Sirokou') {
        fire = new FlxSprite(70, 50);
        fire.frames = Paths.getSparrowAtlas('game/stages/basement/fire');
        fire.animation.addByPrefix('fire', 'fire', 24, true);
        fire.animation.play('fire');
        fire.scale.set(6,3);
        //game.insert(members.indexOf(Basement.bg),fire);
    
        redScreen = new FlxSprite(-540, -400).makeGraphic(FlxG.width + 1100, FlxG.height + 1100, FlxColor.RED);
        redScreen.alpha = 0.45;
        redScreen.scrollFactor.set();
        redScreen.blend = LuaUtils.blendModeFromString('overlay');
        //game.insert(members.indexOf(Basement.bg),redScreen);
        }

		bg = new BGSprite('game/stages/basement/basement', -600, -200, 1, 1);
        bg.color = 0xFFABABAB;
		add(bg);

        if(ClientPrefs.data.shaders)
        {
            monitor = new Monitor();
            chromatic.distortion.value = [0];

            if(PlayState.SONG.song != 'Sirokou') game.camGame.setFilters([new ShaderFilter(monitor)]);
        }

        charShader = new CharShadow();
        charShader._alpha.value = [0.7];
        charShader._disx.value = [0];
        charShader._disy.value = [34];
        charShader.inner.value = [true];
        charShader.inverted.value = [true];

        if(PlayState.SONG.song == 'House-for-Sale' && !seenCutscene && isStoryMode) setStartCallback(videoCutscene.bind('W1'));
        if(PlayState.SONG.song == 'Sirokou' && !seenCutscene && isStoryMode) setStartCallback(videoCutscene.bind('Sirokou'));

		if (isStoryMode)
            {
                switch(PlayState.SONG.song)
                {
                    case 'Sirokou':
                        setEndCallback(function()
                        {
                            game.endingSong = true;
                            inCutscene = true;
                            canPause = false;
                            FlxTransitionableState.skipNextTransIn = true;
                            FlxG.camera.visible = false;
                            camHUD.visible = false;
                            game.startVideo('W1 End', false, true);
                        });
                }
            }
	}

    public function changeBG(thing:String) {
        bg.loadGraphic(Paths.image('game/stages/basement/' + thing));
    }

    override function createPost() {
	blackScreen = new FlxSprite(-240, -200).makeGraphic(FlxG.width + 700, FlxG.height + 700, FlxColor.BLACK);
    blackScreen.alpha = 0.45;
    blackScreen.scrollFactor.set();
	add(blackScreen);

    spotlight = new BGSprite('game/stages/basement/spotlight', -40, -80, 1, 1);
    if (PlayState.SONG.song == 'Sirokou') {
        spotlight.alpha = 0;
    }
    else {
        spotlight.alpha = 0.3;
    }
    spotlight.blend = SCREEN;
	if (!ClientPrefs.data.lowQuality) add(spotlight);

    aSpotlight = new BGSprite('game/stages/basement/Aspotlight', -30, -260, 1, 1);
    aSpotlight.blend = ADD;
    aSpotlight.color = 0xFFFFFC44;
    aSpotlight.alpha = 0.4;
    aSpotlight.visible = false;
    game.add(aSpotlight);

    game.gf.shader = charShader;
    if (PlayState.SONG.song != 'Sirokou') {
    game.boyfriend.shader = game.dad.shader = charShader;
    }
    }

    public static var chromValue:Float = 0;
	override function update(elapsed:Float)
    {
    chromatic.distortion.value = [chromValue];
    chromValue = FlxMath.lerp(chromValue, 0, 0.08);
    if (!ClientPrefs.data.lowQuality && spotlight.visible == true) spotlight.angle =  Math.sin((Conductor.songPosition / 3000) * (Conductor.bpm / 80) * 3.0) * 19; // notbeep made this code.
    }

    override function beatHit() {
        chromValue = intense;
    }

	override function stepHit()
        {
            if (PlayState.SONG.song == 'Sirokou') {
                switch(curStep)
                {
                case 512:
                    spotlight.alpha = 0.3;
                    game.boyfriend.shader = game.dad.shader = charShader;
                }
            }
        }

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
        {
            switch(eventName)
            {
                case "Camera Modulo Change":
                    if (value1 == '1') {
                    if(ClientPrefs.data.shaders) FlxG.game.setFilters([new ShaderFilter(chromatic)]);
                    intense = 0.4 * flValue2;
                    }
                    else {
                    if(ClientPrefs.data.shaders) FlxG.game.setFilters([]);
                    intense = 0;
                    }
                case "Change Character":
                game.dad.shader = null;
                case "Event Trigger":
                    if (value1 == 'changeBG') changeBG(value2);
                    switch(value2)
                    {
                        case 'basementdark':
                        game.scaredGF = true;
                        if (game.scaredGF == false) game.gf.playAnim('sad');
                        game.gf.specialAnim = false;
                        spotlight.color = 0xFFFFAAAA;
                        case 'basementred': 
                        game.scaredGF = false;
                        game.gf.playAnim('scared', true);
                        game.gf.specialAnim = true;
                        spotlight.color = 0xFFFF0000;
                        case 'basement':
                        game.scaredGF = true;
                        if (game.scaredGF == false) game.gf.playAnim('sad');
                        game.gf.specialAnim = false;
                        spotlight.color = 0xFFFFFFFF;
                    }
            }
        }

        var videoEnded:Bool = false;
        function videoCutscene(?videoName:String = null)
        {
            game.inCutscene = true;
            if (game.videoCutscene != null) {
                game.videoCutscene.set_canSkip(true);
            }
            if(!videoEnded && videoName != null)
            {
                game.startVideo(videoName, false, true);
                game.videoCutscene.finishCallback = game.videoCutscene.onSkip = function()
                {
                    videoEnded = true;
                    game.videoCutscene = null;
                    game.inCutscene = false;
                    startCountdown();
                };
                return;
            }
        }

        override function destroy()
            {
                FlxG.game.setFilters([]);
            }
}