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
	[2] = 'Fat Toast',
	[3] = 'Ultimate Toast',
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

	-- if the first 3 ingredients are bread (and it isn't a sandwich), this is ultimate toast
	if plate[2] == 1 and plate[3] == 1 then
		return 3
	end

	-- if the first 2 ingredients are bread, this is fat toast
	if plate[2] == 1 then
		return 2
	end

	-- otherwise, we just have one slice of bread, normal toast
	return 1
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

	return math.max(plateScore * typeOfPlate, 0)
end
