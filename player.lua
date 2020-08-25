require "bullet"
require "collision"
require "gameover"

Player = {

	x=0,
	y=0,
	firerate=8,
	firetimer=0,
	animation=0,
	faceRight = true,
	speed=80,
	onStairs = false,

	health = 5,
	damageTimer = 0
}

local playerImg = love.graphics.newImage("assets/player.png")
local playerImg2 = love.graphics.newImage("assets/player02.png")

local shootStep = 0
local shootAud = {
	love.audio.newSource("audio/shoot.ogg","static"),
	love.audio.newSource("audio/shoot.ogg","static"),
	love.audio.newSource("audio/shoot.ogg","static")
}
local damageAud = love.audio.newSource("audio/player_damage.wav", "static")

function Player:new()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Player:update(dt)

	--Movement
	local dir_x = 0.0
	local dir_y = 0.0
	if love.keyboard.isDown("w") then dir_y = dir_y - 1.0 end
	if love.keyboard.isDown("a") then dir_x = dir_x - 1.0 end
	if love.keyboard.isDown("s") then dir_y = dir_y + 1.0 end
	if love.keyboard.isDown("d") then dir_x = dir_x + 1.0 end

	dir_x = dir_x*self.speed*dt
	dir_y = dir_y*self.speed*dt

	local free = spaceFree(nil, self.x+dir_x, self.y)

	if free then
		self.x = self.x+dir_x
	end

	free = spaceFree(nil, self.x, self.y+dir_y)

	if free then
		self.y = self.y+dir_y
	end

	--Animation

	if dir_x<0 then
		self.faceRight = false
	elseif dir_x>0 then
		self.faceRight = true
	end

	if dir_x~=0 or dir_y~=0 then
		self.animation = self.animation+dt*2
	else
		self.animation = 0
	end
	if self.animation>.5 then
		self.animation = self.animation-.5
	end

	--Shooting
	local shoot_x = 0
	local shoot_y = 0
	if love.keyboard.isDown("up") then shoot_y = shoot_y - 1 end
	if love.keyboard.isDown("left") then shoot_x = shoot_x - 1 end
	if love.keyboard.isDown("down") then shoot_y = shoot_y + 1 end
	if love.keyboard.isDown("right") then shoot_x = shoot_x + 1 end

	if self.firetimer<1/self.firerate then
		self.firetimer = self.firetimer+dt
	end

	if shoot_x~=0 or shoot_y~=0 then
		if self.firetimer>=1/self.firerate then
			self.firetimer = 0
			dir = math.atan2(shoot_y, shoot_x)
			table.insert(bullets, Bullet:new(self.x+4+math.cos(dir)*8,self.y+4+math.sin(dir)*8,dir))

			shootAud[shootStep+1]:play()
			shootStep = shootStep+1
			if(shootStep>tablelength(shootAud)-1) then shootStep=0 end

			--Knockback
			local xb = -math.cos(dir)*2
			local yb = -math.sin(dir)*2
			if spaceFree(nil,self.x+xb,self.y+yb) then
				self.x = self.x+xb
				self.y = self.y+yb
			end

			--ScreenShake
			screenShake = screenShake+.025

		end
	end

	--Face if Shooting
	if shoot_x<0 then
		self.faceRight = false
	elseif shoot_x>0 then
		self.faceRight = true
	end

	--Enter stairs
	local tx = math.floor(((self.x+8.0)/8.0)+.5)
	local ty = math.floor(((self.y+8.0)/8.0)+.5)+1
	tx = math.min(tx, 29)
	ty = math.min(ty, 15)
	tx = math.max(tx, 0)
	ty = math.max(ty, 0)

	--Next level
	if tablelength(enemies)==0 and
		world.currentRoom.isExit
		and checkCollision(self.x-4,self.y-4,16,16,world.exitx*8+2,world.exity*8+2+8,4,4) then
			self.onStairs = true
			message = "PRESS SPACE TO ENTER"
			messageTime = .2
			if love.keyboard.isDown("space") then
				world:nextLevel()
			end
	else self.onStairs = false
	end

	--Damage
	if self.damageTimer>0 then
		self.damageTimer = self.damageTimer-dt
	end


end

function Player:takeDamage(dmg)
	if self.damageTimer>0 then
		return
	end

	love.timer.sleep(1/60 * 4)
	self.health = self.health-dmg
	self.damageTimer = .5
	damageAud:play()

	--GAME OVER
	if self.health<=0 then
		screen = GameOver:new()
	end

	if self.health>1 then
		message = "OUCH!"
	else
		message = "LOW HEALTH!"
	end
	messageTime = 1
	screenShake = .3

end

function Player:draw()
	local xscale = 1
	if self.faceRight==false then
		xscale=-1
	end

	if self.damageTimer>0 then
		if math.sin(math.rad(self.damageTimer*1000))>0 then
			love.graphics.setColor(1, 0, 0, 1)
		end
	end

	if self.animation<.25 then
		love.graphics.draw(playerImg, math.floor(self.x + .5)+4, math.floor(self.y + .5)+4,0, xscale, 1, 4, 4)
	else
		love.graphics.draw(playerImg2, math.floor(self.x + .5)+4, math.floor(self.y + .5)+4,0, xscale, 1, 4, 4)
	end

	love.graphics.setColor(1,1,1,1)
end
