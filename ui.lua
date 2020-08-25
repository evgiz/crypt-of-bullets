
score = 0
gameTime = 0
local heartImg = love.graphics.newImage("assets/heart.png")
local font = love.graphics.newFont("Codina.ttf",16)

function initUI()
	love.graphics.setFont(font)
end

function updateUI(dt)
	gameTime = gameTime + dt

	--Change palette over time
	if paletteSelected == 9 then
		local seconds = 3
		if palette.r>0 and palette.b<=0 then
			palette.r = palette.r-dt*255 / seconds
			palette.g = palette.g+dt*255 / seconds
		elseif palette.g>0 then
			palette.g = palette.g-dt*255 / seconds
			palette.b = palette.b+dt*255 / seconds
		else
			palette.b = palette.b-dt*255 / seconds
			palette.r = palette.r+dt*255 / seconds
		end
	end
end

function drawUI()

	love.graphics.setColor(0.7,0.7,0.7,1)
	love.graphics.print("HP",2,-4)
	love.graphics.print("FLOOR "..world.level,60,-4)
	love.graphics.print("SCORE "..score,120,-4)

	love.graphics.print("FPS: "..love.timer.getFPS(),4,10)

	if messageTime>0 then
		love.graphics.setColor(0,0,0,1)
		love.graphics.rectangle("fill", (240-font:getWidth(message))/2-3, 136-22,font:getWidth(message)+5, 10)
		love.graphics.setColor(0,1,0,1)
		love.graphics.print(message,(240-font:getWidth(message))/2,136-24)
		love.graphics.setColor(1,1,1,1)
	end

	love.graphics.setColor(180/255,180/255,180/255,255/255)
	love.graphics.print(getGameTime(),240-32,-4)

	for i=0,4 do
		if player.health>i then
			love.graphics.setColor(palette.r,palette.g,palette.b,255)
		else
			love.graphics.setColor(120/255, 120/255, 120/255, 1)
		end
		love.graphics.draw(heartImg,14+i*8,0)
		love.graphics.setColor(1,1,1,1)
	end
end

function drawTutorial()
	love.graphics.setColor(100/255, 100/255, 100/255, 1)
	love.graphics.print("MOVE WITH WASD",80,30)
	love.graphics.print("SHOOT WITH ARROWS",70,40)
	love.graphics.print("HOLD TAB TO SHOW MAP",65,90)
	love.graphics.print("GOOD LUCK!",95,100)
	love.graphics.setColor(1, 1, 1, 1)
end

function getGameTime()
	local min = math.floor(gameTime/60)
	local sec = math.floor(gameTime)-math.floor(min*60)
	local text = "00:00"

	if min == 0 then
		if sec<10 then
			text = "00:0"..sec
		else
			text = "00:"..sec
		end
	else if min<10 then
			if sec<10 then
				text = "0"..min..":0"..sec
			else
				text = "0"..min..":"..sec
			end
		else
			if sec<10 then
				text = min..":0"..sec
			else
				text = min..":"..sec
			end
		end
	end

	return text
end
