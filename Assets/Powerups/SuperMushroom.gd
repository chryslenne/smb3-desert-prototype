extends CharacterBody2D
class_name SuperMushroom

# Mushroom properties
@export_range(0, 1000, 5) var move_speed : float = 85
@export_range(-1000, 0, 5) var fall_speed : float = -200
@export_range(200, 2000, 10) var vertical_delta : float = 1000
var vertical_speed : float
var horizontal_speed : float
var h_input : int = 0
var spawn_lerp : float = 0

enum ShroomState
{
	Spawning,
	Moving,
	Static,
	Looted
}

enum GroundState
{
	Grounded,
	Falling
}

const enums = preload("res://Assets/Basics/Enums.gd")
const identity = enums.PowerupTypes.SuperMushroom

var ground_state : GroundState
var spawn_target : Vector2
var spawn_origin : Vector2
var shroom_state : ShroomState = ShroomState.Spawning

func _enter_tree():
	Level.powerups_lst.append(self)
func _exit_tree():
	Level.powerups_lst.erase(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	$"ground-checker".exceptions.append(self)
	initialize_state(ShroomState.Spawning)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Static object will not process stuff
	if shroom_state == ShroomState.Static || shroom_state == ShroomState.Looted: 
		return
	
	process_state(delta)
	process_ground_state()

func loot_powerup():
	initialize_state(ShroomState.Looted)

func hit_by(body):
	if body.global_position.x > self.global_position.x:
		h_input = -1
	elif self.global_position.x > body.global_position.x:
		h_input = 1
	$Casters/right.enabled = h_input > 0
	$Casters/left.enabled = h_input < 0
func move_direction_left():
	h_input = -1
	$Casters/right.enabled = h_input > 0
	$Casters/left.enabled = h_input < 0
func move_direction_right():
	h_input = 1
	$Casters/right.enabled = h_input > 0
	$Casters/left.enabled = h_input < 0

func random_direction():
	var result = randi_range(-1, 1)
	return random_direction() if result == 0 else result

func initialize_state(new_state = null):
	shroom_state = new_state
	match shroom_state:
		ShroomState.Spawning:
			if h_input == 0:
				h_input = random_direction()
			$collision.disabled = true
			$"ground-checker".process_mode = Node.PROCESS_MODE_DISABLED
			global_position = spawn_origin
			print(spawn_origin)
			spawn_target = spawn_origin + Vector2.UP * 16 # add 16 pixel up
			print(spawn_target)
		ShroomState.Moving:
			$"ground-checker".process_mode = Node.PROCESS_MODE_INHERIT
			$collision.disabled = false
		ShroomState.Static:
			$"ground-checker".process_mode = Node.PROCESS_MODE_DISABLED
			$collision.disabled = false
		ShroomState.Looted:
			queue_free()

func process_state(delta):
	match shroom_state:
		ShroomState.Spawning:
			spawn_lerp += delta * (1 / Level.powerup_spawn_delay)
			global_position = lerp(spawn_origin, spawn_target, spawn_lerp)
			if spawn_lerp > 1:
				initialize_state(ShroomState.Moving)
		ShroomState.Moving:
			match h_input:
				1: 
					if $Casters/right.get_collider(): 
						hit_by($Casters/right.get_collider())
						move_direction_left()
				_: 
					if $Casters/left.get_collider(): 
						hit_by($Casters/left.get_collider())
						move_direction_right()
			
			horizontal_speed = h_input
			velocity.x = horizontal_speed * move_speed
			match ground_state:
				GroundState.Grounded:
					velocity.y = 0
				GroundState.Falling:
					velocity.y = move_toward(velocity.y, -fall_speed, delta * vertical_delta)
			move_and_slide()
		ShroomState.Static:
			pass

func process_ground_state():
	var is_grounded = $"ground-checker".is_grounded
	
	if ground_state == GroundState.Grounded && !is_grounded:
		ground_state = GroundState.Falling
	elif ground_state == GroundState.Falling && is_grounded:
		ground_state = GroundState.Grounded
