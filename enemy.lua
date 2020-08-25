require "collision"
require "debris"

Enemy = {
	x=0,
	y=0,
	speed=55,
	health=50,
	animation=0,
	sleepTimer=.25,
	faceRight = true,
	remove = false,
	damage = 1
}

local enemyImg = love.graphics.newImage("assets/enemy01.png")
local enemyImg2 = love.graphics.newImage("assets/enemy02.png")
local bloodImg = love.graphics.newImage("assets/blood.png")

local hurtAudStep = 0
local hurtAud = {
	love.audio.newSource("audio/hurt.ogg", "static"),
	love.audio.newSource("audio/hurt.ogg", "static"),
	love.audio.newSource("audio/hurt.ogg", "static")
}

local dieAudStep = 0
local dieAud = {
	love.audio.newSource("audio/enemy_die.ogg", "static"),
	love.audio.newSource("audio/enemy_die.ogg", "static"),
	love.audio.newSource("audio/enemy_die.ogg", "static")
}


function Enemy:new(x,y)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x=x
	o.y=y
	o.sleepTimer = love.math.random(.3,.5)
	return o
end

function Enemy:update(dt)
	if self.sleepTimer>0 then
		self.sleepTimer = self.sleepTimer-dt
		return
	end

	local dir = math.atan2(self.y - player.y, self.x-player.x)
	local dx = - math.cos(dir)*self.speed*dt
	local dy = - math.sin(dir)*self.speed*dt

	if dx<0 then
		self.faceRight = false
	elseif dx>0 then
		self.faceRight = true
	end

	local free = spaceFree(self,self.x+dx, self.y) and collisionEnemyExclude(self,self.x+dx, self.y)==nil

	if free then
		self.x = self.x+dx
	end

	free = spaceFree(self,self.x, self.y+dy)  and collisionEnemyExclude(self,self.x, self.y+dy)==nil

	if free then
		self.y = self.y+dy
	end

	self.animation = self.animation+dt
	if self.animation>.5 then
		self.animation = self.animation-.5
	end

	if checkCollision(self.x, self.y, 8,8, player.x,player.y,8,8) then
		player:takeDamage(self.damage)
		self.sleepTimer = .25
	end

end

function Enemy:takeDamage(dmg)
	self.health = self.health-dmg
	if self.health<=0 then
		self.remove = true
		dieAud[dieAudStep+1]:play()
		dieAudStep = dieAudStep+1
		if dieAudStep>tablelength(dieAud)-1 then
			dieAudStep = 0
		end

		local c = love.math.random(3,6)
		for i=1,c do
			table.insert(world.currentRoom.entities, Coin:new(self.x,self.y,true))
		end

		--ADD BLOOD
		for i=1,3 do
			local scl = 1
			if love.math.random(0,1)==0 then scl =-1 end
			drawDebrisPalette(bloodImg,self.x+love.math.random(-5,5),self.y+love.math.random(-5,5), 0, scl,1,4,4)
		end

		return
	end

	hurtAud[hurtAudStep+1]:play()
	hurtAudStep = hurtAudStep+1
	if hurtAudStep>tablelength(hurtAud)-1 then
		hurtAudStep = 0
	end

	local scl = 1
	if love.math.random(0,1)==0 then scl =-1 end
	drawDebrisPalette(bloodImg,self.x+love.math.random(-5,5),self.y+love.math.random(-5,5), 0, scl,1,4,4)
end

function Enemy:draw()
	local xscale = 1
	if self.faceRight==false then xscale=-1 end

	love.graphics.setColor(palette.r,palette.g,palette.b,255)
	if self.animation<.25 then
		love.graphics.draw(enemyImg, math.floor(self.x+.5)+4, math.floor(self.y+.5)+4, 0, -xscale, 1, 4, 4)
	else
		love.graphics.draw(enemyImg2, math.floor(self.x+.5)+4, math.floor(self.y+.5)+4, 0, -xscale, 1, 4, 4)
	end

	love.graphics.setColor(255, 255, 255, 255)
end
