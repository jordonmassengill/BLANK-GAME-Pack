// scr_health_system.gml - Updated damage_creature function
function create_health_system() {
    return {
        damage_creature: function(target, amount) {
            // Safety check for target
            if (target == noone || !instance_exists(target)) return 0;
            
            // Round the damage to 2 decimal places
            amount = round(amount * 100) / 100;
            
            var actual_damage = 0;
            
            // Use component system if available
            if (variable_instance_exists(target, "entity") && 
                variable_struct_exists(target.entity, "health")) {
                
                // Apply damage via component
                actual_damage = target.entity.health.take_damage(amount);
                
                // Sync with old system during transition if it exists
                if (variable_instance_exists(target, "creature") && 
                    variable_struct_exists(target.creature, "current_health")) {
                    target.creature.current_health = target.entity.health.current_health;
                }
            }
            // Otherwise use the traditional system
            else if (variable_instance_exists(target, "creature") && 
                     variable_struct_exists(target.creature, "current_health")) {
                
                var old_health = target.creature.current_health;
                target.creature.current_health -= amount;
                
                // Round the new health to 2 decimal places
                target.creature.current_health = round(target.creature.current_health * 100) / 100;
                
                actual_damage = old_health - target.creature.current_health;
            }
            else {
                // Target doesn't have either health system
                return 0;
            }
            
            // Call hit function if it exists
            if (variable_instance_exists(target, "hit")) {
                target.hit(amount);
            }
            
            // Show damage numbers
            if (variable_global_exists("damage_number_system")) {
                global.damage_number_system.add_number(target, amount, false);
            }
            
            return actual_damage;
        },
        
        modify_health: function(target, amount) {
            // Safety check for target
            if (target == noone || !instance_exists(target)) return 0;
            
            var health_change = 0;
            
            // Use component system if available
            if (variable_instance_exists(target, "entity") && 
                variable_struct_exists(target.entity, "health")) {
                
                if (amount > 0) {
                    // Apply healing via component
                    health_change = target.entity.health.heal(amount);
                } else {
                    // Apply damage via component
                    health_change = -target.entity.health.take_damage(-amount);
                }
                
                // Sync with old system during transition if it exists
                if (variable_instance_exists(target, "creature") && 
                    variable_struct_exists(target.creature, "current_health") &&
                    variable_struct_exists(target.creature, "max_health")) {
                    target.creature.current_health = target.entity.health.current_health;
                }
            }
            // Otherwise use the traditional system
            else if (variable_instance_exists(target, "creature") && 
                     variable_struct_exists(target.creature, "current_health") &&
                     variable_struct_exists(target.creature, "max_health")) {
                
                var old_health = target.creature.current_health;
                target.creature.current_health = clamp(old_health + amount, 0, target.creature.max_health);
                health_change = target.creature.current_health - old_health;
            }
            else {
                // Target doesn't have either health system
                return 0;
            }
            
            // Show health change numbers
            if (health_change != 0 && variable_global_exists("damage_number_system")) {
                global.damage_number_system.add_number(target, abs(health_change), health_change > 0);
            }
            
            return health_change;
        },
        
        // Apply life steal - updated to work with both systems
        apply_life_steal: function(attacker, damage_dealt) {
            if (attacker == noone || !instance_exists(attacker)) return;
            
            var life_steal_amount = 0;
            
            // Get life steal amount from component if available
            if (variable_instance_exists(attacker, "entity") && 
                variable_struct_exists(attacker.entity, "stats")) {
                life_steal_amount = attacker.entity.stats.get_life_steal();
            }
            // Otherwise use traditional system
            else if (variable_instance_exists(attacker, "creature") && 
                     variable_struct_exists(attacker.creature, "stats") &&
                     variable_struct_exists(attacker.creature.stats, "get_life_steal")) {
                life_steal_amount = attacker.creature.stats.get_life_steal();
            }
            
            // Apply healing if life steal is available
            if (life_steal_amount > 0) {
                var heal_amount = damage_dealt * life_steal_amount;
                self.modify_health(attacker, heal_amount);
            }
        },
        
        // Draw health bar - updated to support both systems
        draw_health_bar: function(instance_id) {
            // Safety check
            if (instance_id == noone || !instance_exists(instance_id)) return;
            
            // Use component draw function if available
            if (variable_instance_exists(instance_id, "entity") && 
                variable_struct_exists(instance_id.entity, "health") &&
                variable_struct_exists(instance_id.entity.health, "draw_health_bar")) {
                instance_id.entity.health.draw_health_bar();
                return;
            }
            
            // Fall back to traditional draw method
            if (!variable_instance_exists(instance_id, "creature")) return;
            
            var health_width = 40;
            var health_height = 4;
            var health_y_offset = -32;
            
            var xx = instance_id.x - health_width/2;
            var yy = instance_id.y + health_y_offset;
            
            var creature = instance_id.creature;
            
            // Safety check for health properties
            if (!variable_struct_exists(creature, "current_health") || 
                !variable_struct_exists(creature, "max_health")) return;
                
            var health_percent = creature.current_health / creature.max_health;
            
            // Draw background
            draw_set_color(c_red);
            draw_rectangle(xx, yy, xx + health_width, yy + health_height, false);
            
            // Draw health
            draw_set_color(c_lime);
            draw_rectangle(xx, yy, xx + (health_width * health_percent), yy + health_height, false);
            
            // Draw ticks
            draw_set_color(c_black);
            for(var i = 50; i < creature.max_health; i += 50) {
                var tick_x = xx + (health_width * (i/creature.max_health));
                draw_line(tick_x, yy, tick_x, yy + health_height);
            }
            
            // Draw border
            draw_rectangle(xx, yy, xx + health_width, yy + health_height, true);
            
            draw_set_color(c_white);
        }
    };
}