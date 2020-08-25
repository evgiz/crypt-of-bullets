
require "debris"

Destructible =
{
	x=0,
	y=0,
	hp=2,
	remove = false
}

local block = love.graphics.newImage("assets/destructible.png")
local debris = love.graphics.newImage("assets/debris.png")

function Destructible:new(x,y)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x=x
	o.y=y+8
	return o
end

function Destructible:update(dt)
	if self.hp<=0 then
		self.remove = true

		if love.math.random(0,5) == 0 then
			table.insert(world.currentRoom.entities, Coin:new(self.x,self.y,true))
		end

		for i=1,3 do
			local can = love.graphics.getCanvas()
			love.graphics.setColor(100/255,100/255,100/255, 1)
			drawDebris(debris,self.x+love.math.random(-3,3),self.y+love.math.random(-3,3))
			love.graphics.setColor(1,1,1,1)
		end
	end
end

function Destructible:draw(dt)
	love.graphics.setColor(100/255,100/255,100/255,1)
	love.graphics.draw(block, math.floor(self.x+.5), math.floor(self.y+.5))
	love.graphics.setColor(1,1,1,1)
end
