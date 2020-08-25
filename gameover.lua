

GameOver = {
	initialDelay = .5,
	gameOverAlpha = 0,
	statsAlpha = -255,
	paletteOpen = nil,
	high = "GAME OVER"
}

local selectImg = love.graphics.newImage("assets/select.png")

function GameOver:new()
	o = {}
	setmetatable(o, self)
	self.__index = self

	if paletteList[4].open == false then
		paletteList[4].open = true
		o.paletteOpen = paletteList[4]
	elseif paletteList[9].open == false and score>=1000 then
		paletteList[9].open = true
		o.paletteOpen = paletteList[9]
	elseif paletteList[8].open == false and world.level>=5 then
		paletteList[8].open = true
		o.paletteOpen = paletteList[8]
	elseif paletteList[7].open == false and world.level>=3 then
		paletteList[7].open = true
		o.paletteOpen = paletteList[7]
	elseif paletteList[6].open == false and score>=500 then
		paletteList[6].open = true
		o.paletteOpen = paletteList[6]
	elseif paletteList[5].open == false and score>=100 then
		paletteList[5].open = true
		o.paletteOpen = paletteList[5]
	end

	if score>save_Highscore then
		save_Highscore = score
		high = "NEW HIGHSCORE!"
	end

	saveGame()

	return o
end

function GameOver:update(dt)
	if self.initialDelay>0 then
		self.initialDelay = self.initialDelay-dt
		return
	end

	if self.gameOverAlpha<255 then
		self.gameOverAlpha = self.gameOverAlpha+dt*255
		return
	end

	if self.statsAlpha<255*5 then
		self.statsAlpha = self.statsAlpha+dt*255*1.5
		return
	end

	if love.keyboard.isDown("space") then
		newGame()
	end
end

function GameOver:draw()

	love.graphics.setColor(100/255,100/255,100/255, self.gameOverAlpha)
	love.graphics.print(self.high, (240-love.graphics.getFont():getWidth(self.high))/2,40)

	local txt = "TIME: "..getGameTime()
	love.graphics.setColor(1, 1, 1, self.statsAlpha-1)
	love.graphics.print(txt, (240-love.graphics.getFont():getWidth(txt))/2,65)

	love.graphics.setColor(1, 1, 1, self.statsAlpha)
	love.graphics.print("SCORE: "..score, (240-love.graphics.getFont():getWidth("SCORE: "..score))/2,55)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setColor(1, 1, 1, self.statsAlpha-1*2)
	love.graphics.print("FLOOR "..world.level, (240-love.graphics.getFont():getWidth("FLOOR "..world.level))/2,75)
	love.graphics.setColor(1,1,1,1)

	if self.paletteOpen ~= nil then
		love.graphics.setColor(self.paletteOpen.r, self.paletteOpen.g, self.paletteOpen.b, self.statsAlpha-1*3)
		love.graphics.print("UNLOCKED \""..self.paletteOpen.name.."\" PALETTE!", (240-love.graphics.getFont():getWidth("UNLOCKED \""..self.paletteOpen.name.."\" PALETTE!"))/2,5)
		love.graphics.print("("..self.paletteOpen.desc..")", (240-love.graphics.getFont():getWidth("("..self.paletteOpen.desc..")"))/2,15)
		love.graphics.setColor(1,1,1,1)
	end

	if self.statsAlpha>=255*5 then
		love.graphics.setColor(100/255, 100/255, 100/255, 1)
		love.graphics.print("SPACE TO CONTINUE", (240-love.graphics.getFont():getWidth("SPACE TO CONTINUE"))/2,math.floor(105+math.cos(love.timer.getTime()*7)*2 + .5))
		love.graphics.setColor(1,1,1,1)
	end


end
