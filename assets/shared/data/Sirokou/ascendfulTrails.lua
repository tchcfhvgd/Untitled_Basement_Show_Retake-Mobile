function onUpdate()
	if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT' then
		createShadow(true, 'bf',false,0,300)
    end
        if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT' then
		createShadow(true, 'bf',false,0,-300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'singUP' then
		createShadow(true, 'bf',false,300,0)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN' then
		createShadow(true, 'bf',false,300,0)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'singLEFT-alt' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHT-alt' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'singUP-alt' then
		createShadow(true, 'bf',false,300,300)
	    end
        if getProperty('boyfriend.animation.curAnim.name') == 'singDOWN-alt' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'idle-alt' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'idle' then
	    createShadow(true, 'bf',false,300,0)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'danceLeft' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'danceRight' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'singLEFTmiss' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'singDOWNmiss' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'singUPmiss' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'singRIGHTmiss' then
		createShadow(true, 'bf',false,300,300)
        end
        if getProperty('boyfriend.animation.curAnim.name') == 'dodge' then
		createShadow(true, 'bf',false,300,300)
        end
		
        if getProperty('dad.animation.curAnim.name') == 'singLEFT' then
		createShadow(false, dad,false,0,300)
        end
        if getProperty('dad.animation.curAnim.name') == 'singRIGHT' then
		createShadow(false, dad,false,0,-300)
        end
        if getProperty('dad.animation.curAnim.name') == 'singUP' then
		createShadow(false, dad,false,300,0)
        end
        if getProperty('dad.animation.curAnim.name') == 'singDOWN' then
		createShadow(false, dad,false,300,0)
        end
        if getProperty('dad.animation.curAnim.name') == 'singLEFT-alt' then
		createShadow(false, dad,false,300,300)
        end
        if getProperty('dad.animation.curAnim.name') == 'singRIGHT-alt' then
		createShadow(false, dad,false,300,300)
        end
        if getProperty('dad.animation.curAnim.name') == 'singUP-alt' then
		createShadow(false, dad,false,300,300)
        end
        if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' then
     	createShadow(false, dad,false,300,300)
        end
        if getProperty('dad.animation.curAnim.name') == 'idle-alt' then
		createShadow(false, dad,false,300,300)
        end
        if getProperty('dad.animation.curAnim.name') == 'idle' then
		createShadow(false, dad,false,300,0)
		end
end

local shadowTag = 'shadow'
local shadowCount = 0
local shadowAlpha = 0
function createShadow(isBF, char, strong,xOff,yOff)
	char = getCharacter(char)
	
	if (shadowCount > 999) then shadowCount = 0 end
	local tag = shadowTag .. char .. shadowCount
	
	local props = getProperties(char, {
		image = 'imageFile',
		frame = 'animation.frameName',
		x = 'x',
		y = 'y',
		scaleX = 'scale.x',
		scaleY = 'scale.y',
		offsetX = 'offset.x',
		offsetY = 'offset.y',
		flipX = 'flipX'
	})
	

	makeAnimatedLuaSprite(tag, props.image, props.x, props.y)
	addAnimationByPrefix(tag, 'stuff', props.frame, 0, false)
	scaleObject(tag, props.scaleX, props.scaleY, false)
	setProperty(tag .. '.flipX', props.flipX)
	offsetObject(tag, props.offsetX, props.offsetY)
	setProperty(tag .. '.alpha', shadowAlpha)

	if isBF then
	setProperty(tag .. '.colorTransform.redOffset', getProperty('boyfriend.healthColorArray[0]'))
	setProperty(tag .. '.colorTransform.greenOffset', getProperty('boyfriend.healthColorArray[1]'))
	setProperty(tag .. '.colorTransform.blueOffset', getProperty('boyfriend.healthColorArray[2]'))
    else
	setProperty(tag .. '.colorTransform.redOffset', 255)
	setProperty(tag .. '.colorTransform.greenOffset', 0)
	setProperty(tag .. '.colorTransform.blueOffset', 0)
	end
	
	addLuaSprite(tag, false)
	setObjectOrder(tag, getObjectOrder(char .. 'Group') - 1)
	
	if strong then
		doTweenY('YAx' .. tag, tag, props.y - xOff, 1.5, 'quadOut')
		doTweenX('YAy' .. tag, tag, props.x - yOff, 1.5, 'quadOut')
		doTweenAlpha('Ang' .. tag, tag, 0, 1, 'quadIn')
		doTweenColor('COL' .. tag, tag, '55DD61', 1.3, 'linear')
	else
		doTweenY('YAx' .. tag, tag, props.y - xOff, 0.85, 'quadIn')
		doTweenX('YAy' .. tag, tag, props.x - yOff, 1.5, 'quadOut')
		doTweenAlpha('Ang' .. tag, tag, 0, 0.8, 'quadOut')
	end
	
	shadowCount = shadowCount + 1
end

function offsetObject(obj, x, y)
	setProperty(obj .. '.offset.x', x)
	setProperty(obj .. '.offset.y', y)
end

function getProperties(par, props)
	local t = {}
	for i, v in pairs(props) do
		local ind = type(i) == 'string' and i or v
		t[ind] = getProperty(par .. '.' .. v)
	end
	return t
end

function getCharacter(char)
	if (type(char) ~= 'string') then return 'dad' end; char = char:lower()
	if (char:sub(1, 2) == 'bf' or char:sub(1, 3) == 'boy') then return 'boyfriend'
	elseif (char:sub(1, 2) == 'gf' or char:sub(1, 4) == 'girl') then return 'gf' end
	return 'dad'
end

function onTweenCompleted(t)
	if (t:sub(4, 3 + #shadowTag) == shadowTag) then
		local spr = t:sub(4, #t)
		removeLuaSprite(spr, true)
	end
end

function onEvent(name, v1, v2)
	if name == 'Event Trigger' then
		if v2 == 'specialPart' then
			shadowAlpha = 0.1
		else
			shadowAlpha = 0
		end
	end
end