// obj_Martin Step Event
event_inherited();

// Move
x += lengthdir_x(walk_speed, direction);

// Check for collisions or edges
if (place_meeting(x + lengthdir_x(walk_speed, direction), y, obj_floor)) {
    direction = direction == 0 ? 180 : 0;  // Turn around
    image_xscale = (direction == 0) ? 1 : -1;  // Flip sprite
}

// Change direction randomly sometimes
if (random(1) < 0.005) {  // 0.5% chance per step to turn around
    direction = direction == 0 ? 180 : 0;
    image_xscale = (direction == 0) ? 1 : -1;
}