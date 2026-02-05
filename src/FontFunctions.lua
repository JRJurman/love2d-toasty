local fonts = {
	dynapuff = {},
	atkinson = {},
	whacky = {},
}

fontDetails = {
	dynapuff = {
		fontSrc = 'Fonts/dynapuff-semibold.ttf',
		fontSizeModifier = 0,
		fontHint = 'normal',
	},
	atkinson = {
		fontSrc = 'Fonts/font-atkinson-bold.ttf',
		fontSizeModifier = 0,
		fontHint = 'normal',
	},
	whacky = {
		fontSrc = 'Fonts/font-whacky-joe.ttf',
		fontSizeModifier = 0,
		fontHint = 'mono',
	}
}

function loadFont(key)
	currentFont = key
	currentFontSrc = fontDetails[key].fontSrc
	fontSizeModifier = fontDetails[key].fontSizeModifier
	fontHint = fontDetails[key].fontHint
end

currentFont = ''
currentFontSrc = ''
fontSizeModifier = 0
fontHint = ''

loadFont('dynapuff')

function swapFont()
	if currentFont == 'dynapuff' then
		loadFont('atkinson')
	else
		loadFont('dynapuff')
	end
end

function buildFont(fontSize)
	local font = love.graphics.newFont(currentFontSrc, fontSize + fontSizeModifier, fontHint)
	fonts[currentFont][fontSize] = font
	return font
end

function getFont(fontSize)
	if not fonts[currentFont][fontSize] then
		buildFont(fontSize)
	end
	return fonts[currentFont][fontSize]
end
