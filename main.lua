--debug = true

require "collision"
scoreFont = love.graphics.newFont("assets/Pixeled.ttf", 12)
messageFont = love.graphics.newFont("assets/Pixeled.ttf", 16)
backgroundMusic = nil

-- Units
player = { x = 0, y = 0, spawnX = 0, spawnY = 0, speed = 250, image = nil }
zako = { speed = 170, spawnRate = 2, firstSpawnTimer = 2, spawnTimer = 2, spawnCount = 1, value = 1, image = nil, bulletSound = nil }
elite = { speed = 300, spawnRate = 5, firstSpawnTimer = 10, spawnTimer = 10, spawnCount = 2, value = 3, image = nil, bulletSound = nil }
elite2 = { speed = 300, spawnRate = 7, firstSpawnTimer = 28, spawnTimer = 28, spawnCount = 4, value = 3, image = nil, bulletSound = nil }
enemyTypes = {}
enemies = {}

-- Timers
canShoot = true
canShootTimer = 0
reloadTime = 0.5 -- in seconds

maxSpawnInterval = 5 -- in seconds
spawnTimer = maxSpawnInterval

-- Bullets
bulletImage = nil
bulletSound = nil
hitSound = nil
deathSound = nil
bulletSpeed = 800 -- pixels per second
bullets = {}

-- Game State
isAlive = false
score = 0

function love.load(arg)
	bulletImage = love.graphics.newImage("assets/bullet.png")

	player.image = love.graphics.newImage("assets/shiplight.png")
	player.spawnX = (love.graphics.getWidth() / 2) - (player.image:getWidth() / 2)
	player.spawnY = love.graphics.getHeight() - player.image:getHeight() - 10
	player.x = player.spawnX
	player.y = player.spawnY
	
	bulletSound = love.audio.newSource("assets/shot.wav")
	hitSound = love.audio.newSource("assets/hit.wav")
	deathSound = love.audio.newSource("assets/death.wav")
	
	zako.image = love.graphics.newImage("assets/enemy.png")
	zako.bulletSound = love.audio.newSource("assets/enemyshot.wav")
	zako.spawnTimer = zako.firstSpawnTimer
	table.insert(enemyTypes, zako)
	
	elite.image = love.graphics.newImage("assets/elite.png")
	elite.bulletSound = love.audio.newSource("assets/enemyshot.wav")
	elite.spawnTimer = elite.firstSpawnTimer
	table.insert(enemyTypes, elite)
	
	elite2.image = love.graphics.newImage("assets/elite.png")
	elite2.bulletSound = love.audio.newSource("assets/enemyshot.wav")
	elite2.spawnTimer = elite2.firstSpawnTimer
	table.insert(enemyTypes, elite2)
	
	backgroundMusic = love.audio.newSource("assets/bgmusic.wav")
	backgroundMusic:setLooping(true)
	--love.audio.play(backgroundMusic)
	
	love.graphics.setBackgroundColor(0, 0, 50)
end

