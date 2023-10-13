extends CharacterBody2D
class_name FireFlower

# Mushroom properties
var spawn_lerp : float = 0

enum FireFlowerState
{
	Spawning,
	Static,
	Looted
}

const enums = preload("res://Assets/Basics/Enums.gd")
const identity = enums.PowerupTypes.FireFlower

var spawn_target : Vector2
var spawn_origin : Vector2
var flower_state : FireFlowerState = FireFlowerState.Spawning

func _enter_tree():
	Level.powerups_lst.append(self)
func _exit_tree():
	Level.powerups_lst.erase(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_state(FireFlowerState.Spawning)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Static object will not process stuff
	if flower_state == FireFlowerState.Static || flower_state == FireFlowerState.Looted: 
		return
	process_state(delta)

func loot_powerup():
	initialize_state(FireFlowerState.Looted)

func initialize_state(new_state = null):
	flower_state = new_state
	match flower_state:
		FireFlowerState.Spawning:
			$collision.disabled = true
			global_position = spawn_origin
			print(spawn_origin)
			spawn_target = spawn_origin + Vector2.UP * 16 # add 16 pixel up
			print(spawn_target)
		FireFlowerState.Static:
			$collision.disabled = false
		FireFlowerState.Looted:
			queue_free()

func process_state(delta):
	match flower_state:
		FireFlowerState.Spawning:
			spawn_lerp += delta * (1 / Level.powerup_spawn_delay)
			global_position = lerp(spawn_origin, spawn_target, spawn_lerp)
			if spawn_lerp > 1:
				initialize_state(FireFlowerState.Static)
		FireFlowerState.Static:
			pass
