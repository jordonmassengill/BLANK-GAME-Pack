// scr_shop

// Function to create a shop inventory
function create_shop_inventory() {
    var shop = ds_map_create();
    shop[? "items"] = ds_list_create();
    return shop;
}

// Function to add an item to the shop inventory
function shop_add_item(shop, item_name, price, item_object, description) {
    var item = ds_map_create();
    item[? "name"] = item_name;
    item[? "price"] = price;
    item[? "object"] = item_object;
    item[? "description"] = description;
    ds_list_add(shop[? "items"], item);
}

// Function to create a shop menu
function create_shop_menu() {
    var menu = ds_map_create();
    menu[? "active"] = false; // Whether the menu is currently open
    menu[? "selected_item"] = 0; // Index of the currently selected item
    return menu;
}

function shop_menu_update(menu, shop, player) {
    if (menu[? "active"]) {
        // Handle menu navigation and item selection
        if (player.creature.input.menu_up) {
            menu[? "selected_item"] = max(0, menu[? "selected_item"] - 1);
        }
        if (player.creature.input.menu_down) {
            menu[? "selected_item"] = min(ds_list_size(shop[? "items"]) - 1, menu[? "selected_item"] + 1);
        }

        // Handle item purchase
        if (player.creature.input.menu_select) {
            var selected_item = ds_list_find_value(shop[? "items"], menu[? "selected_item"]);
            if (player.creature.currency >= selected_item[? "price"]) {
                // Debug: Check the selected item's object
                show_debug_message("Creating object: " + string(selected_item[? "object"]));

                // Ensure the object is valid
                if (selected_item[? "object"] != noone && selected_item[? "object"] != undefined) {
                    instance_create(player.x, player.y, selected_item[? "object"]);
                    player.creature.currency -= selected_item[? "price"];
                } else {
                    show_debug_message("Invalid object for selected item!");
                }
            }
        }

        // Handle exiting the shop menu
        if (player.creature.input.menu_back) {
            menu[? "active"] = false; // Deactivate the shop menu
            instance_activate_all(); // Reactivate all instances
            show_debug_message("Shop menu closed!"); // Debug message
        }
    }
}

// Function to draw the shop menu
function shop_menu_draw(menu, shop, x, y) {
    if (menu[? "active"]) {
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_text(x, y - 64, "Shop Menu");

        var item_y = y - 32;
        for (var i = 0; i < ds_list_size(shop[? "items"]); i++) {
            var item = ds_list_find_value(shop[? "items"], i);
            var item_text = item[? "name"] + " - " + string(item[? "price"]) + " gold";
            if (i == menu[? "selected_item"]) {
                draw_set_color(c_yellow);
            } else {
                draw_set_color(c_white);
            }
            draw_text(x, item_y, item_text);
            item_y += 16;
        }

        draw_set_halign(fa_left);
    }
}