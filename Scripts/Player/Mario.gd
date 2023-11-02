extends CharacterBody2D
class_name SMBPlayer

#---------------------#
# signals             #
#---------------------#
signal onPlayerDeath

#---------------------#
# properties          #
#---------------------#
static var entity : SMBPlayer
@export_range(0, 1000, 5) var move_speed : float = 85
@export_range(0, 10, 0.1) var run_speed : float = 2
@export_range(1000, 0, 5) var jump_power : float = 200
@export_range(1000, 0, 5) var fall_speed : float = 200
@export_range(200, 2000, 10) var vertical_delta : float = 1000
var vertical_speed : float
var horizontal_speed : float
var jump_boost : bool = false
# Character input & states
var h_input : int
var v_input : int
var s_input : bool
var j_input : bool
var pipe_entry : Dictionary
var run_input : bool
var is_jumping : bool
var active_state

# ==================
# For start
func _ready():
	active_state = $States/Small_Mario
	## warm up the pipe entry logic
	for dir in Enums.Directions:
		pipe_entry[Enums.Directions[dir]] = false
	## adds hitscan callback
	$DownwardHitscan.hitscan_found.connect(fall_attack_success)

func _notification(what):
	match what:
		NOTIFICATION_ENTER_TREE:
			entity = self
		NOTIFICATION_EXIT_TREE:
			entity = null

# ==================
# Receives player input here
func _input(event):
	if event.is_action("move_right"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry[Enums.Directions.E] = true
			h_input += 1
		elif event.is_released() && !event.is_echo():
			pipe_entry[Enums.Directions.E] = false
			h_input -= 1
	if event.is_action("move_left"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry[Enums.Directions.W] = true
			h_input -= 1
		elif event.is_released() && !event.is_echo():
			pipe_entry[Enums.Directions.W] = false
			h_input += 1
	if event.is_action("move_up"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry[Enums.Directions.N] = true
			v_input -= 1
		elif event.is_released() && !event.is_echo():
			pipe_entry[Enums.Directions.N] = false
			v_input += 1
	if event.is_action("move_down"):
		if event.is_pressed() && !event.is_echo():
			pipe_entry[Enums.Directions.S] = true
			v_input += 1
		elif event.is_released() && !event.is_echo():
			pipe_entry[Enums.Directions.S] = false
			v_input -= 1
	
	if event.is_action("run"):
		if event.is_pressed():
			run_input = true
		elif event.is_released():
			run_input = false
	
	if event.is_action("jump"):
		if event.is_pressed() && !event.is_echo():
			j_input = true
		elif event.is_released() && !event.is_echo():
			j_input = false
	
	if event.is_action("special"):
		if event.is_pressed() && !event.is_echo():
			s_input = true
		elif event.is_released() && !event.is_echo():
			s_input = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_movements(delta)
	process_pipes_entry()

func process_movements(delta):
	if h_input > 0:
		$States.scale.x = 1
	elif h_input < 0:
		$States.scale.x = -1
	if (j_input || s_input) && is_on_floor():
		jump()
	if !j_input && !s_input && is_jumping:
		is_jumping = false
		$Timer/Jump.stop()
	## process horizontal speed
	## this is moving depending on the h_input and it is smooth
	horizontal_speed = move_toward(horizontal_speed, h_input, delta * 3)
	velocity.x = horizontal_speed * (move_speed * run_speed if run_input else move_speed)
	## process vertical speed
	## and depending on the
	## jump state
	if is_jumping:
		velocity.y = -jump_power * (1.25 if jump_boost else 1.0)
	elif is_on_floor():
		if !$Timer/Jump.is_stopped():
			$Timer/Jump.stop()
		velocity.y = delta
	else:
		velocity.y = move_toward(velocity.y, fall_speed, vertical_delta * delta)
	## if bump the ceiling, then we fall
	if is_on_ceiling():
		var col = get_last_slide_collision().get_collider() as Block
		col.hit(self)
		velocity.y = fall_speed
		is_jumping = false
		j_input = false
		$Timer/Jump.stop()
	if s_input:
		is_jumping = false
		s_input = false
	## Process the hitscan
	$DownwardHitscan.enabled = !is_on_floor() && velocity.y > 0
	move_and_slide()

func process_pipes_entry():
	for dir in Enums.Directions:
		if pipe_entry[Enums.Directions[dir]]:
			pipe_entry[Enums.Directions[dir]] = false
			enter_active_pipe(dir)

func enter_active_pipe(dir):
	if Pipe.nearest_pipe == null:
		return
	if Pipe.nearest_pipe.entry_dir == Enums.Directions[dir]:
		if Pipe.nearest_pipe.scene_camera != Pipe.nearest_pipe.other_pipe.scene_camera:
			Pipe.nearest_pipe.other_pipe.scene_camera.enabled = true
			Pipe.nearest_pipe.scene_camera.enabled = false
		Pipe.nearest_pipe.transition(self)
		horizontal_speed = 0

func _on_jumpduration_timeout():
	is_jumping = false

func hit():
	pass

func jump():
	is_jumping = true
	$Timer/Jump.start()

func fall_attack_success():
	if j_input:
		jump()
	else:
		force_jump()

func force_jump():
	velocity.y = -jump_power * (1.25 if jump_boost else 1.0)
