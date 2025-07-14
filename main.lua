-- Define the window's properties
-- Returns TRUE on success and FALSE on... not success.
local function defineWindow(flags)
	local width, height = 1280, 720
	return love.window.setMode(width, height, flags)
end

-- Define and return a table of the characters in assets.
local function getCharacters()
	local artPath = "assets/art/"
	local charPaths = {
		artPath .. "MC_Default.png",
		artPath .. "MC_Shocked.png",
		artPath .. "MC_Happy.png",
		artPath .. "MC_Sad.png",
		artPath .. "MC_Concerned.png",
		artPath .. "MC_Fear.png",
	}
	local characters = {}
	for i, path in ipairs(charPaths) do
		characters[i] = love.graphics.newImage(path)
	end
	return characters
end



-- Define and return a table of the backgrounds in assets.
local function getBackgrounds()
	local artPath = "assets/art/"
	local backPaths = {
		artPath .. "Background_Main.png",
		artPath .. "Background_Variation_1.png",
		artPath .. "Background_Variation_2.png",
	}
	local backgrounds = {}
	for i, path in ipairs(backPaths) do
		backgrounds[i] = love.graphics.newImage(path)
	end
	return backgrounds
end

-- Define and return a table of theme mp3s in music.
local function getThemes()
	local themePath = "assets/music/"
	local thmPaths = {
		themePath .. "Theme.mp3",
		themePath .. "Theme_Variation_1.mp3",
		themePath .. "Theme_Variation_2.mp3",
		themePath .. "empty.mp3",
	}
	local themes = {}
	for i, path in ipairs(thmPaths) do
		themes[i] = love.audio.newSource(path, "static")
	end
	return themes
end

-- Count the number of dialouge texts there are in the story.
local function countTexts(lines)
	local i = 0
	for l, line in ipairs(lines) do
		if line.type == '"' then
			i = i + 1
		end
	end
	return i
end

-- Parse the story.txt file into seperate lines.
local function parseText()
	local file = io.open("assets/story.txt", "r")
	local text = {}
	if file then
		for line in file:lines() do
			local tline = {}
			tline.str = string.sub(line, 2, -1)
			tline.type = string.sub(line, 1, 1)
			table.insert(text, tline)
		end
	end

	return text
end

local function parseCommand(command)
	command = string.lower(command)
	if command == "mc_default" then
		CUR_CHAR = Characters[1]
	elseif command == "mc_shocked" then
		CUR_CHAR = Characters[2]
	elseif command == "mc_happy" then
		CUR_CHAR = Characters[3]
	elseif command == "mc_sad" then
		CUR_CHAR = Characters[4]
	elseif command == "mc_concerned" then
		CUR_CHAR = Characters[5]
	elseif command == "mc_fear" then
		CUR_CHAR = Characters[6]
	elseif command == "background_1" then
		CUR_BACKGROUND = Backgrounds[1]
	elseif command == "background_2" then
		CUR_BACKGROUND = Backgrounds[2]
	elseif command == "background_3" then
		CUR_BACKGROUND = Backgrounds[3]
	elseif command == "music_1" then
		CUR_THEME = Themes[1]
		love.audio.stop()
	elseif command == "music_2" then
		CUR_THEME = Themes[2]
		love.audio.stop()
	elseif command == "music_3" then
		CUR_THEME = Themes[3]
		love.audio.stop()
	elseif command == "music_None" then
		CUR_THEME = Themes[4]
		love.audio.stop()
	elseif command == "zoom" then
	elseif command == "unzoom" then
	elseif command == "shake" then
	else
		print("Messed up command :(")
	end
end

local function setDialogue(d)
	print(d)
	CUR_DIALOGUE = d
	CUR_DIALINE = CUR_DIALINE + 1
end

local function moveOnLine()
	if TEXT[CUR_LINE] == nil then
		love.event.quit()
	end
	while TEXT[CUR_LINE].type == "*" do
		print("*")
		local command = TEXT[CUR_LINE].str
		parseCommand(command)
		CUR_LINE = CUR_LINE + 1
	end
	local dialogue = TEXT[CUR_LINE].str
	setDialogue(dialogue)
	CUR_LINE = CUR_LINE + 1
end

-- Runs on first load of the window
function love.load()
	local windowFlags = {}
	windowFlags.borderless = true
	windowFlags.centered = true
	windowFlags.resizable = false
	windowFlags.fullscreen = false
	if not (defineWindow(windowFlags)) then
		os.exit(1)
	end

	Backgrounds = getBackgrounds()
	Characters = getCharacters()
	Themes = getThemes()

	CUR_LINE = 1
	CUR_DIALINE = 0
	CUR_CHAR = Characters[1]
	CUR_BACKGROUND = Backgrounds[1]
	CUR_THEME = Themes[4]
	CUR_DIALOGUE = ""
	TEXT = parseText()
	FONT = love.graphics.newFont("assets/CaskaydiaCoveNerdFont-Bold.ttf", 30)
	NUM_DIALINES = countTexts(TEXT)

	love.audio.play(CUR_THEME)
end

-- Updates every frame, before drawing graphics.
function love.update(dt)
	if love.audio.getActiveSourceCount() ~= 1 then
		love.audio.stop()
		love.audio.play(CUR_THEME)
	end
end

-- Handling keyboard input
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	if key == "space" then
		moveOnLine()
	end
end

-- Updates every frame, after love.update().
function love.draw()
	love.graphics.draw(CUR_BACKGROUND, 0, 0)
	love.graphics.draw(CUR_CHAR, 430, 0)
	love.graphics.setColor(1, 1, 1, 0.75)
	love.graphics.rectangle("fill", 140, 420, 1000, 300)
	love.graphics.setColor(0.5, 0.5, 0.5, 1)
	love.graphics.printf(CUR_DIALOGUE, FONT, 200, 480, 880, "left")
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.print(CUR_DIALINE .. " / " .. NUM_DIALINES, FONT, 10, 10)
	love.graphics.setColor(1, 1, 1, 1)
end
