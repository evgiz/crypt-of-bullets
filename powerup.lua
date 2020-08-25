require "bullet"

Powerup = {
	x=0,
	y=0,
	dx=0,
	dy=0,
	speed=10,
}

local img = love.graphics.newImage("assets/powerup.png")
local powerupAud = love.audio.newSource("audio/powerup.wav", "static")

function Powerup:new(x,y,move)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x = x+4
	o.y = 136/2+4

	return o
end

function Powerup:update(dt)
	--Pickup
	if checkCollision(self.x-4,self.y-4,14,14,player.x,player.y,8,8) then
		self.remove = true

		self:applyPowerup()
		powerupAud:play()

	end

end

function Powerup:applyPowerup()
	local option = love.math.random(0,3)

	if option == 0 then
		if player.health<5 then
			player.health = player.health+1
			messageTime = 2
			message = "HP UP!"
		else
			self:applyPowerup()
		end
	elseif option == 1 then
		player.speed = player.speed+8
		messageTime = 2
		message = "SPEED UP!"
	elseif option == 2 then
		player.firerate = player.firerate+.75
		messageTime = 2
		message = "FIRERATE UP!"
	elseif option == 3 then
		Bullet.hp = Bullet.hp+0.01
		messageTime = 3
		message = "RANGE UP!"
	end

end

function Powerup:draw()
	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.draw(img, math.floor(self.x+.5), math.floor(self.y+.5), 0, 1, 1, 4, 4)
	love.graphics.setColor(1,1,1,1)
end
