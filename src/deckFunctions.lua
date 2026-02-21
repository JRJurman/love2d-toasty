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
	-- keep shuffling until the first two contain exactly 1 bread
	-- or until we hit like, 200 shuffles (give up at that point)
	local totalShuffles = 0
	repeat
		print('shuffling.. '..totalShuffles)
		totalShuffles = totalShuffles + 1
		target = shuffle(source)
	until countValueInTopOfPile(target, 2, 1) == 1 or totalShuffles > 200

	return target
end

function safeShuffle(source)
	local target = {}
	-- keep shuffling until the first three contain exactly 1 bread
	local totalShuffles = 0
	repeat
		print('shuffling.. '..totalShuffles)
		totalShuffles = totalShuffles + 1
		target = shuffle(source)
	until countValueInTopOfPile(target, 3, 1) == 1 or totalShuffles > 200

	return target
end
