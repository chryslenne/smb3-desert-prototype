extends StaticBody2D 
class_name BrickBlock

enum BrickState
{
	Active,
	Broken,
	Hidden,
	Disabled
}

#---------------------#
# signals             #
#---------------------#
signal OnBroken

#---------------------#
# properties          #
#---------------------#
static var entities : Array
var brick_state : BrickState
var can_reward_coin : bool
var amt_coin_reward : int = 100

#---------------------#
# accessors           #
#---------------------#
func is_active(): brick_state == BrickState.Active
func is_broken(): brick_state == BrickState.Broken
func is_hidden(): brick_state == BrickState.Hidden

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
# of the brick block
#
# This is between:
#	Active / Broken / Hidden / Disabled
func set_visual_state():
	match brick_state:
		BrickState.Active:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$Visual2D.play()
			$Collision2D.disabled = false
		BrickState.Broken:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = false
			$Visual2D.stop()
			$Collision2D.disabled = true
			$Timer/Cleanup.start()
			OnBroken.emit()
		BrickState.Hidden: 
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$Visual2D.stop()
			$Visual2D.visible = false
			$Collision2D.disabled = false
		BrickState.Disabled:
			process_mode = PROCESS_MODE_DISABLED
			visible = false
			$Visual2D.play()
			$Visual2D.visible = true
			$Collision2D.disabled = true

# Throws an explosion particle fx
# and sets the brick state to broken
# and initializes visual state
#
# (optional) rewards coins if allowed
func break_block(actor = null):	
	if $VisualFX/Explosion: 
		($VisualFX/Explosion as GPUParticles2D).emitting = true
	
	brick_state = BrickState.Broken
	set_visual_state()
	
	if can_reward_coin:
		# amt_coin_reward
		($VisualFX/Coin as GPUParticles2D).emitting = true

# This is hooked with a timer that starts whenever
# state is broken and begins cleanup by calling queue_free()
func _on_cleanup_timeout():
	queue_free()
