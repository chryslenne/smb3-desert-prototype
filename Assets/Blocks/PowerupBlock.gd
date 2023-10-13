extends StaticBody2D 
class_name PowerupBlock

enum LootState
{
	Unlooted,
	Looted,
	Hidden,
	Disabled
}

#---------------------#
# signals             #
#---------------------#
signal onLooted

#---------------------#
# properties          #
#---------------------#
const enums = preload("res://Assets/Basics/Enums.gd")
var loot_state : LootState
@export var stored_pup : enums.PowerupTypes

#---------------------#
# accessors           #
#---------------------#
func is_active(): return loot_state == LootState.Unlooted
func is_looted(): return loot_state == LootState.Looted
func is_hidden(): return loot_state == LootState.Hidden
func is_disabled(): return loot_state == LootState.Disabled

#---------------------#
# godot functions     #
#---------------------#
func _enter_tree():
	Level.prize_blocks.append(self)
func _exit_tree():
	Level.prize_blocks.erase(self)
func _ready():
	set_visual_state()

# Initializes the visual state
# of the prize block
#
# This is between:
#	Looted / Unlooted / Hidden / Disabled
func set_visual_state():
	match loot_state:
		LootState.Unlooted:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$visuals.play("unlooted")
			$collision.disabled = false
		LootState.Looted:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$visuals.play("looted")
			$collision.disabled = false
			onLooted.emit()
		LootState.Hidden: 
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$visuals.visible = false
			$collision.disabled = false
		LootState.Disabled:
			process_mode = PROCESS_MODE_DISABLED
			visible = false
			$visuals.visible = true
			$collision.disabled = true

# Loots the powerup inside the block
# and turns the block into an unusable state
func loot_block(actor = null):
	if is_looted():
		return
	loot_state = LootState.Looted
	set_visual_state()
	spawn_powerup(actor)

# Spawns a powerup
# this uses an AutoLoaded script: Level.gd
#
# Only gets called once the block is looted
func spawn_powerup(actor):
	match stored_pup:
		enums.PowerupTypes.SuperMushroom:
			var instance = Level.preloaded_powerups[enums.PowerupTypes.SuperMushroom].instantiate()
			instance.spawn_origin = self.global_position
			Level.current.get_instance_container().add_child(instance)
			if actor != null && actor is PhysicsBody2D:
				instance.hit_by(actor)
		enums.PowerupTypes.FireFlower:
			var instance = Level.preloaded_powerups[enums.PowerupTypes.FireFlower].instantiate()
			instance.spawn_origin = self.global_position
			Level.current.get_instance_container().add_child(instance)
		enums.PowerupTypes.SuperLeaf:
			pass
		enums.PowerupTypes.TanookiSuit:
			pass
		enums.PowerupTypes.PWing:
			pass
		enums.PowerupTypes.FrogSuit:
			pass
		enums.PowerupTypes.HammerSuit:
			pass
		enums.PowerupTypes.Starman:
			pass
