local fonts = {
	atkinson = {},
	cherrybomb = {}
}

fontDetails = {
	atkinson = {
		fontSrc = 'Fonts/atkinson-bold.ttf',
		fontSizeModifier = 0,
		fontHeight = 1,
		fontHint = 'normal',
	},
	cherrybomb = {
		fontSrc = 'Fonts/cherrybomb-regular.ttf',
		fontSizeModifier = 0,
		fontHeight = 0.8,
		fontHint = 'normal',
	}
}

function loadFont(key)
	currentFont = key
	currentFontSrc = fontDetails[key].fontSrc
	fontSizeModifier = fontDetails[key].fontSizeModifier
	fontHint = fontDetails[key].fontHint
	fontHeight = fontDetails[key].fontHeight
end

currentFont = ''
currentFontSrc = ''
fontSizeModifier = 0
fontHint = ''
fontHeight = 1

loadFont('cherrybomb')

function swapFont()
	if currentFont == 'cherrybomb' then
		loadFont('atkinson')
	else
		loadFont('cherrybomb')
	end
end

function buildFont(fontSize)
	local font = love.graphics.newFont(currentFontSrc, fontSize + fontSizeModifier, fontHint)
	font:setLineHeight(fontHeight)
	fonts[currentFont][fontSize] = font
	return font
end

function getFont(fontSize)
	if not fonts[currentFont][fontSize] then
		buildFont(fontSize)
	end
	return fonts[currentFont][fontSize]
end
