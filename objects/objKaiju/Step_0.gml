/// ===== objKaiju : Step =====

if (dead) exit;

// ---------- ROOT controls targeting & win condition ----------
if (is_root) {
    var pl = instance_nearest(x, y, target);
    if (instance_exists(pl)) { target_x = pl.x; target_y = pl.y; }

    // win when all required parts are dead
    var all_down = true;
    for (var i = 0; i < ds_list_size(required_parts); i++) {
        var prt = required_parts[| i];
        if (instance_exists(prt) && !prt.dead) { all_down = false; break; }
    }
    if (all_down) { dead = true; event_user(0); }
    exit;
}

// ---------- CHILD LOGIC ----------
switch (role) {

    // ------- MECH PARTS: bone follow -------
    case KaijuRole.CORE:
    case KaijuRole.HEAD:
    case KaijuRole.TORSO_U:
    case KaijuRole.TORSO_L:
    case KaijuRole.ARM_U_L:
    case KaijuRole.ARM_L_L:
    case KaijuRole.HAND_L:
    case KaijuRole.ARM_U_R:
    case KaijuRole.ARM_L_R:
    case KaijuRole.HAND_R:
    case KaijuRole.THIGH_L:
    case KaijuRole.CALF_L:
    case KaijuRole.FOOT_L:
    case KaijuRole.THIGH_R:
    case KaijuRole.CALF_R:
    case KaijuRole.FOOT_R:
    case KaijuRole.WING_L:
    case KaijuRole.WING_R:
    {
        if (!instance_exists(parent_ref)) { instance_destroy(); break; }

        var bx = parent_ref.x, by = parent_ref.y, ba = parent_ref.image_angle;
        var r   = point_distance(0,0, local_x, local_y);
        var ang = point_direction(0,0, local_x, local_y);

        x = bx + lengthdir_x(r, ba + ang);
        y = by + lengthdir_y(r, ba + ang);
        image_angle = (follow_parent_ang ? ba : 0) + local_ang;
    }
    break;

    // ------- DRAGON HEAD -------
    case KaijuRole.DRAGON_HEAD:
    {
        var pl = instance_nearest(x, y, target);
        if (instance_exists(pl)) {
            var desired = point_direction(x, y, pl.x, pl.y);
            image_angle = _ang_move_to(image_angle, desired, turn_rate);
        }
        var wave = sin(current_time * 0.004) * wiggle_k;
        var ang  = image_angle + wave;
        x += lengthdir_x(move_speed, ang);
        y += lengthdir_y(move_speed, ang);
    }
    break;

    // ------- DRAGON SEGMENT -------
    case KaijuRole.DRAGON_SEG:
    {
        if (!instance_exists(parent_ref)) { instance_destroy(); break; }
        var tx = parent_ref.x, ty = parent_ref.y;
        var dir  = point_direction(x, y, tx, ty);
        var dist = point_distance(x, y, tx, ty);
        var step = max(0, dist - target_dist);

        x += lengthdir_x(step, dir);
        y += lengthdir_y(step, dir);
        image_angle = dir;
    }
    break;
}
