require('classlib')

function love.load()

    tile = love.graphics.newImage("images/grass.bmp")
	char = love.graphics.newImage("images/man.png")
	enemy = love.graphics.newImage("images/enemy.png")
	zombie = love.graphics.newImage("images/zombies2.png")
	
	love.graphics.setMode(tile:getWidth()*4, tile:getHeight()*3, false, true, 2)	
	world = love.physics.newWorld(0,0,tile:getWidth()*4,tile:getHeight()*3)

	--start position of character
	xChar = 250
	yChar = 500
	
	xEnemy1, xEnemyBody1 = (love.graphics.getWidth()/2)-250
	yEnemy1, yEnemyBody1 = 50

	enemyBody1 = love.physics.newBody(world,xEnemyBody1,yEnemyBody1)
	enemyShape1 = love.physics.newRectangleShape(enemyBody1,0,0,28,48)
	
	xEnemy2, xEnemyBody2 = love.graphics.getWidth()/2
	yEnemy2, yEnemyBody2 = 50

	enemyBody2 = love.physics.newBody(world,xEnemyBody2,yEnemyBody2)
	enemyShape2 = love.physics.newRectangleShape(enemyBody2,0,0,28,48)

	xEnemy3 = (love.graphics.getWidth()/2)+250
	yEnemy3 = 50

	zombies = {}
	for i=0,2 do
		zombies[i] = Zombie(0,0)
	end

	xCharOffset = 0
	yCharOffset = 0

	sTime = love.timer.getTime()
	charSTime = love.timer.getTime()
	cRedTime = 0
	pace = false

	enemyCollide1=false
	enemyCollide2=false
	enemyCollide3=false

	red = false
	dead = false
	amountOfRed = 0
end

function love.draw()

	yTile = love.graphics.getHeight()/tile:getHeight()
	xTile = love.graphics.getWidth()/tile:getWidth()	
	--here to remove blending and set to default
	love.graphics.reset()
	
	for i=0,yTile-1 do
		for j=0,xTile-1 do
    		love.graphics.draw(tile, j*tile:getWidth(), i*tile:getHeight())
		end
	end
	
	zombieQuad1 = love.graphics.newQuad(zombies[0].xOffset, zombies[0].yOffset, 28, 48, 278, 148)
	zombieQuad2 = love.graphics.newQuad(zombies[1].xOffset, zombies[1].yOffset, 28, 48, 278, 148)
	zombieQuad3 = love.graphics.newQuad(zombies[2].xOffset, zombies[2].yOffset, 28, 48, 278, 148)

	charQuad = love.graphics.newQuad(xCharOffset, yCharOffset, 35, 75, 319, 319)

	love.graphics.setBlendMode("alpha")
	love.graphics.drawq(char, charQuad, xChar, yChar, 0, 1.2, 1.2)
	love.graphics.setBlendMode("additive")
	love.graphics.drawq(zombie, zombieQuad1, xEnemy1, yEnemy1, 0, 2, 2)
	love.graphics.drawq(zombie, zombieQuad2, xEnemy2, yEnemy2, 0, 2, 2)
	love.graphics.drawq(zombie, zombieQuad3, xEnemy3, yEnemy3, 0, 2, 2)

	love.graphics.setBlendMode("alpha")
	
	if red == true then
		love.graphics.setColor(255,0,0,amountOfRed)
		love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())
	end

	if dead == true then
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("You're dead.",love.graphics.getWidth()/3,love.graphics.getHeight()/3,0,4,4)
	end

end

