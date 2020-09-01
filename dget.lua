baseUrl = 'https://raw.githubusercontent.com/de5933/MinecraftLuaScripts/master/'

-- Adapted from wget.lua in ComputerCraft (https://github.com/dan200/ComputerCraft)

local function printUsage()
	print( "Usage:" )
	print( "dget <filename>" )
end

local tArgs = { ... }
if #tArgs < 1 then
	printUsage()
	return
end

if not http then
	printError( "dget requires http API" )
	printError( "Set http_enable to true in ComputerCraft.cfg" )
	return
end

local function get( sUrl )
	write( "Connecting to " .. sUrl .. "... " )

	local ok, err = http.checkURL( sUrl )
	if not ok then
			print( "Failed." )
			if err then
					printError( err )
			end
			return nil
	end

	local response = http.get( sUrl , nil , true )
	if not response then
			print( "Failed." )
			return nil
	end

	print( "Success!" )

	local sResponse = response.readAll()
	response.close()
	return sResponse
end

-- Determine file to download
local sFile = tArgs[1]
local sUrl = baseUrl .. '/' .. sFile
local sPath = shell.resolve( sFile )

-- Do the get
local res = get( sUrl )
if res then
	local file = fs.open( sPath, "w" )
	file.write( res )
	file.close()

	print( "Downloaded "..sFile )
end
