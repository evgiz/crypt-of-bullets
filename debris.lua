

function drawDebrisPalette(img, x,y)
	love.graphics.setCanvas(world.currentRoom.canvas)
	love.graphics.setColor(palette.r, palette.g, palette.b, 255)
	love.graphics.draw(img,math.floor(x+.5)+.3,math.floor(y+.5)+.3)
	love.graphics.setCanvas(can)
	love.graphics.setColor(255, 255, 255, 255)
end

function drawDebris(img, x,y)
	love.graphics.setCanvas(world.currentRoom.canvas)
	love.graphics.draw(img,math.floor(x+.5)+.3,math.floor(y+.5)+.3)
	love.graphics.setCanvas(can)
end

function drawDebris(img, x,y, r, sx,sy,ox,oy)
	love.graphics.setCanvas(world.currentRoom.canvas)
	love.graphics.draw(img,math.floor(x+.5)+.3,math.floor(y+.5)+.3,r,sx,sy,ox,oy)
	love.graphics.setCanvas(can)
end
