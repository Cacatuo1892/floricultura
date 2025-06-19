-- Floricultura mod generado automáticamente
-- Registro manual de cultivos y semillas sin farming.register_plant

local flores = {
    {name = "chrysanthemum_green", item = "flowers:chrysanthemum_green", desc = "Semilla de Crisantemo Verde"},
    {name = "dandelion_white", item = "flowers:dandelion_white", desc = "Semilla de Diente de León Blanco"},
    {name = "dandelion_yellow", item = "flowers:dandelion_yellow", desc = "Semilla de Diente de León Amarillo"},
    {name = "geranium", item = "flowers:geranium", desc = "Semilla de Geranio"},
    {name = "rose", item = "flowers:rose", desc = "Semilla de Rosa"},
    {name = "tulip", item = "flowers:tulip", desc = "Semilla de Tulipán"},
    {name = "tulip_black", item = "flowers:tulip_black", desc = "Semilla de Tulipán Negro"},
    {name = "viola", item = "flowers:viola", desc = "Semilla de Violeta"},
}

for _, flor in ipairs(flores) do
    local fullbase = "floricultura:" .. flor.name

    -- Etapas de crecimiento
    for stage = 1, 3 do
        local def = {
            description = flor.desc .. " (Etapa " .. stage .. ")",
            drawtype = "plantlike",
            tiles = {"floricultura_" .. flor.name .. "_" .. stage .. ".png"},
            inventory_image = "floricultura_" .. flor.name .. "_" .. stage .. ".png",
            wield_image = "floricultura_" .. flor.name .. "_" .. stage .. ".png",
            paramtype = "light",
            sunlight_propagates = true,
            walkable = false,
            selection_box = farming.select,
            groups = {
                snappy = 3, flammable = 2, plant = 1,
                not_in_creative_inventory = 1, growing = 1,
            },
            sounds = default.node_sound_leaves_defaults(),
        }

        if stage == 3 then
            def.drop = {
                max_items = 1,
                items = {
                    {items = {flor.item .. " 5"}, rarity = 5},
                    {items = {flor.item .. " 4"}, rarity = 2},
                    {items = {flor.item .. " 3"}},
                }
            }
        end

        minetest.register_node(fullbase .. "_" .. stage, def)
    end

    -- Semilla y colocación personalizada
    minetest.register_craftitem(fullbase .. "_seed", {
        description = flor.desc,
        inventory_image = "floricultura_" .. flor.name .. "_seed.png",
        on_place = function(itemstack, placer, pointed_thing)
            local under = pointed_thing.under
            local above = pointed_thing.above

            local valid_soils = {
                ["farming:soil"] = true,
                ["farming:soil_wet"] = true,
            }

            if valid_soils[minetest.get_node(under).name] and minetest.get_node(above).name == "air" then
                minetest.set_node(above, {name = fullbase .. "_1"})
                itemstack:take_item()
                return itemstack
            end

            return minetest.item_place(itemstack, placer, pointed_thing)
        end,
    })

    -- Receta de crafteo
    minetest.register_craft({
        output = fullbase .. "_seed",
        recipe = {
            {flor.item, flor.item},
        }
    })

    -- ABM para acelerar crecimiento
    for stage = 1, 2 do
        local nodename = fullbase .. "_" .. stage
        local nextstage = fullbase .. "_" .. (stage + 1)

        minetest.register_abm({
            label = "Floricultura crecimiento: " .. flor.name .. " etapa " .. stage,
            nodenames = {nodename},
            interval = 15,  -- más frecuente
            chance = 3,     -- más probabilidad
            action = function(pos, node)
                local light = minetest.get_node_light(pos)
                if light and light >= 13 then
                    minetest.set_node(pos, {name = nextstage})
                end
            end
        })
    end
end

