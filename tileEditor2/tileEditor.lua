require ("boundary")

tileSet = love.graphics.newImage("spriteBatch.png");
tilesY = 0


function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end


function readMapFile(name, size, layerMap, layerNum)
	data = love.filesystem.read( "custom_maps/" .. name, size )
	-- for i = 0, math.floor(string.len(data)/2)-1, 1 do
	-- 	layerMap[layerNum][i+1] = tonumber(string.sub(data,i*2 + 1,i*2 + 1))
	-- 	print(tonumber(string.sub(data,i*2 + 1,i*2 + 1)))
	-- end
	t = data:split(",")
	for i = 1, #t, 1 do
		layerMap[layerNum][i] = tonumber(t[i])
	end

	print("MAPSIZE = " .. #layerMap[layerNum])
end

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

function contains(t, k)
	for i = 1, #t, 1 do
		if t[i] == k then
			return {true, k}
		end
	end
	return {false, -1}
end

function injectLayer(ids, tbl, layerTbl, layerNum)

	for i = 1, #tbl+1, 1 do
		for j = 1, #tbl[i-1]+1, 1 do -- minus i and 1 to set back to zero while not getting out of bounds error
			if contains(ids, tbl[i-1][j-1])[1] then
				layerTbl[layerNum] [j + (#tbl[i-1]+1) * (i-1)] = contains(ids, tbl[i-1][j-1])[2]
			elseif tbl[i-1][j-1] == nil then
				print ("NILL ".. j .. " " .. i)
			else
				layerTbl[layerNum] [j + (#tbl[i-1]+1) * (i-1)] = 0
			end
		end
	end 

end

--need to read the file first you dont need to overlay any layers because when you make a map you never overlay a tile
function mergeLayers(tbl, layerTbl)
	for i = 1, #layerTbl, 1 do 
		for j = 1, #layerTbl[i], 1 do
			tbl[i][j] = layerTbl[i][j]
		end
	end
end

function updateSize()
	bottomWidth = (((tileSet:getHeight()/32) * tileSet:getWidth()) %love.graphics.getWidth());  
	tilesX = 0; -- tiles boundaryx 
	tilesY = (math.floor((love.graphics.getHeight() - (math.floor(((tileSet:getWidth()*tileSet:getHeight())/(32*32))/(love.graphics.getWidth()/32))*32))/32
		)*32) - math.ceil((bottomWidth) / (bottomWidth+1)) * 32 -- tiles boundaryy
end

function loadTileEditor(mapFile)

	love.graphics.setBackgroundColor(255,255,255);
	tileQuads = {};
	layerMap = {{}};
	bottomWidth = (((tileSet:getHeight()/32) * tileSet:getWidth()) %love.graphics.getWidth());  
	tilesX = 0; -- tiles boundaryx 
	tilesY = (math.floor((love.graphics.getHeight() - (math.floor(((tileSet:getWidth()*tileSet:getHeight())/(32*32))/(love.graphics.getWidth()/32))*32))/32
		)*32) - math.ceil((bottomWidth) / (bottomWidth+1)) * 32 -- tiles boundaryy
	tilesMin = 0;
	tileD = 32;
	boxWidth = 0;
	if(tileSet:getWidth()*(tileSet:getHeight()/32) % love.graphics.getWidth() == tileSet:getWidth()) then
		boxWidth = tileSet:getWidth();
	else
		boxWidth = love.graphics.getWidth();
	end
	boxHeight = math.ceil(((love.graphics.getHeight() - tilesY))/32)*32;
	tileMap = {};
	tx = 0;
	ty = 0;
	-- putting if outside for effeciency, every frame counts!
	data = love.filesystem.read( "custom_maps/" .. mapFile, love.filesystem.getSize(mapFile), layerMap, 1)
	if  data ~= "" then
		readMapFile(mapFile, love.filesystem.getSize(mapFile), layerMap, 1)
	 	for i = 0, math.floor(love.graphics.getHeight()/32)-1, 1 do
			tileMap[i] = {};
			for j = 0, math.floor(love.graphics.getWidth()/32)-1, 1 do
				tileMap[i][j] = layerMap[1][(j+ 1) + math.floor(love.graphics.getWidth()/32) * i];
				-- tileMap[i][j] = 0;
				-- print(layerMap[1][j + #tileMap[i]*(i)]);
			end
		end
	else
		for i = 0, math.floor(love.graphics.getHeight()/32)-1, 1 do
			tileMap[i] = {};
			for j = 0, math.floor(love.graphics.getWidth()/32)-1, 1 do
				tileMap[i][j] = 0;
				-- print("zero" .. tileMap[i][j] .. k)
			end
		end
	end
	
	for y = 0, (tileSet:getHeight()/32)-1, 1 do
		for x = 0, (tileSet:getWidth()/32)-1, 1 do 
			tileQuads[#tileQuads+1] = love.graphics.newQuad(x * 32, y * 32, 32, 32, tileSet:getWidth(), tileSet:getHeight());
		end
	end
	spriteBatch = love.graphics.newSpriteBatch(tileSet, love.graphics.getHeight() * love.graphics.getWidth());
end

function getMap( )
	return layerMap;

end

function updateMap() 
	spriteBatch:clear();
	for i = 0, #tileMap, 1 do 
		for j = 0, #tileMap[i] do 
			if tileMap[i][j] ~= 0 then
				spriteBatch:add(tileQuads[tileMap[i][j]],j*32,i*32);
			end
		end
	end
	spriteBatch:flush();
end

function isTileItemColliding()
	return isTouching(tilesMin, tilesY, boxWidth, boxHeight, bottomWidth);
end 


function drawTileEditor()
	love.graphics.setColor(0,0,0);
	-----MAP GRID
	for i = 0, math.floor(love.graphics.getHeight()/32), 1 do
		love.graphics.line(0, i*32, love.graphics.getWidth(), i*32);
	end 

	for i = 0, math.floor(love.graphics.getWidth()/32), 1 do
		love.graphics.line(i*32, 0, i*32, love.graphics.getHeight());
	end 
	-----END OF MAP GRID
	-- love.graphics.print("mousex: " .. tostring(love.mouse.getX()/32), 0, love.graphics.getHeight() - 20);
	love.graphics.print("mousey: " .. tostring(love.mouse.getY()/32), 200);
	love.graphics.print("isTouching ".. tostring(isTouching(tilesMin, tilesY, boxWidth, boxHeight, bottomWidth)), 32);
-- math.floor(((tileSet:getWidth()*tileSet:getHeight())/(32*32))/(love.graphics.getWidth()/32))
	love.graphics.setColor(255,255,255);
	for y = 0, math.floor(((tileSet:getWidth()*tileSet:getHeight())/(32*32))/(love.graphics.getWidth()/32)), 1 do --clean up with modoulus
		for i = 1, #tileQuads - y * love.graphics.getWidth()/32, 1 do
			if i <= 25 then
				tilesX = ((i-1)*32);
				tileMap[(tilesY+y*32)/32][tilesX/32] = i + (y*(love.graphics.getWidth()/32));
			end
		end
	end

	-- (y*(love.graphics.getWidth()/32));
	updateMap()
	love.graphics.draw(spriteBatch);
	isGrabbing(tilesMin, tilesY, boxWidth, boxHeight,tileD, tileQuads, tileSet,tileMap);
end