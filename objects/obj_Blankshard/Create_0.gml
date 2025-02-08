// Create Event for obj_Blankshard (parent = obj_pickup_parent)
sharditem = {
    name: "Blank Shard",
    color: c_dkgray,  // Darker gray to differentiate from full orb
    type: "shard",
    description: "Collect 5 to form a Blank Orb"
}

function apply_effect(target) {
    if (variable_instance_exists(target, "creature") && 
        variable_struct_exists(target.creature, "inventory")) {
        
        // Count existing shards in inventory
        var shard_count = 0;
        var first_shard_slot = -1;
        var items = target.creature.inventory.items;
        
        for(var i = 0; i < array_length(items); i++) {
            if (items[i] != undefined && items[i].type == "shard") {
                shard_count++;
                if (first_shard_slot == -1) first_shard_slot = i;
            }
        }
        
        // Add this new shard
        target.creature.inventory.add_item(sharditem);
        shard_count++;
        
        // If we now have 5 shards
        if (shard_count >= 5) {
            // Remove 5 shards
            var shards_removed = 0;
            var i = 0;
            while (shards_removed < 5 && i < array_length(items)) {
                if (items[i] != undefined && items[i].type == "shard") {
                    target.creature.inventory.remove_item(i);
                    shards_removed++;
                }
                i++;
            }
            
            // Create blank orb
            var blank_orb = {
                name: "Blank Orb",
                color: c_gray,
                type: "blank",
                description: "Can be exchanged for any orb type at an exchange platform"
            };
            
            // Add the blank orb to inventory
            target.creature.inventory.add_item(blank_orb);
        }
        
        return true;
    }
    return false;
}