require('cardDetails')
require('shuffle')

function countValueInTopOfPile(pile, count, value)
	local totalCount = 0
	for pileIndex=1, count do
		if pile[pileIndex] == value then
			totalCount = totalCount + 1
		end
	end
	return totalCount
end

function safeShuffle(source, deep, card)
	local target = {}
	local deep = deep or 3
	local card = card or 1
	-- keep shuffling until the first three (or however many deep we pass in) contain exactly 1 bread
	local totalShuffles = 0
	repeat
		totalShuffles = totalShuffles + 1
		target = shuffle(source)
	until countValueInTopOfPile(target, deep, card) == 1 or totalShuffles > 200

	return target
end
