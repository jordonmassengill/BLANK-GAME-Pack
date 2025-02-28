// obj_guy Create Event with enhanced health component
event_inherited();

// Create traditional creature properties
creature = create_player_properties();
is_main_player = true;

// NEW: Set up entity with enhanced health component
entity = {};
entity.owner_instance = id;

// Create health component with a death callback
var health_comp = create_health_component(creature.max_health);
health_comp.regen_rate = creature.stats.health_regen;  // Sync regeneration rate
health_comp.set_death_callback(function() {
    // Create death effect
    var death_effect = instance_create_layer(owner_instance.x, owner_instance.y, "Instances", obj_HeroDeath);
    death_effect.sprite_index = sHeroDeath;
    death_effect.image_xscale = owner_instance.sprite_direction;
    
    // Create death screen
    instance_create_layer(0, 0, "Instances", obj_death_screen);
    
    // Schedule instance for destruction
    with(owner_instance) {
        creature.status_manager.clear_effects();
        instance_destroy();
    }
});

add_component(entity, "health", health_comp);

// Animation variables
anim_state = "idle";
sprite_direction = 1;  // 1 for right, -1 for left
anim_blend = 0;  // 0 = idle, 1 = full running
image_speed = 1;
is_grounded = true;

// New falling animation variables
fall_start = true;
fall_frame_timer = 0;
jetpack_active = false;
fall_animation_started = false; 

// Add hit animation variables
hit_timer = 0;
hit_timer_max = 15;

// Updated hit function that uses enhanced health component
hit = function(damage_amount = 0) {
    if (hit_timer <= 0) {
        hit_timer = hit_timer_max;
        sprite_index = sHeroHit;
        image_index = 0;
        image_speed = 1;
        
        // Briefly stop movement when hit
        creature.input.left = false;
        creature.input.right = false;
        
        // Apply damage using the health component
        if (damage_amount > 0 && variable_instance_exists(id, "entity") && 
            variable_struct_exists(entity, "health")) {
            entity.health.take_damage(damage_amount);
            // Sync with old system during transition
            creature.current_health = entity.health.current_health;
        } else if (variable_instance_exists(id, "entity") && 
                  variable_struct_exists(entity, "health")) {
            // If no damage amount was provided (old system), sync
            entity.health.current_health = creature.current_health;
        }
    }
    return true;
}