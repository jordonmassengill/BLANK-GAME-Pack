// obj_npc_parent Step Event (parent = obj_creature_parent)
event_inherited();

// Death check - handle both component and traditional systems
var is_dead = false;

// Check component health if available
if (variable_instance_exists(id, "entity") && 
    variable_struct_exists(entity, "health") && 
    entity.health.current_health <= 0) {
    is_dead = true;
} 
// Otherwise check traditional health system
else if (variable_struct_exists(creature, "current_health") && 
         creature.current_health <= 0) {
    is_dead = true;
}

// If dead by either measure, destroy the instance
if (is_dead) {
    // Reset any active status effects
    if (variable_struct_exists(creature, "status_manager")) {
        creature.status_manager.clear_effects();
    }
    instance_destroy();
    exit;
}