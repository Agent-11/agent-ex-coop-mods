-- name: Left 4 Dead 2 HUD
-- incompatible: hud
-- description: Left 4 Dead 2 HUD\nBy \\#ec7731\\Agent X\\#ffffff\\\n\nThis mod adds the Left 4 Dead 2 HUD into sm64ex-coop with other players' health bars on the side too, you can cycle through them with DPad left and DPad right. This mod is fully cross compatible and fully integrated with Downing as well so players will show as\nincapacitated on their healthbars and everything else.\nIf SM64 health is off (by default it is) you can pick up 1 ups and use them\nas first aid kits to heal.

gGlobalSyncTable.sm64Health = false

_G.l4dBarTexture = get_texture_info("gradient")

function check_for_mod(name, find)
    local has = false
    for k, v in pairs(gActiveMods) do
        if find then
            if v.enabled and v.name:find(name) then has = true end
        else
            if v.enabled and v.name == name then has = true end
        end
    end
    return has
end

downing = check_for_mod("Downing", false)

function lerp(a,b,t) return a * (1-t) + b * t end

function if_then_else(cond, if_true, if_false)
    if cond then return if_true end
    return if_false
end

function clamp(x, a, b)
    if x < a then return a end
    if x > b then return b end
    return x
end

function length(table)
    local count = 0
    for i in pairs(table) do
        count = count + 1
    end
    return count
end

--- @param m MarioState
function active_player(m)
    local np = gNetworkPlayers[m.playerIndex]
    if m.playerIndex == 0 then
        return true
    end
    if not np.connected then
        return false
    end
    if np.currCourseNum ~= gNetworkPlayers[0].currCourseNum then
        return false
    end
    if np.currActNum ~= gNetworkPlayers[0].currActNum then
        return false
    end
    if np.currLevelNum ~= gNetworkPlayers[0].currLevelNum then
        return false
    end
    if np.currAreaIndex ~= gNetworkPlayers[0].currAreaIndex then
        return false
    end
    return is_player_active(m)
end

function name_without_hex(name)
    local nameTable = {}
    name:gsub(".", function(c) table.insert(nameTable, c) end)

    local removed = false
    for k, v in pairs(nameTable) do
        if v == "\\" and not removed then
            removed = true
            nameTable[k] = ""     -- \
            nameTable[k + 1] = "" -- #
            nameTable[k + 2] = "" -- f
            nameTable[k + 3] = "" -- f
            nameTable[k + 4] = "" -- f
            nameTable[k + 5] = "" -- f
            nameTable[k + 6] = "" -- f
            nameTable[k + 7] = "" -- f
            nameTable[k + 8] = "" -- \
        end
    end
    return table.concat(nameTable, "")
end

function djui_hud_set_adjusted_color(r, g, b, a)
    local multiplier = 1
    if is_game_paused() then multiplier = 0.5 end
    djui_hud_set_color(r * multiplier, g * multiplier, b * multiplier, a)
end

glyphs = {
    [CT_MARIO] = get_texture_info("mario"),
    [CT_LUIGI] = get_texture_info("luigi"),
    [CT_TOAD] = get_texture_info("toad"),
    [CT_WALUIGI] = get_texture_info("waluigi"),
    [CT_WARIO] = get_texture_info("wario")
}

chars = {
    [CT_MARIO] = get_texture_info("mario_down"),
    [CT_LUIGI] = get_texture_info("luigi_down"),
    [CT_TOAD] = get_texture_info("toad_down"),
    [CT_WALUIGI] = get_texture_info("waluigi_down"),
    [CT_WARIO] = get_texture_info("wario_down")
}

