require('recipeDetails')
require('deckFunctions')
require('plateFunctions')

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
		local countOfIngredientOnPlate = countValueInTopOfPile(plateIngredients, recipeSize, ingredient)
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
