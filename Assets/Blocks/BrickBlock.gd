extends Block 
class_name BrickBlock

enum State
{
	Unbroken,
	Looted,
	Hidden,
}
enum Reward
{
	None,
	Coin,
	OneUpMushroom
}

#---------------------#
# signals             #
#---------------------#
signal OnBroken

#---------------------#
# properties          #
#---------------------#
static var entities : Array
@export var brick_state : State
@export var reward_type : Reward
@export var reward_count : int

#---------------------#
# accessors           #
#---------------------#
func is_active(): brick_state == State.Unbroken
func is_looted(): brick_state == State.Looted
func is_hidden(): brick_state == State.Hidden

#---------------------#
# godot functions     #
#---------------------#
func _ready():
	set_visual_state()
	block_hit.connect(brick_hit)
func _enter_tree():
	entities.append(self)
func _exit_tree():
	entities.erase(self)

# Initializes the visual state
# of the brick block
#
# This is between:
#	Active / Broken / Hidden / Disabled
func set_visual_state(new_state = null):
	if new_state != null:
		brick_state = new_state
	
	match brick_state:
		State.Unbroken:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$Visual2D.play()
			$Collision2D.disabled = false
		State.Looted:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$Visual2D.play()
			$Collision2D.disabled = false
		State.Hidden: 
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$Visual2D.stop()
			$Visual2D.visible = false
			$Collision2D.disabled = false

func brick_hit(actor = null):
	match reward_type:
		Reward.None:
			break_block(actor)
			return
		Reward.Coin:
			if reward_count > 1:
				reward_count -= 1
				if reward_count == 0:
					set_visual_state(State.Looted)
				if $VisualFX/Coin: 
					($VisualFX/Coin as GPUParticles2D).emitting = true
		Reward.OneUpMushroom:
			if reward_count > 1:
				reward_count -= 1
				if reward_count == 0:
					set_visual_state(State.Looted)
				Pickup.spawn(self.global_position, actor, reward_type)
			pass

# Throws an explosion particle fx
# and sets the brick state to broken
# and initializes visual state
#
# (optional) rewards coins if allowed
func break_block(actor = null):
	if $VisualFX/Explosion: 
		($VisualFX/Explosion as GPUParticles2D).emitting = true
	# set visual aspects and disable physics body
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = false
	$Visual2D.stop()
	$Collision2D.disabled = true
	$Timer/Cleanup.start()
	OnBroken.emit()
	entities.erase(self)


# This is hooked with a timer that starts whenever
# state is broken and begins cleanup by calling queue_free()
func _on_cleanup_timeout():
	queue_free()
