extends StaticBody2D 
class_name ItemBlock

enum PrizeType
{
	SuperMushroom,
	FireFlower,
	SuperLeaf,
	OneUpMushroom,
	Starman
}
enum State
{
	Unlooted,
	Looted,
	Hidden,
	Disabled
}

#---------------------#
# signals             #
#---------------------#
signal OnLooted

#---------------------#
# properties          #
#---------------------#
static var entities : Array
const enums = preload("res://Assets/Basics/Enums.gd")
@export var loot_state : State
@export var stored_pup : PrizeType

#---------------------#
# accessors           #
#---------------------#
func is_active(): 
	return loot_state == State.Unlooted
func is_looted(): 
	return loot_state == State.Looted
func is_hidden(): 
	return loot_state == State.Hidden
func is_disabled(): 
	return loot_state == State.Disabled

#---------------------#
# godot functions     #
#---------------------#
func _ready():
	set_visual_state()

func _notification(what):
	match what:
		NOTIFICATION_POSTINITIALIZE:
			entities.append(self)
		NOTIFICATION_PREDELETE:
			entities.erase(self)

# Initializes the visual state
# of the prize block
#
# This is between:
#	Looted / Unlooted / Hidden / Disabled
func set_visual_state():
	match loot_state:
		State.Unlooted:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$Visual2D.play("unlooted")
			$Collision2D.disabled = false
		State.Looted:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$Visual2D.play("looted")
			$Collision2D.disabled = false
			OnLooted.emit()
		State.Hidden: 
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$Visual2D.visible = false
			$Collision2D.disabled = false
		State.Disabled:
			process_mode = PROCESS_MODE_DISABLED
			visible = false
			$Visual2D.visible = true
			$Collision2D.disabled = true

# Loots the powerup inside the block
# and turns the block into an unusable state
func loot_block(actor = null):
	if is_looted():
		return
	loot_state = State.Looted
	set_visual_state()
	spawn_powerup(actor)

# Spawns a powerup
# this uses an AutoLoaded script: Level.gd
#
# Only gets called once the block is looted
func spawn_powerup(actor):
	var instance = Level.preloaded_assets[stored_pup].instantiate()
	var instanceBody = instance.get_node("Body")
	
	match stored_pup:
		PrizeType.SuperMushroom:
			instanceBody.spawn_origin = self.global_position
			Level.current.get_instance_container().add_child(instance)
			if actor != null && actor is PhysicsBody2D:
				instanceBody.hit_by(actor)
		PrizeType.FireFlower:
			instanceBody.spawn_origin = self.global_position
			Level.current.get_instance_container().add_child(instance)
		PrizeType.SuperLeaf:
			instance.global_position = self.global_position
			Level.current.get_instance_container().add_child(instance)
		PrizeType.OneUpMushroom:
			instanceBody.spawn_origin = self.global_position
			Level.current.get_instance_container().add_child(instance)
			if actor != null && actor is PhysicsBody2D:
				instanceBody.hit_by(actor)
		PrizeType.Starman:
			instanceBody.spawn_origin = self.global_position
			Level.current.get_instance_container().add_child(instance)
			if actor != null && actor is PhysicsBody2D:
				instanceBody.hit_by(actor)
