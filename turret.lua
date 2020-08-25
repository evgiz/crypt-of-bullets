require "fireball"

Turret =
{
	x=0,
	y=0,

	firerate = 1,
	firetimer = .2,
	enabled = true
}

local turretImg = love.graphics.newImage("assets/turret.png")

function Turret:new(x,y)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x=x
	o.y=y+4

	o.firerate = .4+world.level/20

	return o
end

function Turret:update(dt)

	self.firetimer = self.firetimer + dt

	if self.firetimer>1/self.firerate then
		self.firetimer = self.firetimer-1/self.firerate

		if self.enabled and tablelength(enemies)>0 then
			table.insert(world.currentRoom.entities, Fireball:new(self.x,self.y));
		end

	end

end

function Turret:draw(dt)
	love.graphics.draw(turretImg, math.floor(self.x+.5), math.floor(self.y+.5))
end
