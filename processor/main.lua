local json           = require('dkjson')
local helper         = require('helper')
local poi_restaurant = require('poi_restaurant')

-- For debugging:
-- inspect = require('inspect')

-- Print some basic information
print('osm2pgsql version: ' .. osm2pgsql.version)

-- Define the tables
local tables = {}

tables.pois = osm2pgsql.define_node_table('pois', {
    { column = 'id',      type = 'serial', create_only = true },
    { column = 'name',    type = 'text',   not_null = true },
    { column = 'geom',    type = 'point' },
    { column = 'info',    type = 'jsonb'}
})

-- The OSM processors:

function osm2pgsql.process_node(object)
    --  Uncomment next line to look at the object data:
    --  print(inspect(object))

    if helper.clean_tags(object.tags) then
        return
    end

    local processor = nil

    if poi_restaurant.is_processable(object) then
        processor = poi_restaurant
    end

    if processor != nil then
        tables.pois:add_row({
            name = processor.get_name(object),
            info = json.encode(processor.get_info(object))
        })
    end
end
