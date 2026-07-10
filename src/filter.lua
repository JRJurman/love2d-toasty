-- from https://www.tutorialspoint.com/lua/lua_filter_iterators.htm

-- define a filter with filter iterator
filter = function(array, filterIterator)

   -- filter result to be returned
   local result = {}

   -- iterate over main array
   for key, value in pairs(array) do
      -- call filterIterator
      if filterIterator(value, key, array) then
				-- append the value in filtered result
				table.insert(result,value)
			end
   end

   -- return the filtered result
   return result
end
