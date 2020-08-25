require "room"

World = {
	level = 0,
	startx=0,
	starty=0,
	currentx=0,
	currenty=0,
	exitx=0,
	exity=0,
	layout = {},
	rooms = {}
}

local nextLevelAudio = love.audio.newSource("audio/stairs.wav","static")

function World:new()
	o = {}
	setmetatable(o, self)
	self.__index = self

	return o
end

function World:nextLevel()
	self.level = self.level+1
	self.startx = 0
	self.starty=0
	self.exitx = 0
	self.exity=0
	self.currentx=0
	self.currenty=0
	self.layout = {}
	self.rooms = {}
	self:generate()

	player.x = 240/2
	player.y = 136/2

	nextLevelAudio:play()
	love.timer.sleep(1/5)

	score = score+self.level*30
	message = "SCORE +"..self.level*30
	messageTime = 2
end

function World:generate()
	self:generateLayout(self.level)
	self:generateRooms()
	self.currentx = self.startx
	self.currenty = self.starty

	self.currentRoom.cleared = true

	--Set exit, TODO make exit distance away from entrance
	local exit = false
	local x,y
	local tries=0

	while exit == false do
		tries = tries+1
		x = love.math.random(1, 9)
		y = love.math.random(1, 9)

		if x~=self.startx or y~=self.starty then
			if self.rooms[x][y]~=nil then
				exit = self.rooms[x][y]:makeExit()
				if exit then self.rooms[x][y].isExit = true end
			end
		end
		
		-- Should not happen :/
		if tries > 1000 then break end
	end

end

local doorSound = love.audio.newSource("audio/door.wav", "static")
function World:move(dx,dy)
	self.currentx = self.currentx+dx
	self.currenty = self.currenty+dy
	self.currentRoom = self.rooms[self.currentx][self.currenty]
	if self.currentRoom.visited == false then
		self.currentRoom:generateMonsters(self.level)
		self.currentRoom:updateDoors()
		self.currentRoom.visited = true

		if tablelength(enemies) == 0 then
			self.currentRoom.cleared = true
		end
	end

	doorSound:play()
end

function World:generateRooms()
	for x=0,10 do
		self.rooms[x] = {}
		for y=0,10 do
			self.rooms[x][y]=nil
			if self.layout[x][y] > 0 then
				local top = (self.layout[x][y-1]>0)
				local bottom = (self.layout[x][y+1]>0)
				local left = (self.layout[x-1][y]>0)
				local right = (self.layout[x+1][y]>0)

				if x==self.startx and y==self.starty then
					self.rooms[x][y] = Room:new(top, bottom, left, right)
					self.rooms[x][y]:load("default")
					self.currentRoom = self.rooms[x][y]
					self.currentRoom.visited = true
				elseif love.math.random(0,10)==0 then
					self.rooms[x][y] = Room:new(top, bottom, left, right)
					self.rooms[x][y]:load("power_room")
				else
					self.rooms[x][y] = Room:new(top, bottom, left, right)
					self.rooms[x][y]:load("random")
				end
			else
				self.rooms[x][y]=nil
			end
		end
	end
end

--Layout:
	-- 0 = no room
	-- 1 = normal room
	-- 2 = start room
	-- 3 = end room
function World:generateLayout(level)
	--10x10 rooms at maximum
	for x=0,10 do
		self.layout[x] = {}
		for y=0,10 do
			self.layout[x][y]=0
		end
	end

	local roomCount = math.min(30, level*2 + 6)
	self.startx = love.math.random(1, 9)
	self.starty = love.math.random(1, 9)

	self.layout[self.startx][self.starty] = 2

	local rx,ry
	while roomCount>0 do
		rx = love.math.random(1,9)
		ry = love.math.random(1,9)

		if self.layout[rx][ry] == 0 then
			if self.layout[rx-1][ry]>0 or self.layout[rx+1][ry]>0
				or self.layout[rx][ry-1]>0 or self.layout[rx][ry+1]>0 then

				self.layout[rx][ry] = 1
				roomCount = roomCount - 1
			end
		end

	end
end

function World:drawMap()

	if love.keyboard.isDown("tab") == false then
		return
	end

	local scale = 6
	local xpos = (240-scale*10)/2
	local ypos = (136-scale*10)/2

	love.graphics.setColor(50/255, 50/255, 50/255, 1)
	love.graphics.rectangle("fill", xpos-5,ypos-15,scale*11+9,scale*11+20)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("LEVEL MAP",240/2-24, 23)

	for x=0,10 do
		for y=0,10 do
			if self.layout[x][y]==0 or world.rooms[x][y].visited == false then
				love.graphics.setColor(70/255, 70/255, 70/255, 1)
				love.graphics.rectangle("fill",xpos+x*scale,ypos+ y*scale, scale-1, scale-1)
			elseif world.rooms[x][y].visited == false then

			elseif world.rooms[x][y].isExit then
				love.graphics.setColor(0, 1, 0, 255)
				love.graphics.rectangle("fill", xpos+x*scale,ypos+ y*scale, scale-1, scale-1)
			elseif self.layout[x][y]>0 then
				love.graphics.setColor(155/255, 155/255, 155/255, 1)
				love.graphics.rectangle("fill", xpos+x*scale,ypos+y*scale, scale-1, scale-1)
			end

			--Red dot on current room
			if x==world.currentx and y==world.currenty then
				love.graphics.setColor(1, 0, 0, 1)
				love.graphics.rectangle("fill", xpos+x*scale+1,ypos+y*scale+1, 3,3)
			end
			love.graphics.origin()
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
end
