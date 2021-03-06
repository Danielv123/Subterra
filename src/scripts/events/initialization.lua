--============================================================================--
-- initialization.lua
--============================================================================--


require 'util'
require ('config')
require 'scripts/utils'
--MAX_LAYER_COUNT = 2

--============================================================================--
-- InitializeSubterra()
--
-- initiate mod and generate underground surface
-- wired in control.lua:game.on_init
--============================================================================--
function InitializeSubterra ()
    -- copy map settings
    local gen_settings = table.deepcopy(game.surfaces['nauvis'].map_gen_settings)
    -- remove resources from settings
    for _, r in pairs(gen_settings.autoplace_controls) do
        r.frequency = 'very-low'
        r.size = 'none'
        r.richness = 'very-poor'
    end
    gen_settings.peaceful_mode = true
    -- create surface(s) with no resources
    for i = 2, subterra.config.MAX_LAYER_COUNT do
        local layer_name = "underground_" .. tostring(i-1)
        if game.surfaces[layer_name] == nil then
            game.create_surface(layer_name, gen_settings)
            game.surfaces[layer_name].daytime = 0.5
            game.surfaces[layer_name].freeze_daytime(true)
        end
        if remote.interfaces["RSO"] then
            remote.call("RSO", "ignoreSurface", layer_name)
        end
    end
    
    -- create player proxies
    global.player_proxies = {}
    
    for i, p in pairs(game.players) do
       addPlayerProxy(i, p)
    end

    -- initialize layers container
    global.layers = {}
    table.insert(global.layers, {
            index = 1,
            layer_above = nil,
            surface = game.surfaces["nauvis"],
            telepads = Quadtree:new()
        })
    global.layers["nauvis"] = global.layers[1]

    for i = 2, subterra.config.MAX_LAYER_COUNT do
        local l_name = "underground_"..tostring(i-1)
        local layer = {
            index = i,
            surface = game.surfaces[l_name],
            telepads = Quadtree:new()
        }
        table.insert(global.layers, layer)
        global.layers[l_name] = layer
    end

    -- set adjacency and kickstart chunk generation
    global.layers[1].layer_below = global.layers[2]
    for i = 2, subterra.config.MAX_LAYER_COUNT do
        global.layers[i].surface.request_to_generate_chunks({0,0}, 10)
        global.layers[i].layer_above = global.layers[i-1]
        if i < subterra.config.MAX_LAYER_COUNT then
            global.layers[i].layer_below = global.layers[i+1]
        else
            global.layers[i].layer_below = nil
        end
    end

    -- initialize belt-elevator container
    global.belt_inputs = {}
    global.belt_outputs = {}

    -- set underground enitity list
    global.underground_entities = table.deepcopy(subterra.config.starting_entities)
end

--============================================================================--
-- OnPlayerJoined()
--
-- add player to needed data structures
-- wired in control.lua:
--============================================================================--
function OnPlayerJoined(event)
    addPlayerProxy(event.player_index)
end

function addPlayerProxy(i)
    local p = game.players[i]
    if global.player_proxies[i] == nil then
        local proxy = {
            name = p.name,
            index = i,
            player = p,
            on_pad = -1,
        }
        global.player_proxies[i] = proxy
    end
end

function OnPlayerLeft(event)
    global.player_proxies[event.player_index] = nil
end

function OnLoad()
    --game.players[1].print("onload")
    for _, layer in pairs(global.layers) do
        local pads = layer.telepads
        if getmetatable(pads) == nil then
            setmetatable(pads, Quadtree)
	        pads:rebuild_metatables()
        end
    end
end