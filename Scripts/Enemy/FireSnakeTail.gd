extends Enemy
class_name FireSnakeTail

const asset = preload("res://Prefabs/Enemies/FireSnakeTail.tscn")

static func get_entities():
	return entities.filter(func(entity): return entity is FireSnakeTail)

# Character input & states
@export var FOLLOW_DELAY_INCREMENTAL = 0.1
var follow_delay = FOLLOW_DELAY_INCREMENTAL
var follow_tail : FireSnakeTail
var main_body : FireSnake
var is_jumping : bool = false
var has_jump : bool = false

func prepare_jump():
	$JumpCooldown.start(follow_delay)

func spawn():
	super.spawn()
	## Update its states and animations
	$AnimatedSprite2D.play("tail")
	## Update its physics body
	velocity = Vector2.ZERO

func hit():
	super.hit()
	if main_body:
		main_body.hit()

func physics_process(delta):
	has_jump = true
	## process vertical speed
	## and horizontal speed
	if !is_on_floor():
		var follow = follow_tail if follow_tail != null else main_body
		var dist = follow.global_position.x - self.global_position.x
		if abs(dist) > 2:
			velocity.x = sign(dist) * main_body.move_speed
		else:
			velocity.x = 0
		velocity.y = move_toward(velocity.y, main_body.fall_speed, main_body.vertical_delta * delta)
	if $JumpTime.time_left > 0:
		velocity.y = -main_body.jump_power
	move_and_slide()
	
	if is_on_floor():
		is_jumping = false
		velocity.y = main_body.fall_speed
		velocity.x = 0

func kill():
	super.kill()
	## Disable its physics body and any detector
	set_physics_process(false)
	set_process(false)
	$DamageArea2D.monitoring = false
	$HitArea2D.monitorable = false
	## Toggle timer for despawn
	$Timer.start()


func _on_damage_area_2d_body_entered(body):
	## If it is not processing at all
	## it means it is dead!
	if !is_processing() || !is_physics_processing():
		return
	## Only scan for player and find the correct body class
	if body is SMBPlayer:
		body.hit()

func _on_jump_cooldown_timeout():
	$JumpTime.start(main_body.jump_time)
	is_jumping = true
	has_jump = false
