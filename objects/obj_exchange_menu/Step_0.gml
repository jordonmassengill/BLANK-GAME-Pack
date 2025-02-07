// obj_exchange_menu Step Event
if (!menu_active) exit;

var player = instance_find(obj_player_creature_parent, 0);
if (!player) exit;

// Handle left/right to switch between columns
if (player.creature.input.right && cursor_position == "inventory") {
    cursor_position = "options";
    selected_item = 0;
}
if (player.creature.input.left && cursor_position == "options") {
    cursor_position = "inventory";
    selected_item = 0;
}

// Handle up/down navigation
if (player.creature.input.menu_up) {
    if (cursor_position == "inventory") {
        // Start from current position and move up
        selected_item--;
        // Keep moving up until we find a valid slot or reach the top
        while (selected_item >= 0 && player.creature.inventory.items[selected_item] == undefined) {
            selected_item--;
        }
        // If we went past the top, wrap to bottom
        if (selected_item < 0) {
            // Find the last valid slot from the bottom
            selected_item = array_length(player.creature.inventory.items) - 1;
            while (selected_item >= 0 && player.creature.inventory.items[selected_item] == undefined) {
                selected_item--;
            }
        }
    } else {
        // Options column stays the same
        selected_item--;
        if (selected_item < 0) selected_item = array_length(orb_types) - 1;
    }
}

if (player.creature.input.menu_down) {
    if (cursor_position == "inventory") {
        // Start from current position and move down
        selected_item++;
        // Keep moving down until we find a valid slot or reach the bottom
        while (selected_item < array_length(player.creature.inventory.items) && 
               player.creature.inventory.items[selected_item] == undefined) {
            selected_item++;
        }
        // If we went past the bottom, wrap to top
        if (selected_item >= array_length(player.creature.inventory.items)) {
            // Find the first valid slot from the top
            selected_item = 0;
            while (selected_item < array_length(player.creature.inventory.items) && 
                   player.creature.inventory.items[selected_item] == undefined) {
                selected_item++;
            }
        }
    } else {
        // Options column stays the same
        selected_item++;
        if (selected_item >= array_length(orb_types)) selected_item = 0;
    }
}

// Handle selection
if (player.creature.input.menu_select) {
    if (cursor_position == "inventory") {
        // Toggle selection of inventory slot
        var slot_index = selected_item;
        var array_index = array_get_index(selected_inventory_slots, slot_index);
        
        if (array_index == -1 && player.creature.inventory.items[slot_index] != undefined) {
            // Add to selected slots
            array_push(selected_inventory_slots, slot_index);
        } else if (array_index != -1) {
            // Remove from selected slots
            array_delete(selected_inventory_slots, array_index, 1);
        }
    } else {
        // Convert all selected orbs to the chosen type
        var new_type = orb_types[selected_item];
        for (var i = 0; i < array_length(selected_inventory_slots); i++) {
            var slot = selected_inventory_slots[i];
            var new_orb = {
                name: new_type.name,
                color: new_type.color,
                type: new_type.type,
                description: "Exchanged orb of " + new_type.type + " type."
            };
            player.creature.inventory.items[slot] = new_orb;
        }
        // Clear selections
        selected_inventory_slots = [];
    }
}

// Handle back/cancel
if (player.creature.input.menu_back) {
    if (array_length(selected_inventory_slots) > 0) {
        // Clear selections if we have any
        selected_inventory_slots = [];
    } else {
        // Exit menu if no selections
        menu_active = false;
        instance_activate_all();
    }
}