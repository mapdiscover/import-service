-- Module container
local M = {}

-- Processor implementation
function is_processable(object)
    return object.tags.amenity == 'restaurant' and object.tags.name
end

function get_name(object) 
    return object.name
end

function get_info(object)
    return object.tags
end

-- Exported functions:
M.is_processable = is_processable
M.get_name = get_name
M.get_info = get_info

return M