// scr_damage_types
// Damage Type Enum
enum DAMAGE_TYPE {
    PHYSICAL,
    MAGICAL,
    DOT,    // Damage Over Time
    AOE     // Area of Effect
}

// Create base projectile properties with damage type and element
function create_projectile_properties(base_damage, damage_type, element_type) {
    return {
        base_damage: base_damage,
        damage_type: damage_type,
        element_type: element_type,
        
        // Status effect parameters
        dot_damage: 0,
        dot_duration: 0,
        dot_tick_rate: 60,  // Default 1 second between ticks
        movement_slow: 0,
        fire_rate_slow: 0,
        stun_duration: 0,
        armor_pierce: 0
    };
}

function calculate_damage(amount, damage_type, target, element_type, attacker) {
    
    var final_damage = amount;
    
    // Apply attacker's damage stats based on damage type
    if (variable_instance_exists(attacker, "creature")) {
        switch(damage_type) {
            case DAMAGE_TYPE.PHYSICAL:
                var phys_mult = attacker.creature.stats.get_physical_damage();
                final_damage *= phys_mult;
                // Round after multiplication
                final_damage = round(final_damage * 100) / 100;
                break;
            case DAMAGE_TYPE.MAGICAL:
                var magic_mult = attacker.creature.stats.get_magical_damage();
                final_damage *= magic_mult;
                // Round after multiplication
                final_damage = round(final_damage * 100) / 100;
                break;
        }
    }
    
    // Get armor value
    var armor = target.creature.stats.get_armor();
    
    // Apply armor reduction
    switch(damage_type) {
        case DAMAGE_TYPE.PHYSICAL:
        case DAMAGE_TYPE.MAGICAL:
            var damage_mult = (1 - (armor / 100));
            final_damage *= damage_mult;
            // Round after armor calculation
            final_damage = round(final_damage * 100) / 100;
            break;
        case DAMAGE_TYPE.DOT:
            var damage_mult = (1 - (armor / 150));
            final_damage *= damage_mult;
            final_damage = round(final_damage * 100) / 100;
            break;
        case DAMAGE_TYPE.AOE:
            var damage_mult = (1 - (armor / 50));
            final_damage *= damage_mult;
            final_damage = round(final_damage * 100) / 100;
            break;
    }
    
    return final_damage;
}