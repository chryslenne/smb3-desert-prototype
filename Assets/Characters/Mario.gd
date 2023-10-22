extends CharacterBody2D
class_name SMBPlayer

enum GroundState
{
	Grounded,
	Jumping,
	JumpingSmall,
	JumpingToFalling,
	Falling,
}

const enums = preload("res://Assets/Basics/Enums.gd")

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
var jump_boost : bool = false
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

# ==================
# For start
func _ready():
	active_state = $"states/small-mario"
	Level.player = self
	## warm up the pipe entry logic
	for dir in enums.Directions:
		pipe_entry[enums.Directions[dir]] = false

# ==================
# Receives player input here
func _input(event):
	if event.is_action("move_right"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry[enums.Directions.E] = true
			h_input += 1
		elif event.is_released() && !event.is_echo():
			pipe_entry[enums.Directions.E] = false
			h_input -= 1
	if event.is_action("move_left"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry[enums.Directions.W] = true
			h_input -= 1
		elif event.is_released() && !event.is_echo():
			pipe_entry[enums.Directions.W] = false
			h_input += 1
	if event.is_action("move_up"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry[enums.Directions.N] = true
			v_input -= 1
		elif event.is_released() && !event.is_echo():
			pipe_entry[enums.Directions.N] = false
			v_input += 1
	if event.is_action("move_down"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry[enums.Directions.S] = true
			v_input += 1
		elif event.is_released() && !event.is_echo():
			pipe_entry[enums.Directions.S] = false
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
			move_and_slide()
		GroundState.Jumping:
			velocity.y = -jump_power * (1.25 if jump_boost else 1)
			move_and_slide()
		GroundState.JumpingSmall:
			velocity.y = -jump_power
			move_and_slide()
		GroundState.JumpingToFalling:
			velocity.y = move_toward(velocity.y, -fall_speed, vertical_delta * delta)
			move_and_slide()
		GroundState.Falling:
			velocity.y = -fall_speed
			move_and_slide()

func is_grounded(): return $ground_checker.is_grounded

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
	for dir in enums.Directions:
		if pipe_entry[enums.Directions[dir]]:
			print("attemtping to enter a pipe with a ", dir, " direction")
			pipe_entry[enums.Directions[dir]] = false
			enter_active_pipe(dir)

func enter_active_pipe(dir):
	if Level == null || Level.pipe == null:
		return
	if Level.pipe.entry_dir == enums.Directions[dir]:
		if Level.pipe.scene_camera != Level.pipe.other_pipe.scene_camera:
			Level.pipe.other_pipe.scene_camera.enabled = true
			Level.pipe.scene_camera.enabled = false
		Level.pipe.transition(self)
		horizontal_speed = 0

func process_special_attacks():
	var is_grounded = $ground_checker.is_grounded
	if active_state == $"states/small-mario" && is_grounded && ground_state == GroundState.Grounded && s_input:
		s_input = false
		ground_state = GroundState.JumpingSmall

func _on_jumpduration_timeout():
	ground_state = GroundState.JumpingToFalling
