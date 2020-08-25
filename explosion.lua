

--TIME FOR SOME EXPLOSIONS

require "debris"

Explosion = {

	x=0,
	y=0,
	frame=0,
	animationTimer=0,
	hitEnemy=false,
	remove=false

}

local img01 = love.graphics.newImage("assets/explosion01.png")
local img02 = love.graphics.newImage("assets/explosion02.png")
local img03 = love.graphics.newImage("assets/explosion03.png")
local img04 = love.graphics.newImage("assets/explosion04.png")

local debris = love.graphics.newImage("assets/explosion_debris.png")

function Explosion:new(x,y,h)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x=x
	o.y=y
	o.hitEnemy = h
	return o
end

function Explosion:update(dt)
	self.animationTimer = self.animationTimer + dt

	if self.animationTimer>=.03 then
		self.animationTimer = 0
		self.frame = self.frame+1

		if self.frame == 4 then
			self.remove = true

			love.graphics.setColor(70/255, 70/255, 70/255,200/255)
			drawDebris(debris,self.x+love.math.random(-1,1),self.y+love.math.random(-1,1))
			love.graphics.setColor(1,1,1,1)

		end
	end

end

function Explosion:draw()
	local img = img01

	if self.frame == 0 then
		img = img01
	elseif self.frame == 1 then
		img = img02
	elseif self.frame == 2 then
		img = img03
	elseif self.frame == 3 then
		img = img04
	else
		return
	end

	--Red explosion when enemy is hit
	if self.hitEnemy then
		love.graphics.setColor(1,1,1,1)
	end

	love.graphics.setColor(palette.r,palette.g,palette.b,1)
	love.graphics.draw(img,math.floor(self.x+.5), math.floor(self.y+.5))
	love.graphics.setColor(1,1,1,1)
end
