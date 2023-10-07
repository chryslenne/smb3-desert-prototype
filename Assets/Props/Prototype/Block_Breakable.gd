extends RigidBody2D

signal onBreakableState

@export var is_broken : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# for debugging purpose
	if is_broken:
		break_block()
		is_broken = false

func break_block():	
	if has_node("visualfx/explosion"): 
		(get_node("visualfx/explosion") as GPUParticles2D).emitting = true
	
	$visuals.visible = false
	$collision.disabled = true
	
	onBreakableState.emit();

func _on_body_entered(body):
	if body.has_node("properties/can_break"): break_block()
