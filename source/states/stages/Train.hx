package states.stages;

import openfl.filters.ShaderFilter;
import shaders.tbs.Monitor;
import shaders.RainShader;
import flixel.math.FlxMath;
import openfl.display.BlendMode;
import cutscenes.CutsceneHandler;

import shaders.tbs.VignetteThing;
import shaders.tbs.LowerQuality;
import shaders.tbs.OldFilm;
import shaders.tbs.Noice;
import shaders.tbs.NTSC;

class Train extends BaseStage
{
	var rainShader:RainShader;
    var rainShaderStartIntensity:Float = 0;
	var rainShaderEndIntensity:Float = 0;
    var monitor:Monitor;
    var blackScreen:FlxSprite;
    public var memorybg:BGSprite;
    public var memories:BGSprite;

    var shader2:VignetteThing = new VignetteThing();
    var shader3:LowerQuality = new LowerQuality();
    var shader1:OldFilm = new OldFilm();
    var shader4:Noice = new Noice();
    var shader5:NTSC = new NTSC();

	override function create()
	{
		var bg:BGSprite = new BGSprite('game/stages/train/blue2', -500, -10, 1, 1);
		add(bg);

		rainShader = new RainShader();
		rainShader.scale = FlxG.height / 200;
        rainShaderStartIntensity = 0.1;
        rainShaderEndIntensity = 0.4;
        rainShader.intensity = rainShaderStartIntensity;
        game.camGame.setFilters([new ShaderFilter(rainShader)]);

        if(ClientPrefs.data.shaders)
        {
            monitor = new Monitor();
            game.camGame.pushFilter('monitor', new ShaderFilter(monitor));

            shader2 = new VignetteThing();
            shader3 = new LowerQuality();
            shader1 = new OldFilm();
            shader4 = new Noice();

            shader1.sat.value = [0.5];
            shader3.blur.value = [1];
            shader4.intenseNess.value = [1.3];
            shader4.colorOffsets.value = [0.1];
        }

        memorybg = new BGSprite('game/stages/train/memories/memorybg', 0, 0, 0, 0);
        memorybg.cameras = [game.camBars];
        memorybg.alpha = 0;
        add(memorybg);

        memories = new BGSprite('game/stages/train/memories/memory1', 0, 0, 0, 0);
        memories.cameras = [game.camBars];
        memories.alpha = 0;
        add(memories);

        if(PlayState.SONG.song == 'Blue' && !seenCutscene && isStoryMode) setStartCallback(videoCutscene.bind('W2'));
	}

    override function createPost() {
		var fg:BGSprite = new BGSprite('game/stages/train/bluefg', -500, -10, 1, 1);
		add(fg);

        blackScreen = new FlxSprite(-280, -200).makeGraphic(FlxG.width + 1000, FlxG.height + 700, 0xFFFFD9B3);
        blackScreen.alpha = 0.45;
        blackScreen.blend = SUBTRACT;
        blackScreen.scrollFactor.set();
        add(blackScreen);
    }

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
        {
            if (eventName == "Event Trigger") {
                if (value1 == "MemoryFlash") {
                memories.alpha = 1;
                FlxTween.tween(memories, {alpha: 0}, 0.5);
                memories.loadGraphic(Paths.image('game/stages/train/memories/memory' + value2));
                }
                if (value1 == "Start") {
                    if (value2 == "true") {
                        memoryTime(true);
                    }
                    else {
                        memoryTime(false);
                    }
                }
        }
        }

    public function memoryTime(on:Bool) {
        if (on) {
        memorybg.alpha = 1;
        if(ClientPrefs.data.shaders) {
        game.camBars.setFilters([new ShaderFilter(shader1), new ShaderFilter(shader4)]);
        game.camHUD.setFilters([new ShaderFilter(shader1), new ShaderFilter(shader4)]);
        }
        if (ClientPrefs.data.ishaders && ClientPrefs.data.shaders) FlxG.game.setFilters([new ShaderFilter(shader2),new ShaderFilter(shader5)]);
        if (ClientPrefs.data.shaders) FlxG.game.setFilters([new ShaderFilter(shader2)]);
        }
        else {
        memorybg.alpha = 0;
        game.camBars.setFilters([]);
        game.camHUD.setFilters([]);
        FlxG.game.setFilters([]);
        }
    }

	override function destroy()
        {
            FlxG.game.setFilters([]);
        }

    var tottalTime:Float = 0;
    override function update(elapsed:Float) {
        var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, (FlxG.sound.music != null ? FlxG.sound.music.length : 0), rainShaderStartIntensity, rainShaderEndIntensity);
        rainShader.intensity = remappedIntensityValue;
        rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
        rainShader.update(elapsed);

    if (ClientPrefs.data.shaders) {
        tottalTime += elapsed;
        shader1.iTime.value = [tottalTime];
        shader4.iTime.value = [tottalTime];
        shader1.brightness.value = [FlxG.random.float(2, 3)];
    }
    }

    var videoEnded:Bool = false;
    function videoCutscene(?videoName:String = null)
    {
        game.inCutscene = true;
        if(!videoEnded && videoName != null)
        {
            game.startVideo(videoName);
            game.videoCutscene.finishCallback = game.videoCutscene.onSkip = function()
            {
                videoEnded = true;
                game.videoCutscene = null;
                game.inCutscene = false;

                camHUD.alpha = 1;
                startCountdown();
            };
            return;
        }
    }
}