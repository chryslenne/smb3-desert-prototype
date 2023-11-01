extends Enemy
class_name Goomba

const asset = preload("res://Enemies/Goomba.tscn")

static func get_entities():
	return entities.filter(func(entity): return entity is Goomba)

# Character input & states
var h_input : int = 1

@export_range(0, 1000, 5) var move_speed : float = 30
@export_range(1000, 0, 5) var fall_speed : float = 200
@export_range(200, 2000, 10) var vertical_delta : float = 1000

func _enter_tree():
	spawn()
func _exit_tree():
	despawn()

func _process(_delta):
	if is_on_wall(): h_input = -h_input
	$AnimatedSprite2D.scale.x = h_input

func _physics_process(delta):
	## process horizontal speed
	velocity.x = h_input * move_speed

	## process vertical speed
	if is_on_floor():
		velocity.y = delta
	else:
		velocity.y = move_toward(velocity.y, fall_speed, vertical_delta * delta)

	move_and_slide()

func spawn():
	super.spawn()
	## Update the initial direction
	if StringLookup.LeftNames.has(spawn_direction.to_lower()):
		h_input = -1
	elif StringLookup.RightNames.has(spawn_direction.to_lower()):
		h_input = 1
	
	## Update its states and animations
	$AnimatedSprite2D.play("default")
	
	## Update its physics body
	velocity = Vector2.ZERO

func hit():
	super.hit()
	## Since this is a goomba, one hit of goomba is death
	kill()

func kill():
	super.kill()
	## Disable its physics body and any detector
	set_physics_process(false)
	set_process(false)
	$DamageArea2D.monitoring = false
	$HitArea2D.monitorable = false
	
	## Update its animation
	$AnimatedSprite2D.play("death")
	
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

func _on_timer_timeout():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if owner is EnemySpawner:
		owner.enemy = null
	$Timer.stop()
	queue_free()
