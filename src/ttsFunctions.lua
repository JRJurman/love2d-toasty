require('ui')

function getNavInstructions(selection, navKey)
	local navDirections = ''
	local dirLabel = ''

	local selectedNavDetails = ui[selection].nav[navKey]
	if selectedNavDetails.up then
		dirLabel = ui[selectedNavDetails.up].label
		navDirections = navDirections..'UP: '..dirLabel..'; '
	end
	if selectedNavDetails.down then
		dirLabel = ui[selectedNavDetails.down].label
		navDirections = navDirections..'DOWN: '..dirLabel..'; '
	end
	if selectedNavDetails.left then
		dirLabel = ui[selectedNavDetails.left].label
		navDirections = navDirections..'LEFT: '..dirLabel..'; '
	end
	if selectedNavDetails.right then
		dirLabel = ui[selectedNavDetails.right].label
		navDirections = navDirections..'RIGHT: '..dirLabel..'. '
	end

	return navDirections
end
