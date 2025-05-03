package states.stages;

import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxBackdrop;

// shaders to use
import shaders.tbs.NTSC;
import shaders.tbs.NTSCother;
import shaders.tbs.GlitchShake;
import shaders.tbs.ChromaticGlitch;
import shaders.tbs.Saturation;
import shaders.Distortion;

import flixel.math.FlxMath;

class FamishedBG extends BaseStage
{
    var bgGroup:FlxTypedGroup<BGSprite>;
	var controledAlpha:Float = 1;

    public static var bfZoom:Float = 1;
    public static var dadZoom:Float = 0.9;

    var localShader:NTSC;
    var localShader2:NTSCother;
    var localShader3:ChromaticGlitch;
    var localShader4:GlitchShake;
    var localShader5:Saturation;
    var localShader6:Distortion = new Distortion();

    override function create()
    {
        bgGroup = new FlxTypedGroup<BGSprite>();
        add(bgGroup);

        var shitArray:Array<Dynamic> = [
            ['sky', -700, -110,0.8],
            ['alley light', -700, -110,0.9]];
        for (i in 0...2)
        {
            var sprite:BGSprite = new BGSprite('game/stages/alley/' + shitArray[i][0], shitArray[i][1], shitArray[i][2], shitArray[i][3], shitArray[i][3]);
            sprite.ID= i;
            if(i > 2)
            sprite.scale.set(0.9, 0.9);
            add(sprite);
            bgGroup.add(sprite);
        }

        var gray2 = new FlxBackdrop(Paths.image('game/stages/alley/weekend1shit/greyGradient'), X, 0, 0);
		gray2.y = -110;
        gray2.blend = ADD;
        gray2.alpha = 0.6;
        gray2.scale.set(1.1, 1.1);
        gray2.color = 0xFFB0B0B0;
		gray2.velocity.x = 28;
        add(gray2);
    
        var spriter:BGSprite = new BGSprite('game/stages/alley/alley BG',  -700, -110, 1, 1);
        spriter.scale.set(0.9, 0.9);
        add(spriter);
        bgGroup.add(spriter);

            localShader = new NTSC();
            localShader2 = new NTSCother();
            localShader3 = new ChromaticGlitch();
            localShader4 = new GlitchShake();
            localShader5 = new Saturation();

            localShader4.iMouseX.value = [630];
            localShader4.NUM_SAMPLES.value = [7];

            localShader5.sat.value = [0.5];
            
            localShader6.glitchModifier.value = [0.5];
            localShader6.moveScreenFullX.value = [true];
            localShader6.moveScreenX.value = [true];
            localShader6.moveScreenFullY.value = [true];
            localShader6.fullglitch.value = [0.3];
            localShader6.working.value = [true];
            localShader6.timeMulti.value = [1];
            localShader6.effectMulti.value = [0.005];
            localShader6.iResolution.value = [FlxG.width, FlxG.height];

            if (ClientPrefs.data.shaders)  game.camGame.setFilters([new ShaderFilter(localShader2),new ShaderFilter(localShader6),new ShaderFilter(localShader5)]);
            if (ClientPrefs.data.shaders) game.camHUD.setFilters([new ShaderFilter(localShader2),new ShaderFilter(localShader5)]);
            if (ClientPrefs.data.ishaders && ClientPrefs.data.shaders) {
            FlxG.game.setFilters([new ShaderFilter(localShader3),new ShaderFilter(localShader)]);
            }
            else if (ClientPrefs.data.shaders) {
            FlxG.game.setFilters([new ShaderFilter(localShader3)]);
            }
            var bd:BGSprite = new BGSprite('border', 0,0, 0, 0);
            bd.cameras = [game.camOther];
            add(bd);
    }

    override function createPost() {
        for(i in 0...game.opponentStrums.members.length) {
            if (ClientPrefs.data.downScroll) {
            game.opponentStrums.members[i].y += 72;
            }
            else {
            game.opponentStrums.members[i].y -= 72;
            }
        }
        for(i in 0...game.playerStrums.members.length) {
            if (ClientPrefs.data.downScroll) {
            game.playerStrums.members[i].y += 62;
            }
            else {
            game.playerStrums.members[i].y -= 62;
            }
        }
    
        game.camHUD.zoom = game.defaultHUDZoom = 0.8;
    
        var idots:Array<FlxSprite> = [game.timeTxt, game.timeBar, game.timeBar.bg];
    
        if (ClientPrefs.data.downScroll) {
        game.timeTxt.y += 43;
        }
        else {
        game.timeTxt.y -= 43;
        }
        for(i in idots) {
            if (ClientPrefs.data.downScroll) {
            i.y += 43;
            }
            else {
            i.y -= 43;
            }
        }
    
        var hudpoop:Array<FlxSprite> = [game.scoreTxt, game.iconP1, game.iconP2, game.healthBar, game.healthBar.bg, game.botplayTxt];
    
        if (ClientPrefs.data.downScroll) {
        game.iconP1.y -= 33; game.iconP2.y -= 33; game.scoreTxt.y -= 33;
        }
        else {
        game.iconP1.y += 43; game.iconP2.y += 43; game.scoreTxt.y += 43;
        }
        for(i in hudpoop) {
            if (ClientPrefs.data.downScroll) {
            i.y -= 33;
            }
            else {
            i.y += 43;
            }
        }

        var gray1 = new FlxBackdrop(Paths.image('game/stages/alley/weekend1shit/greyGradientB'), X, 0, 0);
		gray1.y = 260;
		gray1.scrollFactor.set(1, 0.5);
        gray1.blend = ADD;
		gray1.velocity.x = 18;
        add(gray1);
    }

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
    {
        if (ClientPrefs.data.shaders) {
        if (eventName == "Event Trigger") {
            if (value1 == 'rumble') {
                if (value2 == 'true') {
                    game.camGame.setFilters([new ShaderFilter(localShader2),new ShaderFilter(localShader6),new ShaderFilter(localShader4),new ShaderFilter(localShader5)]);
                    game.camHUD.setFilters([new ShaderFilter(localShader2),new ShaderFilter(localShader4),new ShaderFilter(localShader5)]);
                }
                else {
                    game.camGame.setFilters([new ShaderFilter(localShader2),new ShaderFilter(localShader6),new ShaderFilter(localShader5)]);
                    game.camHUD.setFilters([new ShaderFilter(localShader2),new ShaderFilter(localShader5)]);
                }
            }
        }
    }
    }

	override function destroy()
        {
            FlxG.game.setFilters([]);
        }
    var totalTime:Float = 0;
	override function update(elapsed:Float)
        {
            if (ClientPrefs.data.shaders) {
                totalTime += elapsed;
                localShader2.iTime.value = [totalTime];
                localShader6.iTime.value = [totalTime];
                localShader4.iTime.value = [totalTime];
                localShader4.glitchMultiply.value = [FlxG.random.float(0.2, 0.3)];

                localShader3.rOffset.value = [0.002 * -1 * game.amountOfIntense];
                localShader3.bOffset.value = [0.002 * game.amountOfIntense];
                }
            game.boyfriend.alpha = controledAlpha;
            if (PlayState.SONG.notes[game.curSection] != null ? (PlayState.SONG.notes[game.curSection].mustHitSection == true) : false) {
            game.defaultCamZoom = bfZoom;
            controledAlpha = 1;
            }
            else {
            controledAlpha = 0.4;
            game.defaultCamZoom = dadZoom;
            }
        }
}