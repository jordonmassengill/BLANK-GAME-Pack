// The new, simplified Create Event for obj_Lifeupgrade
event_inherited(); // Inherits from obj_pickup_parent

// This is all the logic we need now!
function apply_effect(target) {
    // Just tell the target's inventory to add a "life_orb"
    // The inventory component itself knows what that means.
    return target.entity.inventory.add_item("orb_blank");
}