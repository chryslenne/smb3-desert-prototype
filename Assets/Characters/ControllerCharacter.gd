extends CharacterBody2D

enum GroundState
{
	Grounded,
	Jumping,
	JumpingToFalling,
	Falling,
}

# Character properties
@export_range(0, 1000, 5) var move_speed : float = 85
@export_range(0, 10, 0.1) var run_speed : float = 2
@export_range(1000, 0, 5) var jump_power : float = 200
@export_range(-1000, 0, 5) var fall_speed : float = -200
@export_range(200, 2000, 10) var vertical_delta : float = 1000
var vertical_speed : float
var horizontal_speed : float

# Character input & states
var h_input : int
var v_input : int
var jump_input : bool
var run_input : bool
@export var ground_state : GroundState = GroundState.Grounded

# ==================
# For initialization
func _enter_tree():
	# appends the current collision body to the raycasters as part of
	# the exception for raycasting
	$ground_checker.exceptions.append(self)
	$roof_checker.exceptions.append(self)

# ==================
# Receives player input here
func _input(event):
	if event.is_action("move_right"):
		if event.is_pressed() && !event.is_echo():
			h_input += 1
		elif event.is_released() && !event.is_echo():
			h_input -= 1
	if event.is_action("move_left"):
		if event.is_pressed() && !event.is_echo():
			h_input -= 1
		elif event.is_released() && !event.is_echo():
			h_input += 1
	
	if event.is_action("run"):
		if event.is_pressed():
			run_input = true
		elif event.is_released():
			run_input = false
	
	if event.is_action("jump"):
		if event.is_pressed() && !event.is_echo():
			jump_input = true
		elif event.is_released() && !event.is_echo():
			jump_input = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_movements(delta)
	process_ground_state()

func process_movements(delta):
	if h_input > 0:
		$states.scale.x = 1
	elif h_input < 0:
		$states.scale.x = -1
	horizontal_speed = move_toward(horizontal_speed, h_input, delta * 3)
	velocity.x = horizontal_speed * (move_speed * run_speed if run_input else move_speed)
	match ground_state:
		GroundState.Grounded:
			velocity.y = 0
		GroundState.Jumping:
			velocity.y = -jump_power
		GroundState.JumpingToFalling:
			velocity.y = move_toward(velocity.y, -fall_speed, vertical_delta * delta)
		GroundState.Falling:
			velocity.y = -fall_speed
	move_and_slide()

func process_ground_state():
	var is_grounded = $ground_checker.is_grounded
	var is_roofed = $roof_checker.is_roofed
	
	if is_grounded && ground_state == GroundState.Grounded && jump_input:
		$"properties/jump-duration".start()
		ground_state = GroundState.Jumping
	elif ground_state == GroundState.Jumping && !jump_input:
		ground_state = GroundState.JumpingToFalling
	elif !is_grounded && ground_state == GroundState.Grounded:
		ground_state = GroundState.JumpingToFalling
	elif ground_state == GroundState.JumpingToFalling && velocity.y == fall_speed:
		ground_state = GroundState.Falling
	elif is_roofed && (ground_state == GroundState.Jumping || ground_state == GroundState.Falling):
		ground_state = GroundState.Falling
	elif ground_state == GroundState.JumpingToFalling && is_grounded:
		$"properties/jump-duration".stop()
		ground_state = GroundState.Grounded
		jump_input = false
	elif ground_state == GroundState.Falling && is_grounded:
		$"properties/jump-duration".stop()
		ground_state = GroundState.Grounded
		jump_input = false
	
func _on_jumpduration_timeout():
	ground_state = GroundState.JumpingToFalling
