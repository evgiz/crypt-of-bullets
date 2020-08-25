
Menu = {
	select = 1,
	canDown=true,
	canUp=true,
	canSelect=false,
	play=false,

	options={
		"PLAY",
		"PALETTE: ",
		"AUDIO ON",
		"FULLSCREEN OFF",
		"VSYNC OFF",
		"QUIT"
	}
}

local selectImg = love.graphics.newImage("assets/select.png")
local smallTitle = love.graphics.newImage("assets/title_small.png")

local selectSound = love.audio.newSource("audio/select.wav", "static")
local actionSound = love.audio.newSource("audio/action.wav", "static")

function Menu:new(inGame)
	o = {}
	setmetatable(o, self)
	self.__index = self

	if inGame then
		o.options[1] = "RESUME"
	end

	local w,h,f = love.window.getMode()

	if love.audio.getVolume()==0 then
		o.options[3] = "AUDIO OFF"
	end

	if f.fullscreen then
		o.options[4] = "FULLSCREEN ON"
	end

	if f.vsync then
		o.options[5] = "VSYNC ON"
	end

	return o
end

function Menu:update(dt)
	if love.keyboard.isDown("down") then
		if self.canDown then
			self.canDown = false
			self.select = self.select+1

			if self.select>tablelength(self.options) then
				self.select = 1
			end

			selectSound:play()
		end
	else
		self.canDown = true
	end

	if love.keyboard.isDown("up") then
		if self.canUp then
			self.canUp = false
			self.select = self.select-1

			if self.select<1 then
				self.select = tablelength(self.options)
			end

			selectSound:play()
		end
	else
		self.canUp = true
	end

	if love.keyboard.isDown("space") then
		if self.canSelect then
			self.canSelect = false
			actionSound:play()

			if self.select == 1 then
				screen = nil
			elseif self.select == 2 then
				repeat
					paletteSelected = paletteSelected+1
					if paletteSelected>tablelength(paletteList) then
						paletteSelected = 1
					end
				until paletteList[paletteSelected].open

				palette = paletteList[paletteSelected]
			elseif self.select == 3 then
				if love.audio.getVolume()>0 then
					love.audio.setVolume(0)
					self.options[3] = "AUDIO OFF"
				else
					love.audio.setVolume(1)
					self.options[3] = "AUDIO ON"
				end
			elseif self.select == 4 then

				love.window.setFullscreen(love.window.getFullscreen()==false)
				if love.window.getFullscreen() then
					self.options[4] = "FULLSCREEN ON"
				else
					self.options[4] = "FULLSCREEN OFF"
				end

			elseif self.select == 5 then
				love.window.setFullscreen(false)
				self.options[4] = "FULLSCREEN OFF"

				local w,h,f = love.window.getMode()

				f.vsync = (f.vsync==false)
				love.window.setMode(w,h,f)

				if f.vsync then
					self.options[5] = "VSYNC ON"
				else
					self.options[5] = "VSYNC OFF"
				end

				love.resize(w, h)
			elseif self.select == 6 then
				love.event.push("quit")
			end

		end
	else
		self.canSelect = true
	end
end

function Menu:draw()

	love.graphics.draw(smallTitle, -10,-5)

	if save_Highscore>0 then
		love.graphics.print("HIGHSCORE: "..save_Highscore, 140,20)
	end

	local yoff = -5
	for i=1,tablelength(self.options) do
		local txt = self.options[i]

		if i==self.select then
			love.graphics.draw(selectImg, 15,yoff+54+i*10)
			love.graphics.print(txt, 25,yoff+50+i*10)

			if i == 2 then
				love.graphics.setColor(palette.r,palette.g, palette.b, 1)
				love.graphics.print(paletteList[paletteSelected].name, 75,yoff+50+i*10)
				love.graphics.setColor(1,1,1,1)
			end
		else
			love.graphics.print(txt, 20,yoff+50+i*10)
			if i == 2 then
				love.graphics.setColor(palette.r,palette.g, palette.b, 1)
				love.graphics.print(paletteList[paletteSelected].name, 70,yoff+50+i*10)
				love.graphics.setColor(1,1,1,1)
			end
		end
	end
	love.graphics.setColor(100/255, 100/255, 100/255, 1)
	love.graphics.print("CREATED BY EVGIZ FOR LUDUM DARE 36", 20,136-12)
	love.graphics.setColor(1,1,1,1)
end
