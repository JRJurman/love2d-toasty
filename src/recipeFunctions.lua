require('recipeDetails')
require('deckFunctions')

discoveredRecipes = {

}

function getTotalDiscoveredRecipes()
	local totalDiscoveredRecipes = 0
	for recipeKey, recipe in pairs(recipeDetails) do
		if discoveredRecipes[recipeKey] then
			totalDiscoveredRecipes = totalDiscoveredRecipes + 1
		end
	end
	return totalDiscoveredRecipes
end

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

function getPotentialRecipeOnPlate(plate)
	-- get ingredients past our initial slices of bread
	local plateIngredients = getPlateIngredients(plate)

	-- if we have no ingredients (or made a sandwich),
	-- don't say what recipes are discoverable
	if #plateIngredients == 0 then
		return {}
	end

	-- iterate through all recipes
	local possibleRecipes = {}
	for recipeKey, recipe in pairs(recipeDetails) do
		-- check if everything on the plate works towards this recipe
		local recipePossible = true
		for ingredientIndex = 1, recipeSize do
			local ingredient = plateIngredients[ingredientIndex]
			if not recipe.ingredients[ingredient] then
				recipePossible = false
			end
		end
		if recipePossible then
			table.insert(possibleRecipes, recipeKey)
		end
	end

	return possibleRecipes
end

function getCompletedRecipeOnPlate(plate)
	local plateIngredients = getPlateIngredients(plate)
	local recipes = getPotentialRecipeOnPlate(plate)
	-- if we have more than one recipe, we have some
	-- duplicate ingredients, so we didn't complete it
	if #recipes ~= 1 then
		return nil
	end

	-- iterate through each ingredient, and make sure that we have one of each
	local selectedRecipe = recipeDetails[recipes[1]]
	for ingredient, _ in pairs(selectedRecipe.ingredients) do
		local countOfIngredientOnPlate = countValueInTopOfPile(plate, #plate, ingredient)
		if countOfIngredientOnPlate ~= 1 then
			return nil
		end
	end

	-- if we didn't return early, it means we have one of every ingredient we needed!
	return recipes[1]
end

function getRecipesForIngredient(ingredient)
	-- build the list of all recipes with this ingredient
	local recipesForIngredient = {}
	for recipeKey, recipe in pairs(recipeDetails) do
		-- check if this recipe has this ingredient
		if recipe.ingredients[ingredient] then
			table.insert(recipesForIngredient, recipeKey)
		end
	end

	return recipesForIngredient
end

function splitDiscoveredAndUndiscoveredRecipes(recipes)
	local discovered = {}
	local undiscovered = {}
	for recipeIndex, recipe in ipairs(recipes) do
		if discoveredRecipes[recipe] then
			table.insert(discovered, recipe)
		else
			table.insert(undiscovered, recipe)
		end
	end

	return discovered, undiscovered
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

	-- if we also made a recipe, add the associated number of points for that
	local recipe = getCompletedRecipeOnPlate(plate)
	if recipe then
		plateScore = plateScore + recipeDetails[recipe].points
	end

	return plateScore
end

function getScoreForPlate(plate)
	local plateScore = getRawScoreForPlate(plate)
	local typeOfPlate = getTypeOfPlate(plate)

	return math.max(plateScore * typeOfPlate, 0)
end
