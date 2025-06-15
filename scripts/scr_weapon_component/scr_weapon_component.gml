/// @function create_weapon_component(owner_entity)
/// @description Creates a component to manage an entity's weapons, firing, and inventory
///              using a two-slot, swap-and-drop system.
/// @param {struct} owner_entity - The parent entity struct (the one with .owner_instance).
function create_weapon_component(owner_entity) {
	return {
		//----------------------------------------------------------------------
		// PROPERTIES
		//----------------------------------------------------------------------
		owner: owner_entity,
		
		// Holds the two weapon slots. Each is either 'undefined' or a weapon struct.
		slots: [undefined, undefined],
		
		// Tracks the active slot index (0 or 1).
		active_slot: 0,

		//----------------------------------------------------------------------
		// METHODS
		//----------------------------------------------------------------------

		/// @function init()
		/// @description Initializes the component.
		init: function() {
			return self;
		},

		/// @function pickup_weapon(weapon_name, weapon_data)
		/// @description The core logic for picking up a new weapon. Returns true on success.
		pickup_weapon: function(weapon_name, weapon_data) {
			// First, check if we already have this weapon in either slot
			if ((self.slots[0] != undefined && self.slots[0].name == weapon_name) ||
			    (self.slots[1] != undefined && self.slots[1].name == weapon_name)) {
				// We already have it, so don't pick it up.
				return false; 
			}

			var new_weapon = { name: weapon_name, data: weapon_data };
			new_weapon.data.cooldown = 0; // Ensure new weapon can be fired immediately

			// Case 1: The first slot is empty.
			if (self.slots[0] == undefined) {
				self.slots[0] = new_weapon;
				self.active_slot = 0; // Equip to slot 1
				show_debug_message("Equipped " + weapon_name + " to Slot 1");
				return true;
			}
			
			// Case 2: The second slot is empty.
			if (self.slots[1] == undefined) {
				self.slots[1] = new_weapon;
				self.active_slot = 1; // Auto-equip to slot 2
				show_debug_message("Equipped " + weapon_name + " to Slot 2");
				return true;
			}
			
			// Case 3: Both slots are full. Drop the active weapon and replace it.
			var weapon_to_drop = self.slots[self.active_slot];
			self.drop_weapon(weapon_to_drop.name, weapon_to_drop.data.pickup_obj_index);
			
			self.slots[self.active_slot] = new_weapon;
			show_debug_message("Dropped " + weapon_to_drop.name + " and equipped " + weapon_name);
			return true;
		},

		/// @function drop_weapon(weapon_name, pickup_obj_index)
		/// @description Spawns a pickup item for the dropped weapon at the player's location.
		drop_weapon: function(weapon_name, pickup_obj_index) {
			// Can't drop a weapon if we don't know what pickup object to create
			if (pickup_obj_index == undefined) return;

			var inst = self.owner.owner_instance;
			var drop = instance_create_layer(inst.x, inst.y, "Instances", pickup_obj_index);
			
			// Set the 1-second pickup cooldown we discussed.
			// The hspeed and vspeed lines are removed so it doesn't "shoot off".
			drop.pickup_cooldown = 60;
		},

		/// @function swap_active_weapon()
		/// @description Toggles the active weapon between slot 0 and 1.
		swap_active_weapon: function() {
			// Can only swap if both slots have weapons
			if (self.slots[0] != undefined && self.slots[1] != undefined) {
				self.active_slot = 1 - self.active_slot; // This toggles between 0 and 1
				show_debug_message("Swapped active weapon to Slot " + string(self.active_slot + 1));
			}
		},
		
		/// @function update()
		/// @description Updates cooldowns for both weapons every frame. Must be called in the owner's Step Event.
		update: function() {
			for (var i = 0; i < 2; i++) {
				if (self.slots[i] != undefined && self.slots[i].data.cooldown > 0) {
					self.slots[i].data.cooldown -= 1;
				}
			}
		},

		/// @function fire(target)
		/// @description Fires the currently equipped weapon. Can optionally take a target for AI aiming.
		fire: function(target = noone) {
			var active_weapon = self.slots[self.active_slot];
			
			if (active_weapon == undefined) return;
			if (active_weapon.data.cooldown > 0) return;
			
			var inst = self.owner.owner_instance;
			var creature = inst.creature;
			var aim_angle = 0;
			var shot_fired = false;
			
			// AIMING LOGIC: Handles both AI and Player
			if (target != noone) {
				// AI Aiming: If a target is provided, aim directly at it.
				aim_angle = point_direction(inst.x, inst.y, target.x, target.y);
			} else {
				// Player Aiming: If no target, use the player's input struct.
				if (creature.input.using_controller) {
					if (abs(creature.input.aim_x) > 0.2 || abs(creature.input.aim_y) > 0.2) {
						aim_angle = point_direction(0, 0, creature.input.aim_x, creature.input.aim_y);
					} else {
						aim_angle = (inst.sprite_direction == 1) ? 0 : 180;
					}
				} else {
					aim_angle = point_direction(inst.x, inst.y, creature.input.target_x, creature.input.target_y);
				}
			}

			// FIRE PROJECTILE
			with(obj_weapon_system) {
				switch(active_weapon.name) {
					case "fireball":    shot_fired = shoot_fireball(inst, aim_angle); break;
					case "bomb":        shot_fired = shoot_bomb(inst, aim_angle); break;
					case "dart":        shot_fired = shoot_dart(inst, aim_angle); break;
					case "waterball":   shot_fired = shoot_waterball(inst, aim_angle); break;
					case "iceball":     shot_fired = shoot_iceball(inst, aim_angle); break;
					case "electro":     shot_fired = shoot_electro(inst, aim_angle); break;
					case "ghoststrike": shot_fired = shoot_ghoststrike(inst, aim_angle); break;
					case "ghostball":   shot_fired = shoot_ghostball(inst, aim_angle); break;
					case "shotgun":     shot_fired = shoot_shotgun(inst, aim_angle); break;
				}
			}
			
			// SET COOLDOWN
			if (shot_fired) {
				var rof = creature.stats.get_rate_of_fire();
				active_weapon.data.cooldown = active_weapon.data.base_cooldown / rof;
			}
		}

	}.init(); // Call init on creation to ensure the struct is ready
}