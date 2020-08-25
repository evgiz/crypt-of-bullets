
function collisionEnemy(x,y)
	for k,v in pairs(enemies) do
		if checkCollision(x+1,y+1,6,6, v.x, v.y, 8, 8) then
			return v
		end
	end

	return nil
end

function collisionEnemyExclude(exclude,x,y)
	for k,v in pairs(enemies) do
		if v ~= exclude then
			if checkCollision(x+1,y+1,6,6, v.x, v.y, 8, 8) then
				return v
			end
		end
	end

	return nil
end

function spaceFree(exclude,x,y)
	for wx=0,29 do
		for wy=0,15 do
			local tile = world.currentRoom.tiles[wx][wy]
			if tile==1 or tile==2 then
				if checkCollision(wx*8,wy*8+8,8,8, x+1, y+1, 6, 6) then
					return false
				end
			end
		end
	end

	if(hitDestructible(x,y)) then
		return false
	end

	return true
end

function spaceFreeWorld(x,y)
	for wx=0,29 do
		for wy=0,15 do
			local tile = world.currentRoom.tiles[wx][wy]
			if tile==1 or tile==2 then
				if checkCollision(wx*8,wy*8+8,8,8, x+1, y+1, 6, 6) then
					return false
				end
			end
		end
	end

	return true
end

function hitDestructible(x,y)
	for k,v in pairs(world.currentRoom.entities) do
		if instanceOf(v, Destructible) then
			if checkCollision(x,y,8,8, v.x+1, v.y+1, 6, 6) then
				return v
			end
		end
	end

	return nil
end

function entityCollision(x,y)
	for k,v in pairs(world.currentRoom.entities) do
		if checkCollision(x+1,y+1,6,6, v.x, v.y, 8, 8) then
			return v
		end
	end

	return nil
end

function instanceOf (subject, super)
	super = tostring(super)
	local mt = getmetatable(subject)

	while true do
		if mt == nil then return false end
		if tostring(mt) == super then return true end

		mt = getmetatable(mt)
	end
end


function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
