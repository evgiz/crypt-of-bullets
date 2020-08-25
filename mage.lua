
Mage = Enemy:new(0,0)
Mage.speed=40
Mage.firerate = .5
Mage.firetimer = 0
Mage.randomDirection = 0
Mage.health = 40

local mageImg = love.graphics.newImage("assets/mage01.png")
local mageImg2 = love.graphics.newImage("assets/mage02.png")

function Mage:update(dt)
	if self.randomDirection == 0 then
		self.randomDirection = math.rad(love.math.random(0,360))
	end
	self.firerate = .5 + world.level/10

	if self.sleepTimer>0 then
		self.sleepTimer = self.sleepTimer-dt
		return
	end

	local dir = math.atan2(self.y - player.y, self.x-player.x)
	local dx = math.cos(dir)*self.speed*dt
	local dy = math.sin(dir)*self.speed*dt

	--Dont move if player is far away
	local dist_x = math.abs(self.x-player.x)
	local dist_y = math.abs(self.y-player.y)
	local far = false
	if dist_x*dist_x+dist_y*dist_y > 50*50 then
		dx = math.cos(self.randomDirection)*self.speed*dt*.75
		dy = math.sin(self.randomDirection)*self.speed*dt*.75
		far = true
	end

	self.firetimer = self.firetimer + dt
	if self.firetimer>1/self.firerate then
		self.firetimer = self.firetimer-1/(love.math.random(.75,1.25)*self.firerate)
		table.insert(world.currentRoom.entities, Fireball:new(self.x,self.y));

		self.randomDirection = math.rad(love.math.random(0,360))

	end

	if dx<0 then
		self.faceRight = false
	elseif dx>0 then
		self.faceRight = true
	end

	local hit = collisionEnemyExclude(self,self.x+dx,self.y)

	if hit==nil and spaceFree(nil,self.x+dx, self.y) then
		self.x = self.x+dx
	end

	hit = collisionEnemyExclude(self,self.x, self.y+dy)

	if hit==nil and spaceFree(nil,self.x, self.y+dy) then
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

function Mage:draw()
	local xscale = 1
	if self.faceRight==false then xscale=-1 end

	love.graphics.setColor(palette.r,palette.g,palette.b,1)
	if self.animation<.25 then
		love.graphics.draw(mageImg, math.floor(self.x+.5)+4, math.floor(self.y+.5)+4, 0, -xscale, 1, 4, 4)
	else
		love.graphics.draw(mageImg2, math.floor(self.x+.5)+4, math.floor(self.y+.5)+4, 0, -xscale, 1, 4, 4)
	end

	love.graphics.setColor(1,1,1,1)
end
