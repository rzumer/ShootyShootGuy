debug = true

-- Units
player = { x = 200, y = 710, speed = 150, image = nil }
--enemyImage = nil

-- Timers
canShoot = true
canShootTimer = 0
reloadTime = 0.3 -- in seconds

-- Bullets
bulletImage = nil
bulletSound = nil
bulletSpeed = 250 -- pixels per second
bullets = {}

-- Enemies
zako = { speed = 50, image = nil, bulletSound = nil }

function love.load(arg)
	player.image = love.graphics.newImage("assets/shiplight.png")
	--enemyImage = love.graphics.newImage("assets/enemy.png")
	bulletImage = love.graphics.newImage("assets/bullet.png")
	bulletSound = love.audio.newSource("assets/shot.wav")
	
	zako.image = love.graphics.newImage("assets/enemy.png")
	zako.bulletSound = love.audio.newSource("assets/enemyshot.wav")
	
	love.graphics.setBackgroundColor(0, 0, 50)
end

function love.update(dt)
	-- Timers
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer <= 0 then
		canShoot = true
	end
	
	-- Bullet movement
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (bulletSpeed * dt)
		
		if bullet.y < 0 then
			table.remove(bullets, i)
		end
	end
	
	-- Keypresses
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
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
end

function love.draw(dt)
	love.graphics.draw(player.image, player.x, player.y)
	
	for i, bullet in ipairs(bullets) do
		love.graphics.draw(bullet.image, bullet.x, bullet.y)
	end
end