--- @param m MarioState
function render_health_bar(x, m, scale, name)
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_MENU)

    local height = djui_hud_get_screen_height()

    -- down background
    if downing and m.action == _G.ACT_DOWN then
        if m.playerIndex == 0 then height = height - 8
        else x = x - 15 end

        djui_hud_set_adjusted_color(143, 47, 0, 255)
        djui_hud_render_rect(x - (102  * scale), height - (40 * scale), 102 * scale, 45 * scale)
    end
    -- background
    djui_hud_set_adjusted_color(0, 0, 0, if_then_else(downing and m.action == _G.ACT_DOWN, 255, 200))
    if not name and not (downing and m.action == _G.ACT_DOWN) then
        djui_hud_render_rect(x - (100 * scale), height - (21 * scale), 98 * scale, 13 * scale)
    else
        height = height - 6
        djui_hud_render_rect(x - (100 * scale), height - (21 * scale), 98 * scale, 28 * scale)
    end
    -- icon
    if downing and m.action == _G.ACT_DOWN then
        djui_hud_set_adjusted_color(255, 255, 255, 255)
        djui_hud_render_texture(chars[m.character.type], x - (100 * scale), height - (69 * scale), 0.2 * scale, 0.2 * scale)
    else
        if m.health > 0xff then djui_hud_set_adjusted_color(255, 255, 255, 255)
        else djui_hud_set_adjusted_color(230, 0, 0, 255) end
        djui_hud_render_texture(glyphs[m.character.type], x - (126.2 * scale), height - (33.6 * scale), 0.1 * scale, 0.1 * scale)
    end
    -- health bar
    local health = if_then_else(gGlobalSyncTable.sm64Health, math.floor(m.health / 272), math.floor(m.health / 21.72))
    if not gGlobalSyncTable.sm64Health then health = math.floor(health - lerp(12, 0, (health / 100))) end

    djui_hud_set_color(0, 0, 0, 255)
    djui_hud_render_rect(x - (99 * scale), height - (20 * scale), 96 * scale, 11.1 * scale)

    if gGlobalSyncTable.sm64Health then
        if health > 4 then djui_hud_set_adjusted_color(149, 246, 8, 255)
        elseif health <= 4 and health > 2 then djui_hud_set_adjusted_color(221, 184, 64, 255)
        else djui_hud_set_adjusted_color(228, 0, 0, 255) end
    else
        if health > 50 then djui_hud_set_adjusted_color(149, 246, 8, 255)
        elseif health <= 50 and health > 30 then djui_hud_set_adjusted_color(221, 184, 64, 255)
        else djui_hud_set_adjusted_color(228, 0, 0, 255) end
    end
    local fill = 1.5 * if_then_else(gGlobalSyncTable.sm64Health, (health / 8), (health / 100))
    if downing and m.action == _G.ACT_DOWN then
        djui_hud_set_adjusted_color(228, 0, 0, 255)
        fill = 1.5 * _G.downHealth[m.playerIndex] / 300
    end
    djui_hud_render_texture(_G.l4dBarTexture, x - (99 * scale), height - (20 * scale), (fill * scale), 0.175 * scale)
    -- display
    if m.playerIndex == 0 then
        if downing and m.action == _G.ACT_DOWN then
            djui_hud_print_text("+" .. _G.downHealth[m.playerIndex], x - (98.5 * scale), height - (9 * scale), 0.26 * scale)
        else
            djui_hud_print_text("+" .. health, x - (98.5 * scale), height - (37 * scale), 0.26 * scale)
        end
    elseif not (downing and m.action == _G.ACT_DOWN) then
        djui_hud_print_text("+" .. if_then_else(downing and m.action == _G.ACT_DOWN, _G.downHealth[m.playerIndex], health), x - (98.5 * scale), height - (37 * scale), 0.26 * scale)
    end
    if name then
        djui_hud_set_font(FONT_NORMAL)
        djui_hud_set_adjusted_color(230, 230, 230, 255)
        djui_hud_print_text(name_without_hex(gNetworkPlayers[m.playerIndex].name), x - (98 * scale), height - (9 * scale), 0.5 * scale)
    end
end

function render_info_box(y, glyph, info)
    local width = djui_hud_get_screen_width()
    local height = djui_hud_get_screen_height() * 0.5

    local boxLeft = width - 55
    djui_hud_set_color(0, 0, 0, 150)
    djui_hud_render_texture(get_texture_info("box"), boxLeft, height - y, 1.4, 1.06)
    djui_hud_set_adjusted_color(255, 255, 255, 255)
    djui_hud_render_texture(glyph, boxLeft + 2, height - y + 1.5, 0.9, 0.9)
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_print_text(info, boxLeft + 18, height - y + 2.5, 0.45)
end

