extends CharacterBody2D
class_name FlowerPickup2D

signal flower_despawn
# Mushroom properties
var spawn_lerp : float = 0

enum FlowerState
{
	Spawning,
	Static,
	Despawning
}

var spawn_target : Vector2
var spawn_origin : Vector2
var flower_state : FlowerState = FlowerState.Spawning

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_state(FlowerState.Spawning)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Static object will not process stuff
	if flower_state == FlowerState.Static || flower_state == FlowerState.Despawning: 
		return
	process_state(delta)

func state_despawn():
	initialize_state(FlowerState.Despawning)

func initialize_state(new_state = null):
	flower_state = new_state
	match flower_state:
		FlowerState.Spawning:
			$CollisionShape2D.disabled = true
			global_position = spawn_origin
			spawn_target = spawn_origin + Vector2.UP * 16 # add 16 pixel up
		FlowerState.Static:
			$CollisionShape2D.disabled = false
		FlowerState.Despawning:
			flower_despawn.emit()
			queue_free()

func process_state(delta):
	match flower_state:
		FlowerState.Spawning:
			@warning_ignore("integer_division")
			spawn_lerp += delta * (1 / Level.powerup_spawn_delay)
			global_position = lerp(spawn_origin, spawn_target, spawn_lerp)
			if spawn_lerp > 1:
				initialize_state(FlowerState.Static)
		FlowerState.Static:
			pass
