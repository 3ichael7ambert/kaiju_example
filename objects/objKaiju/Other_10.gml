/// ===== objKaiju : User Event 0 (death) =====

if (is_root) {
    // kill all remaining children
    for (var i = 0; i < ds_list_size(children); i++) {
        var c = children[| i];
        if (instance_exists(c)) with (c) { dead = true; instance_destroy(); }
    }
    // big FX / loot here
    if (asset_get_index("obj_BigExplode") != -1)
        instance_create_layer(x, y, "FX", obj_BigExplode);

    instance_destroy();
} else {
    dead = true;

    // small FX
    if (asset_get_index("obj_SmallExplode") != -1)
        instance_create_layer(x, y, "FX", obj_SmallExplode);

    // detach my children (if any were re-parented later)
    // (optional; in this design children are only created by root)
    instance_destroy();
}
