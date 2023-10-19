extends CharacterBody2D

enum GroundState
{
	Grounded,
	Jumping,
	JumpingSmall,
	JumpingToFalling,
	Falling,
}

#---------------------#
# signals             #
#---------------------#
signal onPlayerDeath

#---------------------#
# properties          #
#---------------------#
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
var s_input : bool
var jump_input : bool
var pipe_entry : Dictionary
var run_input : bool
var ground_state : GroundState = GroundState.Grounded
var active_state

# ==================
# For initialization
func _enter_tree():
	# appends the current collision body to the raycasters as part of
	# the exception for raycasting
	$ground_checker.exceptions.append(self)
	$roof_checker.exceptions.append(self)
	$roof_checker.main_body = self
	
	# for pipe detectors
	# disable detection to self
	$pipe_detector/N.add_exception(self)
	$pipe_detector/S.add_exception(self)
	$pipe_detector/E.add_exception(self)
	$pipe_detector/W.add_exception(self)

# ==================
# For start
func _ready():
	active_state = $"states/small-mario"

# ==================
# Receives player input here
func _input(event):
	if event.is_action("move_right"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry["e"] = true
			h_input += 1
		elif event.is_released() && !event.is_echo():
			pipe_entry["e"] = false
			h_input -= 1
	if event.is_action("move_left"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry["w"] = true
			h_input -= 1
		elif event.is_released() && !event.is_echo():
			pipe_entry["w"] = false
			h_input += 1
	if event.is_action("move_up"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry["n"] = true
			v_input -= 1
		elif event.is_released() && !event.is_echo():
			pipe_entry["n"] = false
			v_input += 1
	if event.is_action("move_down"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry["s"] = true
			v_input += 1
		elif event.is_released() && !event.is_echo():
			pipe_entry["s"] = false
			v_input -= 1
	
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
	
	if event.is_action("special"):
		if event.is_pressed() && !event.is_echo():
			s_input = true
		elif event.is_released() && !event.is_echo():
			s_input = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_special_attacks()
	process_movements(delta)
	process_ground_state()
	process_pipes_entry()

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
		GroundState.JumpingSmall:
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
	elif ground_state == GroundState.Jumping && !jump_input || ground_state == GroundState.JumpingSmall:
		ground_state = GroundState.JumpingToFalling
	elif !is_grounded && ground_state == GroundState.Grounded:
		ground_state = GroundState.JumpingToFalling
	elif ground_state == GroundState.JumpingToFalling && velocity.y == fall_speed:
		ground_state = GroundState.Falling
	elif is_roofed && (ground_state == GroundState.Jumping || ground_state == GroundState.JumpingToFalling):
		ground_state = GroundState.Falling
	elif ground_state == GroundState.JumpingToFalling && is_grounded:
		$"properties/jump-duration".stop()
		ground_state = GroundState.Grounded
		jump_input = false
		s_input = false
	elif ground_state == GroundState.Falling && is_grounded:
		$"properties/jump-duration".stop()
		ground_state = GroundState.Grounded
		jump_input = false
		s_input = false

func process_pipes_entry():
	if pipe_entry.has("e") && pipe_entry["e"]:
		pipe_entry["e"] = false
		print("trying to enter east pipe")
	if pipe_entry.has("w") && pipe_entry["w"]:
		pipe_entry["w"] = false
		print("trying to enter west pipe")
	if pipe_entry.has("n") && pipe_entry["n"]:
		pipe_entry["n"] = false
		print("trying to enter north pipe")
	if pipe_entry.has("s") && pipe_entry["s"] && $pipe_detector/S.get_collider():
		pipe_entry["s"] = false
		var pipe = $pipe_detector/S.get_collider().get_parent()
		if (pipe is Pipe):
			global_position = pipe.other_pipe.get_node("exit").global_position + Vector2.UP

func process_special_attacks():
	var is_grounded = $ground_checker.is_grounded
	if active_state == $"states/small-mario" && is_grounded && ground_state == GroundState.Grounded && s_input:
		s_input = false
		ground_state = GroundState.JumpingSmall

func _on_jumpduration_timeout():
	ground_state = GroundState.JumpingToFalling
