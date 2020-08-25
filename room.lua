--Width = 30 tiles
--Height = 15 tiles

require "collision"
require "ghost"
require "turret"
require "destructible"
require "coin"
require "powerup"
require "mage"

Room = {
	visited = false,
	source="",
	image,
	doorsOpen = false,
	cleared = false,
	isExit = false,
	flipx=false,
	flipy=false,
	tiles={},
	entities={},
	up,
	down,
	left,
	right,
	canvas,
}

local randomRooms = {
	"default",
	"room01",
	"room02",
	"room03",
	"room04",
	"room05",
	"room06",
	"room07",
	"room08",
	"room09",
	"room10",
	"room11",
	"room12",
	"turret_room",
}

local wallImg = love.graphics.newImage("assets/wall.png")
local doorImg = love.graphics.newImage("assets/door.png")
local doorOpenImg = love.graphics.newImage("assets/doorOpen.png")
local stairsImg = love.graphics.newImage("assets/stairs.png")
local stairsClosedImg = love.graphics.newImage("assets/stairs_closed.png")
local roomClearAud = love.audio.newSource("audio/room_clear.wav", "static")

function Room:new(top, down, left, right)
	o = {}
	setmetatable(o, self)
	self.__index = self

	o.up = top
	o.down = down
	o.left = left
	o.right = right

	local c = love.graphics.newCanvas(240, 136)

	o.canvas = c
	o.entities = {}

	return o
end

function Room:load(source)

	if source == "random" then
		source = randomRooms[love.math.random(1,tablelength(randomRooms))]
	end

	self.image = love.image.newImageData("level/"..source..".png")
	self.tiles = {}

	self.flipx = love.math.random(0,1)==0
	self.flipy = love.math.random(0,1)==0

	for x=0,29 do
		self.tiles[x] = {}
		for y=0,15 do

			local xx = x
			local yy = y

			if self.flipx then xx = 29-x end
			if self.flipy then yy = 15-y end
			local r, g, b, a = self.image:getPixel(xx,yy)

			print(xx..", "..yy)
			self.tiles[x][y] = self:getTile(r,g,b,x,y)
		end
	end

	self:updateDoors()

end

function Room:updateDoors()
	--Doors
	local open = 2
	if tablelength(enemies) == 0 then
		open = 3
		self.doorsOpen = true
	end
	self.doorsOpen = false

	if self.left then
		self.tiles[0][7] = open
		self.tiles[0][8] = open
	end

	if self.right then
		self.tiles[29][7] = open
		self.tiles[29][8] = open
	end

	if self.up then
		self.tiles[14][0] = open
		self.tiles[15][0] = open
		self.tiles[16][0] = open
	end

	if self.down then
		self.tiles[14][15] = open
		self.tiles[15][15] = open
		self.tiles[16][15] = open
	end
end

--[[
Tiles:
	0 - empty
	1 - wall
	2 - door closed
	3 - door open
	4 - stairs to next level
]]
function Room:getTile(r,g,b,x,y)
	if r == 0 and g==0 and b==0 then
		return 1
	elseif r==255 and g==255 and b==255 then
		return 0
	elseif r==255 and g==0 and b==0 then
		--Turrets
		if world.level>3 or love.math.random(0, 4-world.level)==0 then
			table.insert(self.entities, Turret:new(x*8,y*8))
		end
		return 0
	elseif r==127 and g==51 and b==0 then
		--Destructible
		if love.math.random(0,3)~=0 then
			table.insert(self.entities, Destructible:new(x*8,y*8))
		end
		return 0

	elseif r==218 and g==255 and b==127 then
		--Powerup
		table.insert(self.entities, Powerup:new(x*8,y*8))
		return 0
	elseif r==0 and g==0 and b==255 then
		--Only one is made stairs
		return 0
	else
		print("Unknown color: "..r,","..g..","..b)
		return 0
	end
end

function Room:makeExit()
	local ax = {}
	local ay = {}

	local options = 0
	for xx=0,29 do
		for yy=0,15 do


			local xxx = xx
			local yyy = yy

			if self.flipx then xxx = 29-xx end
			if self.flipy then yyy = 15-yy end

			local r,g,b,a = self.image:getPixel(xxx,yyy)


			if r==0 and g==0 and b==1 then

				ax[options] = xx
				ay[options] = yy

				options = options+1

			end

			--print(r..", "..g..", "..b.."...")
		end
	end

	local alt = love.math.random(0, options-1)

	if options == 0 then
		return false
	end

	self.tiles[ax[alt]] [ay[alt]] = 4
	world.exitx = ax[alt]
	world.exity = ay[alt]

	return true
end

function Room:update(dt)
	--Open door
	if self.doorsOpen==false and tablelength(enemies) == 0 then
		self:updateDoors()
		if self.cleared == false then
			self.cleared = true
			message = "ROOM CLEAR!"
			messageTime = 2
			roomClearAud:play()
		end
	end

	--Room change
	if player.x<-8 then
		player.x = 240-16
		world:move(-1,0)
	elseif player.x>240 then
		player.x = 8
		world:move(1,0)
	elseif player.y>136 then
		player.y = 16
		world:move(0,1)
	elseif player.y<8 then
		player.y = 136-16
		world:move(0,-1)
	end

	for k,v in pairs(self.entities) do
		v:update(dt)

		if v.remove then
			table.remove(self.entities, k)
		end
	end
end

function Room:generateMonsters(level)
	local monsterCount = love.math.random(0, level+3)
	local x,y
	local tries = 0

	while tries<1000 and monsterCount>0 do
		tries = tries+1
		x = love.math.random(4, 29-8)
		y = love.math.random(4, 15-8)

		if spaceFree(nil,x*8,y*8) then
			table.insert(enemies, self:getMonster(x,y))
			monsterCount = monsterCount-1
		end


	end


	--Generate coins
	local coins = love.math.random(0,6)

	if love.math.random(0,50) == 0 then
		coins = 60
	end

	for i=0, coins do
		local free = false
		local tries = 0
		local x,y

		while free~=true and tries<100 do
			x = love.math.random(8,240-16)
			y = love.math.random(8,136-16)
			free = (entityCollision(x,y)==nil) and spaceFreeWorld(x,y)
			tries = tries+1
		end

		table.insert(world.currentRoom.entities, Coin:new(x,y,false))

	end


end

function Room:getMonster(x,y)
	if world.level>1 and love.math.random(0,3)==0 then
 		return Mage:new(x*8,y*8)
	end

	if love.math.random(0,1)==1 then
		 return Enemy:new(x*8,y*8)
	 else
		 return Ghost:new(x*8,y*8)
	 end
end

function Room:draw(spriteBatch)

	--Debris
	love.graphics.setColor(1,1,1, 230/255)
	love.graphics.draw(self.canvas, 0,0)
	love.graphics.setColor(1,1,1,1)

	for k,v in pairs(self.entities) do
		v:draw()
	end

	spriteBatch:setTexture(wallImg)
	for x=0,29 do
		for y=0,15 do
			tile = self.tiles[x][y]

			if tile == 1 then
				spriteBatch:add(x*8,y*8+8)
			elseif tile==2 then
				love.graphics.draw(doorImg,x*8,y*8+8)
			elseif tile==3 then
				love.graphics.draw(doorOpenImg,x*8,y*8+8)
			elseif tile==4 then
				if tablelength(enemies)>0 then
					love.graphics.draw(stairsClosedImg,x*8,y*8+8)
				else
					love.graphics.draw(stairsImg,x*8,y*8+8)
				end
			end
		end
	end

	spriteBatch:flush()
end
