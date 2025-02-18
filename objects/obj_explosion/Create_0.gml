// obj_explosion Create Event
creator = noone;
base_damage = 50;  // Explosion holds its own base damage
has_dealt_damage = false;
image_speed = 1;

// Deal damage to all valid targets in radius
function deal_damage() {
    if (has_dealt_damage || !creator) return;
    
    // Calculate damage using creator's Area of Effect stat
    var final_damage = base_damage * creator.creature.stats.get_area_of_effect();
    // Get radius using creator's stats
    var explosion_radius = creator.creature.stats.get_explosion_radius();
    
    // Define target types to check
    var target_types = [obj_enemy_parent, obj_npc_parent];
    var targets = ds_list_create();
    
    // Check each target type
    for (var i = 0; i < array_length(target_types); i++) {
        var num = collision_circle_list(x, y, explosion_radius, target_types[i], false, true, targets, false);
        
        if (num > 0) {
            for (var j = 0; j < num; j++) {
                var target = targets[| j];
                if (variable_instance_exists(target, "creature")) {
                    global.health_system.damage_creature(target, final_damage);
                    var target_type = target_types[i] == obj_enemy_parent ? "enemy" : "NPC";
                }
            }
        }
        ds_list_clear(targets);  // Clear list for next target type
    }
    
    ds_list_destroy(targets);
    has_dealt_damage = true;
}