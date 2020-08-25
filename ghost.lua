
Ghost = Enemy:new(0,0)
Ghost.speed=35

local ghostImg = love.graphics.newImage("assets/ghost.png")
local ghostImg2 = love.graphics.newImage("assets/ghost2.png")

function Ghost:update(dt)
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

	local hit = collisionEnemyExclude(self,self.x+dx,self.y)

	if hit==nil then
		self.x = self.x+dx
	end

	hit = collisionEnemyExclude(self,self.x, self.y+dy)

	if hit==nil then
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

function Ghost:draw()
	local xscale = 1
	if self.faceRight==false then xscale=-1 end

	love.graphics.setColor(palette.r,palette.g,palette.b,1)
	if self.animation<.25 then
		love.graphics.draw(ghostImg, math.floor(self.x+.5)+4, math.floor(self.y+.5)+4, 0, -xscale, 1, 4, 4)
	else
		love.graphics.draw(ghostImg2, math.floor(self.x+.5)+4, math.floor(self.y+.5)+4, 0, -xscale, 1, 4, 4)
	end

	love.graphics.setColor(1,1,1,1)
end
