-- name: Mario Style
-- description: Mario Style v1.1\n\\#dcdcdc\\By \\#ff7f00\\Agent X\\#ffff00\\\n\nFirst released mod to use DynOS custom\nanimations!\\#dcdcdc\\\nThis mod adds a custom star dance animation (Mario Style) as well as a tune to go along with it.\n\nIf you have a custom character model and wish for it to be compatible with Mario Style you must place the anims folder (the zip is on my GitHub) in your model's folder, this also works with DynOS packs so if you want to have Mario Style locally then you can use that.

-- localize functions to improve performance
local smlua_anim_util_set_animation,play_secondary_music,audio_sample_play,get_current_background_music_target_volume = smlua_anim_util_set_animation,play_secondary_music,audio_sample_play,get_current_background_music_target_volume

SOUND_CUSTOM_GANGNAM = audio_sample_load("gangnam.mp3")

--- @param m MarioState
local function mario_update(m)
    if not gNetworkPlayers[m.playerIndex].connected then return end

    if m.marioObj.header.gfx.animInfo.animID == MARIO_ANIM_STAR_DANCE then
        smlua_anim_util_set_animation(m.marioObj, "mario_anim_gangnam")
    end

    if m.playerIndex == 0 and (m.action == ACT_STAR_DANCE_EXIT or m.action == ACT_STAR_DANCE_NO_EXIT) then
        play_secondary_music(SEQ_EVENT_CUTSCENE_COLLECT_STAR, 0, 0, 1)
    end
end

--- @param m MarioState
local function on_set_mario_action(m)
    if not gNetworkPlayers[m.playerIndex].connected then return end

    if m.action == ACT_STAR_DANCE_EXIT or m.action == ACT_STAR_DANCE_NO_EXIT then
        audio_sample_play(SOUND_CUSTOM_GANGNAM, m.marioObj.header.gfx.cameraToObject, 5)
    elseif m.prevAction == ACT_STAR_DANCE_EXIT or m.prevAction == ACT_STAR_DANCE_NO_EXIT then
        play_secondary_music(SEQ_EVENT_CUTSCENE_COLLECT_STAR, get_current_background_music_target_volume(), 0, 1)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_SET_MARIO_ACTION, on_set_mario_action)