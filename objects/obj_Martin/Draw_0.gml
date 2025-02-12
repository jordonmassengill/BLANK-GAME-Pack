// obj_Martin Draw Event
draw_self();

// Draw health bar if creature exists
if (variable_instance_exists(id, "creature")) {
    global.health_system.draw_health_bar(id);
}