offset = 0
function on_hud_render()
    if obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then return end

    djui_hud_set_resolution(RESOLUTION_N64)

    local width = djui_hud_get_screen_width()
    local height = djui_hud_get_screen_height() * 0.5
    -- health bars
    local m = gMarioStates[0]
    render_health_bar(width, m, 1, false)
    local spot = 0
    local gActiveMarioStates = {}
    for i = 1, network_player_connected_count() - 1 do
        if active_player(gMarioStates[i]) then table.insert(gActiveMarioStates, gMarioStates[i]) end
    end
    if (m.controller.buttonPressed & R_JPAD) ~= 0 then offset = offset + 1 end
    if (m.controller.buttonPressed & L_JPAD) ~= 0 then offset = offset - 1 end
    offset = clamp(offset, 0, length(gActiveMarioStates) - 3)
    for i = 1, 3 do
        local p = i + offset
        if gActiveMarioStates[p] ~= nil then
            spot = spot + 1
            render_health_bar(77 * spot, gActiveMarioStates[p], 0.6, true)
        end
    end
    -- side bar
    render_info_box(42, gTextures.star,   tostring("x" .. hud_get_value(HUD_DISPLAY_STARS)))
    render_info_box(21, gTextures.coin,   tostring("x" .. hud_get_value(HUD_DISPLAY_COINS)))
    render_info_box(0,  get_texture_info("1up"), tostring("x" .. hud_get_value(HUD_DISPLAY_LIVES)))
    -- first aid
    if not gGlobalSyncTable.sm64Health then
        local boxLeft = width - 27
        djui_hud_set_color(0, 0, 0, 150)
        djui_hud_render_texture(get_texture_info("boxsquare"), boxLeft, height + 21, 1.06, 1.06)
        local tex = get_texture_info("no1up")
        if gPlayerSyncTable[0].firstAid then tex = get_texture_info("1up") end
        djui_hud_set_adjusted_color(255, 255, 255, 255)
        djui_hud_render_texture(tex, boxLeft + 1.5, height + 22.5, 0.9, 0.9)
    end

    -- healing
    if m.action == ACT_HEALING then
        width = (width * 0.5) + 3
        djui_hud_set_adjusted_color(77, 73, 79, 255)
        djui_hud_render_rect(width - 69, height - 18, 29, 29)
        djui_hud_render_rect(width - 41, height - 4, 118, 15)
        djui_hud_set_color(0, 0, 0, 255)
        djui_hud_render_rect(width - 68, height - 17, 27, 27)
        djui_hud_render_rect(width - 40, height - 3, 116, 13)
        -- text
        djui_hud_set_adjusted_color(255, 255, 255, 255)
        djui_hud_set_font(FONT_MENU)
        djui_hud_print_text("+", width - 67, height - 25, 0.6)
        djui_hud_set_font(FONT_NORMAL)
        djui_hud_set_color(0, 0, 0, 180)
        djui_hud_print_text("HEALING YOURSELF", width - 38, height - 20, 0.45)
        djui_hud_set_adjusted_color(255, 255, 255, 255)
        djui_hud_print_text("HEALING YOURSELF", width - 38, height - 21, 0.45)
        -- bar
        djui_hud_set_adjusted_color(221, 184, 64, 255)
        local fill = 1.78 * (m.actionTimer / HEALING_TIME)
        djui_hud_render_texture(_G.l4dBarTexture, width - 39, height - 2, fill, 0.175)
    end
end

function on_sm64_health_command(msg)
    if msg == "on" then
        gGlobalSyncTable.sm64Health = true
        djui_chat_message_create("SM64 Health status: \\#00ff00\\ON")
    else
        gGlobalSyncTable.sm64Health = false
        djui_chat_message_create("SM64 Health status: \\#FF0000\\OFF")
    end
    return true
end

function on_sm64_health_changed(tag, oldVal, newVal)
    if newVal and gPlayerSyncTable[0].firstAid then
        local m = gMarioStates[0]
        m.numLives = m.numLives + 1
        gPlayerSyncTable[0].firstAid = false
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

hook_on_sync_table_change(gGlobalSyncTable, "sm64Health", 0, on_sm64_health_changed)

if network_is_server() then
    hook_chat_command("sm64-health", "[on|off] to use 8 slice health (disables 1 up first aid kits) or convert it into 0-100, default is \\#ff0000\\OFF", on_sm64_health_command)
end

hud_hide()