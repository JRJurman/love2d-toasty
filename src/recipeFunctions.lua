require('recipeDetails')

discoveredRecipes = {

}

function getPlateIngredients(plate)
	-- get ingredients past our initial slices of bread
	local plateIngredients = {}
	for plateIndex, plateIngredient in ipairs(plate) do
		-- if we made a sandwich, no recipes are valid, return nil
		if #plateIngredients > 0 and plateIngredient == 1 then
			return {}
		end

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
		for plateIndex, ingredient in ipairs(plateIngredients) do
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
	-- if we have exactly the number of ingredients for a recipe,
	-- and we have a recipe, return that one
	if #plateIngredients == recipeSize and #recipes == 1 then
		return recipes[1]
	end
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
