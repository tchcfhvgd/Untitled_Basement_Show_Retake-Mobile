package states.stages;

import openfl.filters.ShaderFilter;
import shaders.tbs.NormalWarp;
import flixel.math.FlxMath;
import openfl.display.BlendMode;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.effects.FlxTrail;
import flixel.math.FlxMath;

import shaders.tbs.JPG;
import shaders.GlowShader;

class Meme extends BaseStage
{
    public static var bgGroup:FlxTypedGroup<BGSprite>;
    public static var bg:BGSprite;
    public static var mbg:BGSprite;
    public static var chee:BGSprite;
    public static var watchers:BGSprite;
    public static var memeOld:FlxBackdrop;

    public static var memeShader:NormalWarp = new NormalWarp();
    public static var memeShader2:GlowShader = new GlowShader();

    public static var memeShader1:JPG = new JPG();
    public static var memeTrail:FlxTrail;

	override function create()
	{
        bgGroup = new FlxTypedGroup<BGSprite>();
        add(bgGroup);

		bg = new BGSprite('game/stages/meme/meme new', -400, -580, 1, 1);
        bg.scale.set(1.1,1.1);
		bgGroup.add(bg);

        mbg = new BGSprite('game/stages/meme/mfm', -360, -580, 1, 1);
        mbg.scale.set(1.1,1.1);
        mbg.visible = false;
        bgGroup.add(mbg);

        memeShader.distortion.value = [3.0];

        memeShader2.size.value = [0];
        memeShader2.dim.value = [2.2];

        memeOld = new FlxBackdrop(Paths.image('game/stages/meme/MEME BG'));
		memeOld.velocity.set(260,260);
        memeOld.alpha = 0;
        memeOld.scrollFactor.set(0,0);
        add(memeOld);

        memeShader1.pixel_size.value = [2.0];

        if (ClientPrefs.data.shaders) FlxG.game.setFilters([new ShaderFilter(memeShader1)]);
        if (ClientPrefs.data.ishaders && ClientPrefs.data.shaders) game.camGame.setFilters([new ShaderFilter(memeShader2)]);
    }

	override function destroy()
    {
        FlxG.game.setFilters([]);
    }

    override function createPost() {
        chee = new BGSprite('game/stages/meme/cheese', -400, -580, 0.85, 0.85);
        chee.scale.set(1.1,1.1);
		add(chee);

        watchers = new BGSprite('game/stages/meme/watcher', 200, 450,  ['watcher','watcher'], false);
        watchers.scale.set(2,2);
		add(watchers);

        var bd:BGSprite = new BGSprite('border', 0,0, 0, 0);
        bd.cameras = [game.camOther];
        add(bd);

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

        memeTrail = new FlxTrail(game.dad, null, 4, 5, 0.3, 0.069);
        memeTrail.color = 0xFFFB00FF;
    
        game.judTxt.x -= 35;
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

        game.healthBar.bg.loadGraphic(Paths.image('game/stages/meme/funnyHP'));
        game.healthBar.regenerateClips();
        game.healthBar.bg.setPosition(game.healthBar.bg.x - 48, game.healthBar.bg.y - 10);
        game.healthBar.leftBar.scale.set(1.24,0.4); game.healthBar.rightBar.scale.set(1.24,0.4);
        game.healthBar.leftBar.offset.y = game.healthBar.rightBar.offset.y = -30;
    }

    public static var funniNumber:Float = 2;
    public static var funniNumber2:Float = 2;

	override function update(elapsed:Float) 
    {
    if(ClientPrefs.data.ishaders && ClientPrefs.data.shaders) {
        memeShader2.size.value = [funniNumber];
        memeShader2.dim.value = [funniNumber2];
    }
    }

	override function beatHit()
    {
    watchers.animation.play('watcher');
    }

    override function stepHit()
    {
        if (ClientPrefs.data.leTrail) {
        switch(curStep)
        {
            case 1104:
            game.camHUD.flash(0xFFFB00FF, 0.5, null, false);
            watchers.visible = chee.visible = false;
            mbg.visible = true;
            memeTrail = new FlxTrail(game.dad, null, 4, 5, 0.2, 0.069);
            memeTrail.color = 0xFFFB00FF;
            game.addBehindDad(memeTrail);
            case 1232: memeTrail.destroy(); mbg.destroy();
            watchers.visible = chee.visible = true;
        }
    }
    }

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
    {
        if (eventName == "Low Light") {
            if (ClientPrefs.data.ishaders && ClientPrefs.data.shaders) {
            funniNumber = 40;
            funniNumber2 = 1.1;
                
            FlxTween.num(funniNumber, 2, 1, {ease: FlxEase.expoOut}, function(num) {funniNumber = num;});
            FlxTween.num(funniNumber2, 2, 1, {ease: FlxEase.expoOut}, function(num) {funniNumber2 = num;});
            }
            else {
                game.camGame.flash(0x63FFFFFF, 0.5, null, false);
            }
        }
    }
}