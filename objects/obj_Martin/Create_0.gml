// obj_Martin Create Event (parent = obj_npc_parent)
event_inherited();

// Create creature properties
creature = create_creature_properties();

// Set Martin's specific stats
creature.max_health = 100;
creature.current_health = 100;
creature.stats.armor = 5;
creature.stats.resistance = 5;

// Keep existing movement properties
walk_speed = 0.5;  // Slow walking speed
direction = choose(0, 180);  // Start walking left or right
sprite_index = sMartinWalk;
image_speed = 1;

// Set initial sprite direction
image_xscale = (direction == 0) ? 1 : -1;