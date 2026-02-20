require('ui')

function indexToString(index)
	if index == 1 then
		return 'First'
	elseif index == 2 then
		return 'Second'
	elseif index == 3 then
		return 'Third'
	end
	return ''
end

function getNavInstructions(selection, navKey)
	local navDirections = ''
	local dirLabel = ''

	local selectedNavDetails = ui[selection].nav[navKey]
	if selectedNavDetails.selectLabel then
		dirLabel = selectedNavDetails.selectLabel
		navDirections = navDirections..'SELECT: '..dirLabel..'\n'
	end
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
