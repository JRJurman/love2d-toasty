local fonts = {
	cherrybomb = {}
}

fontDetails = {
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
