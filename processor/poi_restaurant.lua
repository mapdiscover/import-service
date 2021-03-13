-- Module container
local poi_restaurant = {}

-- Processor implementation
function is_processable(object)
    return object.tags.amenity == 'restaurant' and object.tags.name
end

function get_name(object)
    return object.tags.name
end

function get_info(object)
    return object.tags
end

-- Exported functions:
poi_restaurant.is_processable = is_processable
poi_restaurant.get_name = get_name
poi_restaurant.get_info = get_info

return poi_restaurant