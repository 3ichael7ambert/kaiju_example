/// ===== objKaiju : Create =====
randomize();

enum KaijuRole {
    ROOT,
    CORE, HEAD, TORSO_U, TORSO_L,
    ARM_U_L, ARM_L_L, HAND_L,
    ARM_U_R, ARM_L_R, HAND_R,
    THIGH_L, CALF_L, FOOT_L,
    THIGH_R, CALF_R, FOOT_R,
    WING_L, WING_R,
    DRAGON_HEAD, DRAGON_SEG
}

function _ang_move_to(cur, target, maxstep) {
    var d = angle_difference(cur, target);
    return cur + clamp(d, -maxstep, maxstep);
}


target=noone;

// ---------- FACTORY GATE (FIRST!) ----------
if (!variable_global_exists("__kaiju_spawn_depth")) global.__kaiju_spawn_depth = 0;
if (global.__kaiju_spawn_depth > 0) {
    is_root = false;
    parent_ref = noone;
    if (!variable_instance_exists(self, "children")) children = ds_list_create();
    hp_max = 1; hp = 1; armor = 0; dead = false; hit_time = 0;
    exit;
}

// ---------- ROOT DEFAULTS ----------
role = KaijuRole.ROOT; 
is_root = true; 
parent_ref = noone;
children = ds_list_create();
local_x = 0; local_y = 0; local_ang = 0;
follow_parent_ang = true; required_to_kill = false;
hp_max = 1000; hp = hp_max; armor = 0; dead = false; hit_time = 0;
target_x = x; target_y = y;

parts_by_name = ds_map_create();
required_parts = ds_list_create();
dragon_seg_count = 0;

if (!variable_instance_exists(self, "kaiju_mode")) kaiju_mode = choose("mech","dragon");
var root_id = id;

// ===========================
// MECH SPAWN
// ===========================
if (kaiju_mode == "mech") {
    var bp = [
        ["core",   KaijuRole.CORE,       sprMech_Core,    3000, 4, "",       0,   0,   0,  true,  true ],
        ["head",   KaijuRole.HEAD,       sprMech_Head,    1200, 2, "core",   0,  -56,  0,  true,  true ],
        ["torsoU", KaijuRole.TORSO_U,    sprMech_TorsoU,  1800, 3, "core",   0,  -16,  0,  true,  false],
        ["torsoL", KaijuRole.TORSO_L,    sprMech_TorsoL,  2000, 5, "core",   0,   16,  0,  true,  false],
        ["armU_L", KaijuRole.ARM_U_L,    sprMech_ArmU,    1100, 2, "torsoU",-42,  -8, -8,  true,  true ],
        ["armL_L", KaijuRole.ARM_L_L,    sprMech_ArmL,     900, 1, "armU_L",-24,   8, 12,  true,  true ],
        ["handL",  KaijuRole.HAND_L,     sprMech_Hand,     700, 1, "armL_L",-18,  12, 30,  true,  true ],
        ["armU_R", KaijuRole.ARM_U_R,    sprMech_ArmU,    1100, 2, "torsoU", 42,  -8,  8,  true,  true ],
        ["armL_R", KaijuRole.ARM_L_R,    sprMech_ArmL,     900, 1, "armU_R", 24,   8,-12,  true,  true ],
        ["handR",  KaijuRole.HAND_R,     sprMech_Hand,     700, 1, "armL_R", 18,  12,-30,  true,  true ],
        ["thighL", KaijuRole.THIGH_L,    sprMech_Thigh,   1300, 2, "torsoL",-18,  16,  0,  true,  true ],
        ["calfL",  KaijuRole.CALF_L,     sprMech_Calf,    1100, 2, "thighL",  0,  20,  0,  true,  true ],
        ["footL",  KaijuRole.FOOT_L,     sprMech_Foot,     900, 1, "calfL",   0,  16,  0,  true,  true ],
        ["thighR", KaijuRole.THIGH_R,    sprMech_Thigh,   1300, 2, "torsoL", 18,  16,  0,  true,  true ],
        ["calfR",  KaijuRole.CALF_R,     sprMech_Calf,    1100, 2, "thighR",  0,  20,  0,  true,  true ],
        ["footR",  KaijuRole.FOOT_R,     sprMech_Foot,     900, 1, "calfR",   0,  16,  0,  true,  true ],
        ["wingL",  KaijuRole.WING_L,     sprMech_Wing,    1000, 1, "torsoU",-36, -20, -4,  true,  false],
        ["wingR",  KaijuRole.WING_R,     sprMech_Wing,    1000, 1, "torsoU", 36, -20,  4,  true,  false]
    ];

    global.__kaiju_spawn_depth++;
    for (var i = 0; i < array_length(bp); i++) {
        var r = bp[i];
        var inst = instance_create_layer(x, y, layer, object_index);
        with (inst) {
            is_root = false;
            role = r[1];
            sprite_index = r[2];
            hp_max = r[3]; hp = hp_max;
            armor  = r[4];
            parent_name = r[5];
            local_x = r[6]; local_y = r[7]; local_ang = r[8];
            follow_parent_ang = r[9];
            required_to_kill  = r[10];
            core_root = root_id;
        }
        ds_map_add(parts_by_name, r[0], inst);
        ds_list_add(children, inst);
        if (r[10]) ds_list_add(required_parts, inst);
    }
    global.__kaiju_spawn_depth--;

    // link parents
    for (var i = 0; i < array_length(bp); i++) {
        var nm = bp[i][0], pn = bp[i][5];
        var me = parts_by_name[? nm];
        me.parent_ref = (pn == "") ? root_id : parts_by_name[? pn];
    }
}
// ===========================
// DRAGON SPAWN
// ===========================
else if (kaiju_mode == "dragon") {
    global.__kaiju_spawn_depth++;

    var _spr_head = asset_get_index("sprDragonHead"); if (_spr_head < 0) _spr_head = -1;
    var _spr_seg  = asset_get_index("sprDragonSeg");  if (_spr_seg  < 0) _spr_seg  = -1;
    var _root_id = id;

    // head
    var head = instance_create_layer(x, y, layer, object_index);
    head.is_root           = false;
    head.role              = KaijuRole.DRAGON_HEAD;
    head.sprite_index      = _spr_head;
    head.hp_max            = 9000; head.hp = head.hp_max;
    head.armor             = 6;
    head.core_root         = _root_id;
    head.parent_ref        = _root_id;
    head.local_x           = 0; head.local_y = 0; head.local_ang = 0;
    head.follow_parent_ang = false;
    head.required_to_kill  = true;
    head.move_speed        = 2.4;
    head.turn_rate         = 2.0;
    head.wiggle_k          = 4;

    ds_list_add(children, head);
    ds_list_add(required_parts, head);

    // segments
    dragon_seg_count = 28;
    var prev = head;
    for (var j = 0; j < dragon_seg_count; j++) {
        var seg = instance_create_layer(x, y, layer, object_index);
        seg.is_root           = false;
        seg.role              = KaijuRole.DRAGON_SEG;
        seg.sprite_index      = _spr_seg;
        seg.hp_max            = 260 + j*12; seg.hp = seg.hp_max;
        seg.armor             = 2;
        seg.core_root         = _root_id;
        seg.parent_ref        = prev;
        seg.target_dist       = 18;
        seg.follow_parent_ang = false;

        ds_list_add(children, seg);
        prev = seg;
    }

    global.__kaiju_spawn_depth--;
}
