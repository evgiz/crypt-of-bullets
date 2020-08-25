
Fireball =
{
	x=0,
	y=0,
	direction=0,
	dx=0,
	dy=0,
	speed=90,
	remove = false
}

local turretImg = love.graphics.newImage("assets/fireball.png")

function Fireball:new(x,y)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x=x
	o.y=y

	o.direction = math.atan2(player.y-y, player.x-x)
	o.dx = math.cos(o.direction)
	o.dy = math.sin(o.direction)

	return o
end

function Fireball:update(dt)

	self.x = self.x+self.dx*dt*self.speed
	self.y = self.y+self.dy*dt*self.speed

	if checkCollision(self.x+2,self.y+2,4,4,player.x,player.y,8,8) then
		player:takeDamage(1)
		remove = true
	end

	if self.x<-8 or self.x>240 then
		remove = true
	elseif self.y<-8 or self.y>136 then
		remove = true
	end

end

function Fireball:draw(dt)
	love.graphics.setColor(palette.r,palette.g,palette.b,1)
	love.graphics.draw(turretImg, math.floor(self.x+.5), math.floor(self.y+.5))
	love.graphics.setColor(1,1,1,1)
end
