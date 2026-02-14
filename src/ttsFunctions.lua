require('ui')
require('cardDetails')
require('recipeFunctions')
require('actionDetails')

function getSelectionInstruction(selection, hand, modalCards, modalActions)
	-- if this is a card, determine if this is a hand or modalCard,
	-- and then return those details
	if ui[selection].card then
		local selectedCard = nil
		if ui[selection].hand then
			selectedCard = hand[ui[selection].handIndex]
		elseif ui[selection].modal then
			selectedCard = modalCards[ui[selection].drawIndex]
		end

		-- if there is no card in this spot, return no details
		if selectedCard == nil then
			return 'No Card;'
		end

		local label = cardDetails[selectedCard].label
		local effect = cardDetails[selectedCard].effect
		local recipes = getRecipesForIngredient(selectedCard)
		local discoveredRecipes, undiscoveredRecipes = splitDiscoveredAndUndiscoveredRecipes(recipes)
		local cardSelectionText = label..'; '..effect..'\n'..#undiscoveredRecipes.. ' undiscovered recipes.'

		return cardSelectionText
	end

	if selection == 'modalAction1' then
		print('first action: '..modalActions[1])
		local selectedAction = actionDetails[modalActions[1]]
		if selectedAction then
			return selectedAction.actionDescription
		end
	end

	return ''
end

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
