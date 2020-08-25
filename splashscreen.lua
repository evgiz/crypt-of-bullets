

SplashScreen = {
	timer=0
}

local splash = love.graphics.newImage("assets/title.png")

function SplashScreen:new()
	o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function SplashScreen:update(dt)
	if self.timer<4 then
		self.timer = self.timer+dt
		return
	end

	screen = Menu:new()
end

function SplashScreen:draw()

	local alpha = self.timer*1

	if self.timer>3 then
		alpha = 1-(self.timer-3)*1
	end

	love.graphics.setColor(1,1,1, alpha)
	love.graphics.draw(splash, 0, 0)
	love.graphics.setColor(100/255,100/255,100/255, alpha)
	love.graphics.print("A GAME BY EVGIZ", (240-love.graphics.getFont():getWidth("A GAME BY EVGIZ"))/2,136-10)
	love.graphics.setColor(1,1,1,1)

end
