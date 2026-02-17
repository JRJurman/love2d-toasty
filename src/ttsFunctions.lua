require('ui')
require('cardDetails')
require('recipeFunctions')
require('actionDetails')

function getNavInstructions(selection, navKey)
	local navDirections = ''
	local dirLabel = ''

	local selectedNavDetails = ui[selection].nav[navKey]
	if selectedNavDetails.left then
		dirLabel = ui[selectedNavDetails.left].label
		navDirections = navDirections..'LEFT: '..dirLabel..'\n'
	end
	if selectedNavDetails.right then
		dirLabel = ui[selectedNavDetails.right].label
		navDirections = navDirections..'RIGHT: '..dirLabel..'\n'
	end
	if selectedNavDetails.up then
		dirLabel = ui[selectedNavDetails.up].label
		navDirections = navDirections..'UP: '..dirLabel..'\n'
	end
	if selectedNavDetails.down then
		dirLabel = ui[selectedNavDetails.down].label
		navDirections = navDirections..'DOWN: '..dirLabel..'\n'
	end

	return navDirections
end
