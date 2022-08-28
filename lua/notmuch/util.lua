local M = {}

function M.wrap_iterator(iterator, constructor)
	return function ()
		local item = iterator()
		if item ~= nil then
			return constructor:new(item)
		end
	end
end

return M
