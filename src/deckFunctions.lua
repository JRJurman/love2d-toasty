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

function safeShuffle(source)
	local target = {}
	-- keep shuffling until the first six contain exactly 1 bread
	-- or until we hit like, 200 shuffles (give up at that point)
	local totalShuffles = 0
	repeat
		print('shuffling.. '..totalShuffles)
		totalShuffles = totalShuffles + 1
		target = shuffle(source)
	until countValueInTopOfPile(target, 6, 1) == 1 or totalShuffles > 200

	return target
end

function getScoreForPlate(plate)
	local plateScore = 0
	-- need 3 ingredients to start scoring (after bread)
	if #plate < 4 then
		return 0
	end

	-- if there are two slices of bread, score zero
	local slicesOfBread = countValueInTopOfPile(plate, #plate, 1)
	if slicesOfBread > 1 then
		return 0
	end

	for ingredientIndex, ingredient in ipairs(plate) do
		plateScore = plateScore + cardDetails[ingredient].points
	end

	return plateScore
end
