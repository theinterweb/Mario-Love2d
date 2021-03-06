local AdvTiledLoader = require("libs/AdvTiledLoader.Loader")

function loadMap()
	-- Load the Mario Map.
	AdvTiledLoader.path = "custom_maps/"
	map = AdvTiledLoader.load("test.tmx")
	map:setDrawRange(0, 0, map.width * map.tileWidth, (map.height) * map.tileHeight)
	camera:setBounds(0, 0, map.width * map.tileWidth - love.graphics.getWidth(), (map.height) * map.tileHeight - love.graphics.getHeight() )
end