extends StaticBody2D 
class_name BrickBlock

signal onBroken

enum BrickState
{
	Active,
	Broken,
	Hidden,
	Disabled
}

var brick_state : BrickState
var can_reward_coin : bool
var amt_coin_reward : int = 100

func is_active(): brick_state == BrickState.Active
func is_broken(): brick_state == BrickState.Broken
func is_hidden(): brick_state == BrickState.Hidden

func _enter_tree():
	Level.level_bricks.append(self)
func _exit_tree():
	Level.level_bricks.erase(self)

func _ready():
	set_visual_state()

func set_visual_state():
	match brick_state:
		BrickState.Active:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$collision.disabled = false
		BrickState.Broken:
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = false
			$collision.disabled = true
			onBroken.emit()
			$cleanup.start()
		BrickState.Hidden: 
			process_mode = Node.PROCESS_MODE_INHERIT
			visible = true
			$visuals.visible = false
			$collision.disabled = false
		BrickState.Disabled:
			process_mode = PROCESS_MODE_DISABLED
			visible = false
			$visuals.visible = true
			$collision.disabled = true

func break_block(actor = null):	
	if has_node("visualfx/explosion"): 
		($visualfx/explosion as GPUParticles2D).emitting = true
	
	brick_state = BrickState.Broken
	set_visual_state()
	
	if can_reward_coin:
		# amt_coin_reward
		($visualfx/coin as GPUParticles2D).emitting = true

func _on_cleanup_timeout():
	queue_free()
