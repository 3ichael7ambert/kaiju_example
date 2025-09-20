/// ===== objKaiju : Destroy =====
if (ds_exists(children, ds_type_list)) ds_list_destroy(children);
if (ds_exists(required_parts, ds_type_list)) ds_list_destroy(required_parts);
if (ds_exists(parts_by_name, ds_type_map)) ds_map_destroy(parts_by_name);
