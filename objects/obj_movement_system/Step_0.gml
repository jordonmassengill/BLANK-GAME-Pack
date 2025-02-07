//obj_movement_system Step Event
with(all) {
   if (!variable_instance_exists(id, "creature")) continue;
   
   var _move = 0;
   if (creature.state != PlayerState.KNOCKBACK) {  
       if (creature.input.right) _move = creature.stats.move_speed;
       if (creature.input.left) _move = -creature.stats.move_speed;
       creature.xsp = _move;
   } else {
       creature.xsp *= 0.9;
       
       var control_speed = creature.stats.move_speed * 0.1;
       if (creature.input.right) creature.xsp = min(creature.xsp + control_speed, creature.stats.move_speed);
       if (creature.input.left) creature.xsp = max(creature.xsp - control_speed, -creature.stats.move_speed);
   }

   // Use move_and_collide for horizontal movement
   move_and_collide(creature.xsp, 0, obj_floor);
   
   var _grounded = place_meeting(x, y + 1, obj_floor);
   
   // Handle slopes - like the reference code
   if (_grounded && place_meeting(x, y + abs(creature.xsp) + 1, obj_floor) && creature.ysp >= 0) {
       creature.ysp += abs(creature.xsp) + 1;
   }
   
   if (!_grounded) {
       creature.ysp += GRAVITY;
       if (creature.ysp > MAX_FALL_SPEED) creature.ysp = MAX_FALL_SPEED;
   } else {
       if (creature.state != PlayerState.JUMP_SQUAT) {
           creature.ysp = 0;
           if (creature.state == PlayerState.JUMPING) {
               creature.state = PlayerState.NORMAL;
           }
       }
   }
   
   switch (creature.state) {
       case PlayerState.KNOCKBACK:
           creature.ysp += GRAVITY;
           if (_grounded) {
               creature.state = PlayerState.NORMAL;
               creature.xsp = 0;
               creature.ysp = 0;
           }
           break;
           
       case PlayerState.NORMAL:
           if (_grounded && creature.input.jump && creature.jump_released) {
               creature.state = PlayerState.JUMP_SQUAT;
               creature.jump_squat_timer = JUMP_SQUAT_FRAMES;
               creature.ysp = 0;
               creature.jump_released = false;
           } else if (!_grounded && creature.input.jump && creature.has_jetpack && creature.jetpack_fuel > 0 && creature.jump_released) {
               creature.ysp = max(creature.ysp + JETPACK_FORCE, JETPACK_MAX_SPEED);
               creature.jetpack_fuel--;
           }
           break;
           
       case PlayerState.JUMP_SQUAT:
           creature.jump_squat_timer--;
           if (creature.jump_squat_timer <= 0) {
               creature.state = PlayerState.JUMPING;
               creature.ysp = JUMP_FORCE;
               creature.jump_timer = 0;
           }
           break;
           
       case PlayerState.JUMPING:
           creature.jump_timer++;
           
           if (creature.jump_timer >= MIN_JUMP_FRAMES) {
               if (!creature.input.jump) {
                   creature.ysp *= JUMP_RELEASE_MULTIPLIER;
                   creature.jump_released = true;
               }
           }
           
           if (creature.input.jump && creature.has_jetpack && creature.jetpack_fuel > 0 && creature.jump_released) {
               creature.ysp = max(creature.ysp + JETPACK_FORCE, JETPACK_MAX_SPEED);
               creature.jetpack_fuel--;
           }
           break;
   }
   
   if (!creature.input.jump) {
       creature.jump_released = true;
   }
   
   // Use move_and_collide for vertical movement
   move_and_collide(0, creature.ysp, obj_floor);
}