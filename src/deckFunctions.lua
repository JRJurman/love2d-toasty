require('cardDetails')

function countValueInTopOfPile(pile, count, value)
	local totalCount = 0
	for pileIndex=1, count do
		if pile[pileIndex] == value then
			totalCount = totalCount + 1
		end
	end
	return totalCount
end

function startingShuffle(source)
	local target = {}
	-- keep shuffling until the first three contain exactly 1 bread
	-- or until we hit like, 200 shuffles (give up at that point)
	local totalShuffles = 0
	repeat
		print('shuffling.. '..totalShuffles)
		totalShuffles = totalShuffles + 1
		target = shuffle(source)
	until countValueInTopOfPile(target, 3, 1) == 3 or totalShuffles > 200

	return target
end

function safeShuffle(source)
	local target = {}
	-- keep shuffling until the first six contain exactly 1 bread
	local totalShuffles = 0
	repeat
		print('shuffling.. '..totalShuffles)
		totalShuffles = totalShuffles + 1
		target = shuffle(source)
	until countValueInTopOfPile(target, 6, 1) == 1 or totalShuffles > 200

	return target
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
	local plateScore = 0
	local typeOfPlate = getTypeOfPlate(plate)

	for ingredientIndex, ingredient in ipairs(plate) do
		plateScore = plateScore + cardDetails[ingredient].points
	end

	return math.max(plateScore * typeOfPlate, 0)
end
