// obj_health_system Step Event
with(all) {
    // Skip objects without creature property
    if (!variable_instance_exists(id, "creature")) continue;
    
    // Apply health regeneration
    if (variable_struct_exists(creature, "stats") && 
        variable_struct_exists(creature.stats, "health_regen") && 
        creature.stats.health_regen > 0) {
        
        var regen_amount = creature.stats.health_regen / 60; // convert per second to per step
        
        // Use new component if available, otherwise use old system
        if (variable_instance_exists(id, "entity") && 
            variable_struct_exists(entity, "health")) {
            entity.health.heal(regen_amount);
            // Sync to creature system during transition
            creature.current_health = entity.health.current_health;
        } else {
            global.health_system.modify_health(id, regen_amount);
        }
    } 
    
    // Check for collisions with other creatures
    var collided_creature = instance_place(x, y, all);
    if (collided_creature != noone) {
        if (variable_instance_exists(id, "is_player") && 
            variable_instance_exists(collided_creature, "creature") &&
            variable_instance_exists(collided_creature, "is_enemy")) {
            
            if (collided_creature.is_enemy) {
                // Apply damage using new component if available
                if (variable_instance_exists(id, "entity") && 
                    variable_struct_exists(entity, "health")) {
                    entity.health.take_damage(50);
                    // Sync to creature system during transition
                    creature.current_health = entity.health.current_health;
                } else {
                    global.health_system.damage_creature(id, 50);
                }
            }
        }
    }
    
    // Check if any creature's health reaches 0
    // First check component health if available
    if (variable_instance_exists(id, "entity") && 
        variable_struct_exists(entity, "health") && 
        entity.health.current_health <= 0) {
        
        if (variable_instance_exists(id, "is_player")) {
            creature.die();  // Call the creature's die function
        }
    } 
    // If no component, check creature health
    else if (variable_struct_exists(creature, "current_health") && 
             creature.current_health <= 0) {
        
        if (variable_instance_exists(id, "is_player")) {
            creature.die();  // Call the creature's die function
        }
    }
}