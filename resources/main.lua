local buttons = {}
local samples = {}
local sequence = {}
local playcoursor = 1
local gamecoursor = 1

-- warm up random generator :-)
math.randomseed( os.time() )
for i = 0, 5 do
	math.random()
end

buttons[0] = director:createSprite( { source="images/Cow.png", xAnchor=1, yAnchor=1} )
buttons[0].sound = "Cow"
buttons[1] = director:createSprite( { source="images/Goat.png", xAnchor=1, yAnchor=1} )
buttons[1].sound = "Goat"
buttons[2] = director:createSprite( { source="images/Donkey.png", xAnchor=1, yAnchor=1} )
buttons[2].sound = "Donkey"
buttons[3] = director:createSprite( { source="images/Lamb.png", xAnchor=1, yAnchor=1} )
buttons[3].sound = "Lamb"

local pointsLabel = director:createLabel( {
        hAlignment="centre",
        font="fonts/ComicSans24.fnt",
        xScale=1, yScale=1,
        text="",
        color={0xc0, 0xc0, 0xc0},
        } )

function reposition(event)
	print("reposition ")
	print(""..event.angle)
	local dw = 0
	local dh = 0
	if event.angle == 90 or event.angle == 270 then
		dw = director.displayHeight
		dh = director.displayWidth
	else
		dw = director.displayWidth
		dh = director.displayHeight
	end
	buttons[0].x=dw/2 + 200
	buttons[0].y=dh/2
	buttons[1].x=dw/2
	buttons[1].y=dh/2
	buttons[2].x=dw/2 + 200
	buttons[2].y=dh/2 + 200
	buttons[3].x=dw/2
	buttons[3].y=dh/2 + 200
	pointsLabel.x=dw/2
	pointsLabel.y=dh/2
	pointsLabel.wrapWidth=dw
end
system:addEventListener("orientation", reposition)
reposition({angle=0})

function reset()
	gamecoursor = 1
	playcoursor = 1
	sequence = {}
	addToSequence()
end

function pressButtonEvent(event, node)
	if event.phase == "began" then
		audio:playSound(samples[node.sound])
		node.xScale = 1.2
		node.yScale = 1.2
	elseif event.phase == "ended" then
		node.xScale = 1
		node.yScale = 1
		if(sequence[gamecoursor] == node.sound) then
			gamecoursor = gamecoursor + 1
		else
			reset()
		end
	end
end

for i = 0, 3 do
	local animal = buttons[i].sound
	samples[animal] = "sounds/"..animal..".wav"
	audio:loadSound(samples[animal])
	buttons[i]:addEventListener("touch", pressButtonEvent)
end

function addToSequence()
	local rand = math.random(0, 3)
	table.insert(sequence, buttons[rand].sound)
	playcoursor = 1
	gamecoursor = 1
end

function playNext()
	audio:playSound(samples[sequence[playcoursor]])
	for i = 0, 3 do
		if buttons[i].sound == sequence[playcoursor] then
			if math.random(0, 1) == 0 then
				buttons[i].rotation = 20
			else
				buttons[i].rotation = -20
			end
		else
			buttons[i].rotation = 0
		end
	end
end

local even = 0
local tick = function(timer)
	if even == 0 then
		even = 1
		return
	else
		even = 0
	end
	local i = #sequence
	print("seq len: "..i.." game: "..gamecoursor.." play:"..playcoursor)
	if gamecoursor > i then
		addToSequence()
	end 
	
	if playcoursor <= i then
		playNext()
		playcoursor = playcoursor + 1
	elseif playcoursor == (i + 1) then
		for i = 0, 3 do
			buttons[i].rotation = 0
		end
		playcoursor = playcoursor + 1
	end
	
	pointsLabel.text=(gamecoursor-1).."/"..i
end 

reset()
local timer = system:addTimer(tick, 0.5)