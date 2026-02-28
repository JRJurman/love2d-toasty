require('deckFunctions')

function getPlateIngredients(plate)
	-- get ingredients past our initial slices of bread
	local plateIngredients = {}
	local typeOfPlate = getTypeOfPlate(plate)
	-- if we made a sandwich, no recipes are valid, return none
	if typeOfPlate == -1 then
		return {}
	end

	for plateIndex, plateIngredient in ipairs(plate) do
		-- if we are past the recipe size, we shouldn't add more ingredients
		local withinRecipeLimit = #plateIngredients < recipeSize

		-- if this is not bread, and we haven't hit the recipe size, add to our plateIngredients
		if withinRecipeLimit and plateIngredient ~= 1 then
			table.insert(plateIngredients, plateIngredient)
		end
	end

	return plateIngredients
end

typesOfPlates = {
	[-1] = 'Sandwich!' ,
	[0] = 'Not Toast Yet',
	[1] = 'Toast',
	[2] = 'Fat Toast (+8)',
	[3] = 'Ultimate Toast (+12)'
}
function getTypeOfPlate(plate)
	-- if we don't have anything on this plate, this isn't toast yet
	if plate[1] == nil then
		return 0
	end

	-- check if we swap between ingredients and bread (if we do, this is a sandwich)
	local hasIngredients = false
	for plateIndex, ingredient in ipairs(plate) do
		if ingredient ~= 1 then
			hasIngredients = true
		end
		if hasIngredients and ingredient == 1 then
			return -1
		end
	end

	-- if we have less than 5, we have toast
	if #plate < 5 then
		return 1
	end

	-- if we have less than 8 we have fat toast
	if #plate < 8 then
		return 2
	end

	-- otherwise, we have ultimate toast
	return 3
end

function getRawScoreForPlate(plate)
	local plateScore = 0

	for ingredientIndex, ingredient in ipairs(plate) do
		plateScore = plateScore + cardDetails[ingredient].points
	end

	return plateScore
end

function getScoreForPlate(plate)
	local plateScore = getRawScoreForPlate(plate)
	local typeOfPlate = getTypeOfPlate(plate)

	local extraPoints = typeOfPlate * 4
	if typeOfPlate > 1 then
		plateScore = plateScore + extraPoints
	end

	return math.max(plateScore, 0)
end
