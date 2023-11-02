extends Block 
class_name ItemBlock

enum Reward
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
@export var loot_state : State
@export var stored_reward : Reward

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
	block_hit.connect(loot_block)

func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE:
			entities.append(self)
		NOTIFICATION_EXIT_TREE:
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
	Pickup.spawn(self.global_position, actor, stored_reward)
