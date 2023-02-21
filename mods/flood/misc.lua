E_MODEL_FLOOD = smlua_model_util_get_id("flood_geo")
E_MODEL_CTT = smlua_model_util_get_id("ctt_geo") -- easter egg in the distance
E_MODEL_LAUNCHPAD = smlua_model_util_get_id("launchpad_geo")

COL_LAUNCHPAD = smlua_collision_util_get("launchpad_collision")
COL_SPECTATOR_FLOOR = smlua_collision_util_get("spectator_floor_collision")

--- @param o Object
function bhv_water_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oAnimState = gLevels[gGlobalSyncTable.level].type

    o.header.gfx.skipInViewCheck = true

    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
end

--- @param o Object
function bhv_water_loop(o)
    o.oPosY = gGlobalSyncTable.waterLevel

    if gGlobalSyncTable.level ~= LEVEL_SSL then
        o.oFaceAngleYaw = o.oTimer * 14
    end

    for i = 1, 3 do
        if get_environment_region(i) < gGlobalSyncTable.waterLevel then
            set_environment_region(i, -20000)
        end
    end

    if needlemouse_in_server() and gNetworkPlayers[0].currLevelNum == LEVEL_TTC and o.oAnimState ~= 1 then
        o.oAnimState = 1
        smlua_text_utils_course_acts_replace(COURSE_TTC, "    Tit Tock Cock", "CUMMIES", "CUMMIES", "CUMMIES", "CUMMIES", "CUMMIES", "CUMMIES")
        djui_chat_message_create("Cummies Mode Activated")
        play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    end
end

id_bhvWater = hook_behavior(nil, OBJ_LIST_SURFACE, true, bhv_water_init, bhv_water_loop)


--- @param o Object
function bhv_custom_static_object_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    if o.header.gfx.skipInViewCheck ~= nil then o.header.gfx.skipInViewCheck = true end
    set_override_far(50000)
end

id_bhvCustomStaticObject = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_custom_static_object_init, nil)


--- @param o Object
function bhv_final_star_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.hitboxRadius = 160
    o.hitboxHeight = 100

    cur_obj_scale(2)
end

--- @param o Object
function bhv_final_star_loop(o)
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x800
end

id_bhvFinalStar = hook_behavior(nil, OBJ_LIST_GENACTOR, true, bhv_final_star_init, bhv_final_star_loop)


function bhv_launchpad_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oCollisionDistance = 500
    o.collisionData = COL_LAUNCHPAD
    obj_scale(o, 0.85)
end

function bhv_launchpad_loop(o)
    local m = nearest_mario_state_to_object(o)
    if m.marioObj.platform == o then
        play_mario_jump_sound(m)
        if o.oBehParams2ndByte ~= 0x69 then -- humor
            set_mario_action(m, ACT_TWIRLING, 0)
            m.vel.y = o.oBehParams2ndByte
        else
            spawn_non_sync_object(
                id_bhvWingCap,
                E_MODEL_MARIOS_WING_CAP,
                m.pos.x + m.vel.x, m.pos.y + m.vel.y, m.pos.z + m.vel.z,
                nil
            )
            vec3f_set(m.angleVel, 0, 0, 0)
            set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 0)
            m.vel.y = 55
            mario_set_forward_vel(m, 80)
            m.faceAngle.y = 0x4500
        end
    end
    load_object_collision_model()
end

id_bhvLaunchpad = hook_behavior(nil, OBJ_LIST_SURFACE, true, bhv_launchpad_init, bhv_launchpad_loop)


--- @param o Object
function bhv_flood_flag_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oInteractType = INTERACT_POLE
    o.hitboxRadius = 80
    o.hitboxHeight = 700
    o.oIntangibleTimer = 0
    o.oAnimations = gObjectAnimations.koopa_flag_seg6_anims_06001028

    cur_obj_init_animation(0)
end

--- @param o Object
function bhv_flood_flag_loop(o)
    bhv_pole_base_loop()
end

id_bhvFloodFlag = hook_behavior(nil, OBJ_LIST_POLELIKE, true, bhv_flood_flag_init, bhv_flood_flag_loop)


--- @param o Object
function obj_hide(o)
    o.header.gfx.node.flags = o.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
end

--- @param o Object
function obj_mark_for_deletion_on_sync(o)
    if gNetworkPlayers[0].currAreaSyncValid then obj_mark_for_deletion(o) end
end

hook_behavior(id_bhvHoot, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvStar, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvUkiki, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvCannon, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvRedCoin, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvWarpPipe, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvFadingWarp, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvEyerokBoss, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvBalconyBigBoo, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvRecoveryHeart, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)
hook_behavior(id_bhvExclamationBox, OBJ_LIST_UNIMPORTANT, true, obj_hide, obj_mark_for_deletion_on_sync)

function before_phys_step(m)
    if m.playerIndex ~= 0 then return end

    if m.pos.y + 40 < gGlobalSyncTable.waterLevel and gNetworkPlayers[m.playerIndex].currLevelNum == gGlobalSyncTable.level then
        m.vel.y = m.vel.y + 2
    end
end

--- @param m MarioState
--- @param o Object
function allow_interact(m, o)
    if m.action == ACT_SPECTATOR or (o.header.gfx.node.flags & GRAPH_RENDER_ACTIVE) == 0 then return false end
    if o.oInteractType == INTERACT_STAR_OR_KEY or
    o.oInteractType == INTERACT_WARP_DOOR or
    o.oInteractType == INTERACT_WARP then return false end

    return true
end

function on_death()
    local m = gMarioStates[0]
    if m.floor.type == SURFACE_DEATH_PLANE or m.floor.type == SURFACE_VERTICAL_WIND then
        m.health = 0xff
    end
    return false
end

function on_pause_exit()
    if network_player_connected_count() == 1 then
        round_start()
        level_restart()
    end
    return false
end

--- @param o Object
function heal_on_contact(o)
    local m = gMarioStates[0]
    if obj_check_hitbox_overlap(o, m.marioObj) then
        m.healCounter = 31
        m.hurtCounter = 0
    end
end

id_bhv1Up = hook_behavior(id_bhv1Up, OBJ_LIST_LEVEL, false, nil, heal_on_contact)
id_bhv1upJumpOnApproach = hook_behavior(id_bhv1upJumpOnApproach, OBJ_LIST_LEVEL, false, nil, heal_on_contact)
id_bhv1upRunningAway = hook_behavior(id_bhv1upRunningAway, OBJ_LIST_LEVEL, false, nil, heal_on_contact)
id_bhv1upSliding = hook_behavior(id_bhv1upSliding, OBJ_LIST_LEVEL, false, nil, heal_on_contact)
id_bhv1upWalking = hook_behavior(id_bhv1upWalking, OBJ_LIST_LEVEL, false, nil, heal_on_contact)
id_bhvHidden1up = hook_behavior(id_bhvHidden1up, OBJ_LIST_LEVEL, false, nil, heal_on_contact)
id_bhvHidden1upInPole = hook_behavior(id_bhvHidden1upInPole, OBJ_LIST_LEVEL, false, nil, heal_on_contact)

hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)