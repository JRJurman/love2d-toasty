local json = require("json")

function saveGameData(fileName, dataTable)
    -- Convert the Lua table to a JSON string
    local jsonString = json.encode(dataTable)

    love.filesystem.write(fileName, jsonString)

    print(fileName.." saved!")
end

function loadGameData(fileName)
	if love.filesystem.getInfo(fileName) then
		-- Read the file content as a string
		local jsonString = love.filesystem.read(fileName)

		-- Convert the JSON string back into a Lua table
		local dataTable = json.decode(jsonString)

		print(fileName.." loaded!")
		return dataTable
	else
		print(fileName.." not found.")
		return nil
	end
end

function clearGameData(fileName)
	if love.filesystem.getInfo(fileName) then
		love.filesystem.remove(fileName)

		print(fileName.." cleared!")
	else
		print(fileName.." not found.")
		return nil
	end
end
