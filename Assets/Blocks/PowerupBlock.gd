extends StaticBody2D 
class_name PowerupBlock

#---------------------#
# signals             #
#---------------------#
signal onLooted

#---------------------#
# properties          #
#---------------------#
const enums = preload("res://Assets/Basics/Enums.gd")
@export var loot_state : enums.BrickPrizeState
@export var stored_pup : enums.BrickPrizeType

#---------------------#
# accessors           #
#---------------------#
func is_active(): 
	return loot_state == enums.BrickPrizeState.Unlooted
func is_looted(): 
	return loot_state == enums.BrickPrizeState.Looted
func is_hidden(): 
	return loot_state == enums.BrickPrizeState.Hidden
func is_disabled(): 
	return loot_state == enums.BrickPrizeState.Disabled

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
		enums.BrickPrizeState.Unlooted:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$visuals.play("unlooted")
			$collision.disabled = false
		enums.BrickPrizeState.Looted:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$visuals.play("looted")
			$collision.disabled = false
			onLooted.emit()
		enums.BrickPrizeState.Hidden: 
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$visuals.visible = false
			$collision.disabled = false
		enums.BrickPrizeState.Disabled:
			process_mode = PROCESS_MODE_DISABLED
			visible = false
			$visuals.visible = true
			$collision.disabled = true

# Loots the powerup inside the block
# and turns the block into an unusable state
func loot_block(actor = null):
	if is_looted():
		return
	loot_state = enums.BrickPrizeState.Looted
	set_visual_state()
	spawn_powerup(actor)

# Spawns a powerup
# this uses an AutoLoaded script: Level.gd
#
# Only gets called once the block is looted
func spawn_powerup(actor):
	var instance = Level.preloaded_powerups[stored_pup].instantiate()
	var instanceBody = instance.get_node("Body")
	
	match stored_pup:
		enums.BrickPrizeType.SuperMushroom:
			instanceBody.spawn_origin = self.global_position
			Level.current.get_instance_container().add_child(instance)
			if actor != null && actor is PhysicsBody2D:
				instanceBody.hit_by(actor)
		enums.BrickPrizeType.FireFlower:
			instanceBody.spawn_origin = self.global_position
			Level.current.get_instance_container().add_child(instance)
		enums.BrickPrizeType.SuperLeaf:
			instance.global_position = self.global_position
			Level.current.get_instance_container().add_child(instance)
		enums.BrickPrizeType.OneUpMushroom:
			instanceBody.spawn_origin = self.global_position
			Level.current.get_instance_container().add_child(instance)
			if actor != null && actor is PhysicsBody2D:
				instanceBody.hit_by(actor)
