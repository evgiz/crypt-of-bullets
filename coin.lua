
Coin = {
	x=0,
	y=0,
	dx=0,
	dy=0,
	speed=10,
	isCrystal=false
}

local coinImage = love.graphics.newImage("assets/coin.png")
local crystalImage = love.graphics.newImage("assets/crystal.png")

local coinStep = 0
local coinAud = {
	love.audio.newSource("audio/coin.wav", "static"),
	love.audio.newSource("audio/coin.wav", "static"),
	love.audio.newSource("audio/coin.wav", "static"),
	love.audio.newSource("audio/coin.wav", "static")
}

function Coin:new(x,y,move)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.x = x
	o.y = y
	local dir = math.rad(love.math.random(0, 360))
	o.dx = math.cos(dir)
	o.dy = math.sin(dir)

	if move==false and love.math.random(0,20)==0 then
		o.isCrystal = true
	end

	if move == false then
		o.speed = 0
	end

	return o
end

function Coin:update(dt)
	if self.speed>0 then
		if spaceFreeWorld(self.x,self.y) == false then
			self.speed = 0
			return
		end
		self.x = self.x+self.dx*self.speed*dt
		self.y = self.y+self.dy*self.speed*dt
		self.speed = self.speed-dt*5
	end

	--Pickup
	if checkCollision(self.x-4,self.y-4,14,14,player.x,player.y,8,8) then
		self.remove = true

		coinAud[coinStep+1]:setVolume(.5)
		coinAud[coinStep+1]:play()
		coinStep = coinStep+1
		if(coinStep>tablelength(coinAud)-1) then coinStep=0 end

		if self.isCrystal then
			score = score+15
			message = "FOUND CRYSTAL! SCORE +15"
			messageTime = 2
		else
			score = score+1
		end
	end

end

function Coin:draw()

	if self.isCrystal then
		love.graphics.setColor(255, 0, 255, 255)
		love.graphics.draw(crystalImage, math.floor(self.x+.5), math.floor(self.y+.5), 0, 1, 1, 4, 4)
	else
		love.graphics.setColor(255, 255, 0, 255)
		love.graphics.draw(coinImage, math.floor(self.x+.5), math.floor(self.y+.5), 0, 1, 1, 4, 4)
	end
	love.graphics.setColor(255,255,255,255)
end
