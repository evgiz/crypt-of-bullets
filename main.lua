require "player"
require "enemy"
require "world"
require "ui"
require "menu"
require "save"
require "splashscreen"

--Other
scale = 3
canvas = nil
spriteBatch = nil
texture = nil
screenShake = 0

paletteSelected = 1
palette = {r=160/255, g=30/255, b=30/255}

paletteList =
{
	{r=160/255, g=30/255, b=30/255, name="BLOOD", open=true},
 	{r=40/255, g=30/255, b=200/255, name="OCEAN", open=true},
 	{r=0/255, g=138/255, b=40/255, name="FOREST", open=true},
	{r=255/255, g=155/255, b=233/255, name="NOVICE", desc="PLAY YOUR FIRST GAME", open=false},
	{r=255/255, g=106/255, b=0/255, name="SCOUT", desc="SCORE 100 OR MORE", open=false},
	{r=175/255, g=222/255, b=255/255, name="KNIGHT", desc="SCORE 500 OR MORE", open=false},
	{r=80/255, g=80/255, b=80/255, name="UNDERGROUND", desc="REACH FLOOR 3", open=false},
	{r=245/255, g=255/255, b=120/255, name="SUNSHINE", desc="REACH FLOOR 5", open=false},
	{r=255/255, g=0/255, b=0/255, name="RAINBOW", desc="SCORE 1000 OR MORE", open=false}


}

local music = love.audio.newSource("audio/game_music.ogg", "static")
local music_slow = love.audio.newSource("audio/game_music_slow.ogg", "static")

message = ""
messageTime = 0

--World
world = nil
bullets = {}
enemies = {}
particles = {}

--Objects
player = nil
screen = nil

function love.load(arg)
	loadGame()

	love.graphics.setDefaultFilter("nearest", "nearest", 0)
	canvas = love.graphics.newCanvas(240, 136)
	canvas:setFilter("nearest","nearest",0)
	texture = love.graphics.newImage(love.image.newImageData(240,136))
	spriteBatch = love.graphics.newSpriteBatch(texture)
	initUI()

	music:setLooping(true)
	music_slow:setLooping(true)
	music_slow:setPitch(0.8)

	newGame()
	screen = SplashScreen:new()

end

function newGame()
	player = Player:new()
	player.x = 240/2
	player.y = 136/2

	world = World:new()
	world:generate()

	bullets = {}
	enemies = {}
	particles = {}

	screenShake = 0
	music_slow:setLooping(true)
	music_slow:play()

	screen = Menu:new(false)

	score = 0
	gameTime = 0
	messageTime = 0
end


function love.update(dt)
	if screen~=nil then
		screen:update(dt)

		if music:isPlaying() or music_slow:isPlaying()==false then
			if music:isPlaying() then music:stop() end
			if music_slow:isPlaying()==false then
				music_slow:setLooping(true)
				music_slow:play()
			end
		end
		return
	else
		if love.keyboard.isDown("escape") or love.keyboard.isDown("return") then
			screen = Menu:new(true)
			return
		end

		if music_slow:isPlaying() or music:isPlaying()==false then
			if music_slow:isPlaying() then music_slow:stop() end
			if music:isPlaying()==false then
				music:play()
				music:setLooping(true)
			end
		end
	end

	if messageTime>0 then
		messageTime = messageTime-dt
	end

	updateUI(dt)

	if screenShake>0 then
		screenShake=screenShake-dt
	end

	world.currentRoom:update(dt)
	player:update(dt)

	for k,v in pairs(bullets) do
		v:update(dt)

		if v.remove then
			table.remove(bullets, k)
		end
	end

	for k,v in pairs(enemies) do
		v:update(dt)

		if v.remove then
			table.remove(enemies, k)
		end
	end

	for k,v in pairs(particles) do
		v:update(dt)

		if v.remove then
			table.remove(particles, k)
		end
	end
end

function love.resize(w, h)
	local xfit = math.floor(w/240)
	local yfit = math.floor(h/136)

	scale = math.min(yfit,xfit)
end

function love.draw(dt)

	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.setDefaultFilter("nearest", "nearest", 0)

	if screen~=nil then
		screen:draw()
		love.graphics.setCanvas()
		love.graphics.draw(canvas, (love.graphics.getWidth()-scale*240)/2,(love.graphics.getHeight()-scale*136)/2, 0, scale,scale)
		return
	end

	spriteBatch:clear()

	--Game render
	if world.currentx == world.startx and world.currenty == world.starty and world.level == 0 then
		drawTutorial()
	end

	world.currentRoom:draw(spriteBatch)
	player:draw()

	love.graphics.draw(spriteBatch)

	for k,v in pairs(bullets) do
		v:draw()
	end
	for k,v in pairs(enemies) do
		v:draw()
	end
	for k,v in pairs(particles) do
		v:draw()
	end

	drawUI()
	world:drawMap()

	love.graphics.setCanvas()

	local xx=0
	local yy=0
	if screenShake>0 then
		local mag = 2
		if player.damageTimer>0 then mag = 5 end
		xx = love.math.random(-mag,mag)
		yy = love.math.random(-mag,mag)

	end

	love.graphics.draw(canvas, (love.graphics.getWidth()-scale*240)/2+xx*scale/2,(love.graphics.getHeight()-scale*136)/2+yy*scale/2, 0, scale,scale)
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
