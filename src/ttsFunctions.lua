require('ui')

function getNavInstructions(selection, navKey)
	local navDirections = 'Use the following keys to change selection: '
	local dirLabel = ''

	local selectedNavDetails = ui[selection].nav[navKey]
	if selectedNavDetails.up then
		dirLabel = ui[selectedNavDetails.up].label
		navDirections = navDirections..' up, '..dirLabel..'; '
	end
	if selectedNavDetails.down then
		dirLabel = ui[selectedNavDetails.down].label
		navDirections = navDirections..' down, '..dirLabel..'; '
	end
	if selectedNavDetails.left then
		dirLabel = ui[selectedNavDetails.left].label
		navDirections = navDirections..' left, '..dirLabel..'; '
	end
	if selectedNavDetails.right then
		dirLabel = ui[selectedNavDetails.right].label
		navDirections = navDirections..' right, '..dirLabel..'. '
	end

	return navDirections
end