function love.update(dt)
	-- Timers
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer <= 0 then
		canShoot = true
	end
	
	for i, enemyType in ipairs(enemyTypes) do
		enemyType.spawnTimer = enemyType.spawnTimer - (1 * dt)
	end
	
	-- Collisions
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if checkBoxCollision(enemy.x, enemy.y, enemy.type.image:getWidth(), enemy.type.image:getHeight(),
				bullet.x, bullet.y, bullet.image:getWidth(), bullet.image:getHeight())
				and checkPixelCollision(bulletImage, enemy.type.image, bullet.x, bullet.y, enemy.x, enemy.y) then
				if isAlive then
					score = score + enemy.type.value
				end
				table.remove(bullets, j)
				table.remove(enemies, i)
				love.audio.play(hitSound)
			end
		end
		
		if checkBoxCollision(enemy.x, enemy.y, enemy.type.image:getWidth(), enemy.type.image:getHeight(),
			player.x, player.y, player.image:getWidth(), player.image:getHeight())
			and checkPixelCollision(player.image, enemy.type.image, player.x, player.y, enemy.x, enemy.y)
			and isAlive then
			table.remove(enemies, i)
			isAlive = false
			love.audio.play(deathSound)
			love.audio.stop(backgroundMusic)
		end
	end
	
	-- Bullet movement
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (bulletSpeed * dt)
		
		if bullet.y < 0 - bulletImage:getHeight() then
			table.remove(bullets, i)
		end
	end
	
	-- Enemy movement
	for i, enemy in ipairs(enemies) do
		enemy.y  = enemy.y + (enemy.type.speed * dt)
		
		if enemy.y > love.graphics.getHeight() then
			table.remove(enemies, i)
		end
	end
	
	for i, enemyType in ipairs(enemyTypes) do
		if enemyType.spawnTimer <= 0 then
			enemyType.spawnTimer = enemyType.spawnRate
			
			maxPosition = love.graphics.getWidth() - (enemyType.image:getWidth() * enemyType.spawnCount)
			basePosition = math.random(0, maxPosition) / enemyType.spawnCount
			minSpawnDistance = enemyType.image:getWidth()
			
			for j = 1, enemyType.spawnCount do
				newPosition = basePosition * j
				
				if j % 2 == 0 then
					newPosition = love.graphics.getWidth() - enemyType.image:getWidth() - (basePosition * j / 2)
				end
				
				-- fix simultaneous spawns of the same enemy type overlapping each other
				--if j > 1 and basePosition < minSpawnDistance do
				--	newPosition = basePosition + minSpawnDistance * (j - 1)
				--end
				
				-- fix position adjustment potentially the new spawn out of bounds
				--if newPosition > maxPosition do
				--	newPosition = maxPosition
				--end
				
				newEnemy = { x = newPosition, y = 1 - enemyType.image:getHeight(), type = enemyType }
				
				table.insert(enemies, newEnemy)
			end
		end
	end
	
	-- Keypresses
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	if isAlive then
		if love.keyboard.isDown('left') then
			if player.x > 0 then
				player.x = player.x - (player.speed * dt)
			end
		elseif love.keyboard.isDown('right') then
			if player.x < (love.graphics.getWidth() - player.image:getWidth()) then
				player.x = player.x + (player.speed * dt)
			end
		end
		
		if love.keyboard.isDown('up') then
			if player.y > 0 then
				player.y = player.y - (player.speed * dt)
			end
		elseif love.keyboard.isDown('down') then
			if player.y < (love.graphics.getHeight() - player.image:getHeight()) then
				player.y = player.y + (player.speed * dt)
			end
		end
		
		if love.keyboard.isDown('z') and canShoot then
			newBullet = { x = player.x + (player.image:getWidth() / 2 - bulletImage:getWidth() / 2), y = player.y - bulletImage:getHeight(), image = bulletImage }
			table.insert(bullets, newBullet)
			love.audio.play(bulletSound)
			canShoot = false
			canShootTimer = reloadTime
		end
	else
		if love.keyboard.isDown('r') then
			bullets = {}
			enemies = {}
			
			canShootTimer = reloadTime
			
			for i, enemyType in ipairs(enemyTypes) do
				enemyType.spawnTimer = enemyType.firstSpawnTimer
			end
			
			player.x = player.spawnX
			player.y = player.spawnY
			
			score = 0
			isAlive = true
			
			love.audio.rewind(backgroundMusic)
			love.audio.play(backgroundMusic)
		end
	end
end

function love.draw(dt)
	for i, enemy in ipairs(enemies) do
		love.graphics.draw(enemy.type.image, enemy.x, enemy.y)
	end
	
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.image, bullet.x, bullet.y)
	end
	
	if isAlive then
		love.graphics.draw(player.image, player.x, player.y)
	else
		love.graphics.setFont(messageFont)
		love.graphics.printf("Press R to play", 0, 400, love.graphics.getWidth(), "center")
	end
	
	love.graphics.setFont(scoreFont)
	love.graphics.printf("Score: " .. tostring(score), -16, 20, love.graphics.getWidth(), "right")
end
