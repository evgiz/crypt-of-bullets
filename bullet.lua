require "collision"
require "explosion"

Bullet = {

	x=0,
	y=0,
	dx=0,
	dy=0,
	direction=0,
	hp=.25,
	speed=200,
	damage=10,
	remove = false

}

local bulletImg = love.graphics.newImage("assets/bullet.png")

function Bullet:new(x,y,dir)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x=x
	o.y=y
	o.direction=dir
	o.dx = math.cos(dir)
	o.dy = math.sin(dir)
	return o
end

function Bullet:update(dt)
	self.x = self.x+self.dx*self.speed*dt
	self.y = self.y+self.dy*self.speed*dt

	--Health
	self.hp = self.hp-dt
	if self.hp<=0 then
		self.remove = true
		table.insert(particles, Explosion:new(self.x-4,self.y-4,false))
		return
	end

	--Wait 0.02 seconds so bullet is always visible for at least a bit
	if self.hp<Bullet.hp-0.02 then
		enemyHit=collisionEnemy(self.x,self.y)
		if enemyHit~=nil then
			enemyHit:takeDamage(self.damage)
			self.remove = true
			table.insert(particles, Explosion:new(self.x-4,self.y-4,true))
		end
	end

	if spaceFreeWorld(self.x-4,self.y-4,8,8)==false then
		self.hp=0
	end

	local dest = hitDestructible(self.x,self.y)
	if dest~=nil then
		self.hp=0
		dest.hp = dest.hp-1
	end

end

function Bullet:draw()
	love.graphics.draw(bulletImg, math.floor(self.x+.5), math.floor(self.y+.5), self.direction+math.rad(90), 1, 1, 4, 4)
end
