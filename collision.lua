-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function checkBoxCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end

function checkPixelCollision(img1, img2, x1, y1, x2, y2)
	-- get data from images
	local w1 = img1:getWidth()
	local w2 = img2:getWidth()
	local h1 = img1:getHeight()
	local h2 = img2:getHeight()
	local imgData1 = img1:getData()
	local imgData2 = img2:getData()
	
	-- pixels delimiting the test area
	local lowTop = 0
	local highBottom = 0
	local highLeft = 0
	local lowRight = 0
	
	-- max x and y values for the objects
	local xp1 = x1 + (w1 - 1)
	local xp2 = x2 + (w2 - 1)
	local yp1 = y1 + (h1 - 1)
	local yp2 = y2 + (h2 - 1)

	if y1 > y2 then
		lowTop = y1
	else
		lowTop = y2
	end
	
	if x1 > x2 then
		highLeft = x1
	else
		highLeft = x2
	end
	
	if xp1 > xp2 then
		lowRight = xp2
	else
		lowRight = xp1
	end
	
	if yp1 > yp2 then
		highBottom = yp2
	else
		highBottom = yp1
	end
	
	--print("x y xp yp w h")
	--print("img1 " .. tostring(x1) .. ", " .. tostring(y1) .. ", " .. tostring(xp1) .. ", " .. tostring(yp1) .. ", " .. tostring(w1) .. ", " .. tostring(h1))
	--print("img2 " .. tostring(x2) .. ", " .. tostring(y2) .. ", " .. tostring(xp2) .. ", " .. tostring(yp2) .. ", " .. tostring(w2) .. ", " .. tostring(h2))
	--print("lt hl lr hb " .. tostring(lowTop) .. ", " .. tostring(highLeft) .. ", " .. tostring(lowRight) .. ", " .. tostring(highBottom))
	
	-- perform comparison
	for i = round(highLeft), round(lowRight) do
		for j = round(lowTop), round(highBottom) do
			local imgCoords1 = mapGlobalToSpriteCoordinate(round(x1), round(y1), i, j)
			local imgCoords2 = mapGlobalToSpriteCoordinate(round(x2), round(y2), i, j)
			--print("checking px at coords " .. tostring(i) .. ", " .. tostring(j))
			--print("img1 mapped to " .. tostring(imgCoords1.x) .. ", " .. tostring(imgCoords1.y))
			--print("img2 mapped to " .. tostring(imgCoords2.x) .. ", " .. tostring(imgCoords2.y))
			if imgCoords1.x >= 0 and imgCoords1.x < w1 and imgCoords1.y >= 0 and imgCoords1.y < h1
				and imgCoords2.x >= 0 and imgCoords2.x < w2 and imgCoords2.y >= 0 and imgCoords2.y < h2 then
				local r1, g1, b1, a1 = imgData1:getPixel(imgCoords1.x, imgCoords1.y)
				local r2, g2, b2, a2 = imgData2:getPixel(imgCoords2.x, imgCoords2.y)
				--print("alpha: " .. tostring(a1) .. ", " .. tostring(a2))
				if a1 == 255 and a2 == 255 then
					return true
				end
			end
		end
	end
	
	return false
end

function mapGlobalToSpriteCoordinate(spriteX, spriteY, pixelX, pixelY)
	local spriteCoordinates = { x = 0, y = 0 }
	spriteCoordinates.x = pixelX - spriteX
	spriteCoordinates.y = pixelY - spriteY
	
	return spriteCoordinates
end

function round(number)
	if number % 1 > 0.5 then
		return math.ceil(number)
	else
		return math.floor(number)
	end
end