function love.update(dt)

	--slowly increase amount of red onscreen
	if red==true and dead==false then
		amountOfRed = amountOfRed + 1
		if amountOfRed > 250 then
			red=false
			dead=true
		end
	end

	if enemyCollide1==true and enemyCollide2==true and enemyCollide3==true then
		if yChar < ((yEnemy1+yEnemy2+yEnemy3)/3) then
			yEnemy1 = yEnemy1 - 1
			yEnemy2 = yEnemy2 - 1
			yEnemy3 = yEnemy3 - 1
		else
			yEnemy1 = yEnemy1 + 1
			yEnemy2 = yEnemy2 + 1
			yEnemy3 = yEnemy3 + 1
		end

		enemyCollide1=false
		enemyCollide2=false
		enemyCollide3=false
	end

	cTime = love.timer.getTime()

	if cTime - sTime >= 0.5 then
		if pace == false then
			zombies[0].yOffset = zombies[0].yOffset + 48
			zombies[1].yOffset = zombies[1].yOffset + 48
			zombies[2].yOffset = zombies[2].yOffset + 48
			if zombies[0].yOffset >= 48 then
				zombies[0].yOffset=48
				zombies[1].yOffset=48
				zombies[2].yOffset=48
			end
			pace = true
			sTime = cTime
		elseif pace == true then
			zombies[0].yOffset = zombies[0].yOffset - 48
			zombies[1].yOffset = zombies[1].yOffset - 48
			zombies[2].yOffset = zombies[2].yOffset - 48
			if zombies[0].yOffset <= 0 then
				zombies[0].yOffset=0
				zombies[1].yOffset=0
				zombies[2].yOffset=0
			end
			pace = false
			sTime = cTime
		end
	end

	oldX1,oldY1 = xEnemy1,yEnemy1

	xEnemy1New, yEnemy1New = moveEnemy(oldX1, oldY1)	 
	
	if CheckCollision(xEnemy1New,yEnemy1New,42,72,xEnemy2,yEnemy2,42,72) then
  		enemyCollide1=true
	else
		if CheckCollision(xEnemy1New,yEnemy1New,42,72,xEnemy3,yEnemy3,42,72) then
			enemyCollide1=true
		else
			xEnemy1=xEnemy1New
			yEnemy1=yEnemy1New
		end
	end

	xEnemyBody1,yEnemyBody1 = xEnemy1,yEnemy1

	if yChar < yEnemy1 then
			zombies[0].xOffset = 100
	end
	if yChar >= yEnemy1 then
			zombies[0].xOffset = 0
	end

	xEnemy2New, yEnemy2New = moveEnemy(xEnemy2, yEnemy2)

	if CheckCollision(xEnemy2New,yEnemy2New,42,72,xEnemy1,yEnemy1,42,72) then
    	enemyCollide2=true
	else
        if CheckCollision(xEnemy2New,yEnemy2New,42,72,xEnemy3,yEnemy3,42,72) then
        enemyCollide2=true
		else
            xEnemy2=xEnemy2New
            yEnemy2=yEnemy2New
		end
    end

	if yChar < yEnemy2 then
			zombies[1].xOffset = 100
	end
	if yChar >= yEnemy2 then
			zombies[1].xOffset = 0
	end

	xEnemy3New, yEnemy3New = moveEnemy(xEnemy3, yEnemy3)

	if CheckCollision(xEnemy3New,yEnemy3New,42,72,xEnemy1,yEnemy1,42,72) then
    	enemyCollide3 = true
	else
        if CheckCollision(xEnemy3New,yEnemy3New,42,72,xEnemy2,yEnemy2,42,72) then
        	enemyCollide3 = true
		else
            xEnemy3=xEnemy3New
            yEnemy3=yEnemy3New
		end
    end	

	if yChar <  yEnemy3 then
		zombies[2].xOffset = 100
	end
	if yChar >= yEnemy3 then
		zombies[2].xOffset = 0
	end

	if CheckCollision(xEnemy3New,yEnemy3New,42,72,xChar,yChar,39,79) then
		red = true
	end
	if CheckCollision(xEnemy2New,yEnemy2New,42,72,xChar,yChar,39,79) then
		red = true
	end
	if CheckCollision(xEnemy1New,yEnemy1New,42,72,xChar,yChar,39,79) then
		red = true
	end
	if not red then
	if love.keyboard.isDown("up") then
		yChar = yChar - 2.5
		xCharOffset = 0
		charCTime = love.timer.getTime()
		if charCTime - charSTime >= 0.25 then
			if yCharOffset + 79 >= 310 then
				yCharOffset = 0
			else
				yCharOffset = yCharOffset + 79.75
			end
			charSTime = charCTime
		end
		if yChar < 0 then
			yChar = 0
		end
	end
	

	
	if love.keyboard.isDown("down") then
		yChar = yChar + 2.5
		xCharOffset = 161
		charCTime = love.timer.getTime()
         if charCTime - charSTime >= 0.25 then
             if yCharOffset + 79 >= 310 then
                 yCharOffset = 0
             else
                 yCharOffset = yCharOffset + 79.75
             end
             charSTime = charCTime
         end

		if yChar > love.graphics.getHeight() - (75*1.2) then
			yChar = love.graphics.getHeight() - (75*1.2)
		end	
	end

	if love.keyboard.isDown("left") then
		xChar = xChar - 2.5
		xCharOffset = 240
		charCTime = love.timer.getTime()
         if charCTime - charSTime >= 0.25 then
             if yCharOffset + 79 >= 310 then
                 yCharOffset = 0
             else
                 yCharOffset = yCharOffset + 79.75
             end
             charSTime = charCTime
         end

		if xChar < 0 then
			xChar = 0
		end
	end
	
	if love.keyboard.isDown("right") then
		xChar = xChar + 2.5
		xCharOffset = 80
		charCTime = love.timer.getTime()
         if charCTime - charSTime >= 0.25 then
             if yCharOffset + 79 >= 310 then
                 yCharOffset = 0
             else
                 yCharOffset = yCharOffset + 79.75
             end
             charSTime = charCTime
         end

		if xChar > love.graphics.getWidth() - (35*1.2) then
			xChar = love.graphics.getWidth() - (35*1.2)
		end
	end
	end
		
	if love.keyboard.isDown("r") then
		love.load()
	end
	
	if love.keyboard.isDown("q") then
		os.exit()
	end
end

function moveEnemy(enemyX, enemyY)

	xEnemyMV = xChar - enemyX
    yEnemyMV = yChar - enemyY
  
    distance = math.sqrt(xEnemyMV^2 + yEnemyMV^2)
 
    xUnitVector = (xEnemyMV/distance)
    yUnitVector = (yEnemyMV/distance)
  
    xMovementVector = xUnitVector * 1.5
    yMovementVector = yUnitVector * 1.5
  
    X = enemyX + xMovementVector
 	Y = enemyY + yMovementVector

	return X, Y
end

function CheckCollision(box1x, box1y, box1w, box1h, box2x, box2y, box2w, box2h)
    if box1x > box2x + box2w - 1 or -- Is box1 on the right side of box2?
       box1y > box2y + box2h - 1 or -- Is box1 under box2?
       box2x > box1x + box1w - 1 or -- Is box2 on the right side of box1?
       box2y > box1y + box1h - 1    -- Is b2 under b1?
    then
        return false                -- No collision
    else
        return true                 -- Yes collision
    end
end

Zombie = class()

function Zombie:__init(xOffset,yOffset,x,y)
	self.xOffset = xOffset
	self.yOffset = yOffset
	self.x = x
	self.y = y
end
