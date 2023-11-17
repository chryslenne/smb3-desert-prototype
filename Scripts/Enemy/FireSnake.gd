extends Enemy
class_name FireSnake

const id = 'mob_firesnake_body'
static func get_asset():
	if Level.instance:
		if !Level.instance.loaded_assets.has(id):
			Level.instance.loaded_assets[id] = load('res://Prefabs/Enemies/FireSnakeMain.tscn')
		return Level.instance.loaded_assets[id]
	else: return null

static func get_entities():
	return entities.filter(func(entity): return entity is FireSnake)

# Character input & states
var h_input : int = 1

@export var tail_size = 4
@export var jump_time_range = Vector2(0.1, 0.25)
@export var jump_cooldown_range = Vector2(2, 5)
@export_range(0, 1000, 5) var move_speed : float = 60
@export_range(1000, 0, 5) var fall_speed : float = 200
@export_range(1000, 0, 5) var jump_power : float = 200
@export_range(200, 2000, 10) var vertical_delta : float = 1000
var jump_cooldown : float
var jump_time : float
var tails : Array = []

func random_jump_cooldown():
	jump_cooldown = randf_range(jump_cooldown_range.x, jump_cooldown_range.y)
func random_jump_time():
	jump_time = randf_range(jump_time_range.x, jump_time_range.y)

func _enter_tree():
	spawn()
func _exit_tree():
	despawn()

func _process(_delta):
	if is_on_wall() && !is_on_floor(): h_input = -h_input
	call_deferred("_deferred_process")

func _deferred_process():
	if is_on_floor() && $JumpCooldown.time_left <= 0 && $JumpTime.time_left <= 0:
		random_jump_cooldown()
		$JumpCooldown.start(jump_cooldown)
	# Tracks player
	if is_on_floor() && SMBPlayer.entity:
		if SMBPlayer.entity.global_position.x > self.global_position.x:
			h_input = 1
		elif SMBPlayer.entity.global_position.x < self.global_position.x:
			h_input = -1

func _physics_process(delta):
	## process vertical speed
	## and horizontal speed
	if is_on_floor():
		velocity.y = delta
		velocity.x = 0
	else:
		velocity.x = h_input * move_speed
		velocity.y = move_toward(velocity.y, fall_speed, vertical_delta * delta)
	if $JumpTime.time_left > 0:
		velocity.y = -jump_power
	move_and_slide()
	
	## process tails
	for tail in tails:
		if tail is FireSnakeTail && tail.is_jumping:
			tail.physics_process(delta)

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
	## Spawn its tails
	for i in tail_size:
		var tail = FireSnakeTail.get_asset().instantiate()
		if tail is FireSnakeTail:
			tail.spawn()
			tail.main_body = self
			tail.follow_tail = null if i == 0 else tails[i - 1]
			tail.z_index = z_index - (1 + i)
			get_parent().add_child(tail)
			tail.global_position = self.global_position
			tail.follow_delay += tail.FOLLOW_DELAY_INCREMENTAL * i
			## add to the list
			tails.append(tail)

func despawn():
	super.despawn()
	## despawn all tails
	for tail in tails:
		tail.queue_free()

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
	
	## Update its animation
#	$AnimatedSprite2D.play("death")
	
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

func _on_jump_cooldown_timeout():
	random_jump_time()
	$JumpTime.start(jump_time)
	for tail in tails:
		if tail is FireSnakeTail:
			tail.prepare_jump()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if owner is EnemySpawner:
		owner.enemy = null
	$Timer.stop()
	queue_free()
