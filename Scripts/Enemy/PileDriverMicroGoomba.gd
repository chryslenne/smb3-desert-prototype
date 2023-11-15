extends Enemy
class_name PileDriverMicroGoomba

static var asset : PackedScene

static func get_entities():
	return entities.filter(func(entity): return entity is PileDriverMicroGoomba)

enum States
{
	Idle,
	WindingUp,
	JumpAndTrack
}

func is_jump_allowed() -> bool:
	return state_current == States.JumpAndTrack && $StateTime.time_left > 0

# Character input & states
var h_input : int = 1

@export var idle_duration_range = Vector2(1, 2)
@export var windup_duration_range = Vector2(1, 1)
@export var jump_duration_range = Vector2(0.25, 0.5)
@export_range(1, 10) var windup_size : int = 2
@export_range(0, 1000, 5) var move_speed : float = 60
@export_range(1000, 0, 5) var fall_speed : float = 200
@export_range(1000, 0, 5) var jump_power : float = 200
@export_range(200, 2000, 10) var vertical_delta : float = 1000
var windup_counter = 0
var windup_half_time = 0
var windup_distance = 4 # pixels
var state_current : States = States.Idle

func _process(_delta):
	if is_on_wall() && !is_on_floor(): h_input = -h_input
	if is_on_floor() && state_current == States.JumpAndTrack && !is_jump_allowed():
		state_current = States.Idle
		$StateTime.start(randf_range(idle_duration_range.x, idle_duration_range.y))
	if state_current == States.WindingUp:
		var diff_scale = 1 - (max(abs($StateTime.time_left - windup_half_time), 0) / windup_half_time)
		$Offset/AnimatedSprite2D_FakeBrick.position = Vector2.UP * diff_scale * windup_distance
	call_deferred("h_input_to_player")

func _physics_process(delta):
	## process vertical speed
	## and horizontal speed
	if is_on_floor():
		velocity.y = delta
		velocity.x = 0
	else:
		velocity.x = h_input * move_speed
		velocity.y = move_toward(velocity.y, fall_speed, vertical_delta * delta)
	if is_jump_allowed():
		velocity.y = -jump_power
	move_and_slide()

func spawn():
	super.spawn()
	## Update the initial direction
	if StringLookup.LeftNames.has(spawn_direction.to_lower()):
		h_input = -1
	elif StringLookup.RightNames.has(spawn_direction.to_lower()):
		h_input = 1
	$Offset/AnimatedSprite2D_FakeBrick.position = Vector2.ZERO
	## Update its physics body
	velocity = Vector2.ZERO
	## Spawn with idle
	$StateTime.start(randf_range(idle_duration_range.x, idle_duration_range.y))

func despawn():
	super.despawn()

func hit():
	super.hit()
	## Same with goomba, firesnake will be killed in one hit
	kill()

func kill():
	super.kill()
	## Disable its physics body and any detector
	set_physics_process(false)
	set_process(false)
	$DamageArea2D.monitoring = false
	$HitArea2D.monitorable = false	
	## Toggle timer for despawn
	$Timer.start()

func h_input_to_player():
	# Tracks player
	if SMBPlayer.entity:
		if SMBPlayer.entity.global_position.x > self.global_position.x:
			h_input = 1
		elif SMBPlayer.entity.global_position.x < self.global_position.x:
			h_input = -1


func _on_damage_area_2d_body_entered(body):
	## If it is not processing at all
	## it means it is dead!
	if !is_processing() || !is_physics_processing():
		return
	## Only scan for player and find the correct body class
	if body is SMBPlayer:
		body.hit()

func _on_timer_timeout():
	queue_free()

func _on_state_time_timeout():
	match state_current:
		States.Idle:
			# switch to windups
			windup_counter = 1
			state_current = States.WindingUp
			windup_half_time = randf_range(windup_duration_range.x, windup_duration_range.y)
			$StateTime.start(windup_half_time)
			windup_half_time *= 0.5
		States.WindingUp:
			# restart windup if not yet max
			if windup_counter < windup_size:
				windup_counter += 1
				windup_half_time = randf_range(windup_duration_range.x, windup_duration_range.y)
				$StateTime.start(windup_half_time)
				windup_half_time *= 0.5
			# else do jump and track
			else:
				print("jump!")
				state_current = States.JumpAndTrack
				$StateTime.start(randf_range(jump_duration_range.x, jump_duration_range.y))
				$Offset/AnimatedSprite2D_FakeBrick.position = Vector2.ZERO

func _on_visible_on_screen_notifier_2d_screen_exited():
	if owner is EnemySpawner:
		owner.enemy = null
	$Timer.stop()
	queue_free()


