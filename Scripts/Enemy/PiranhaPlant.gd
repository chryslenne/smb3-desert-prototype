class_name PiranhaPlant
extends Enemy

const id = 'mob_piranhaplant'
static func get_asset():
	if Level.instance:
		if !Level.instance.loaded_assets.has(id):
			Level.instance.loaded_assets[id] = load('res://Prefabs/Enemies/PiranhaPlant.tscn')
		return Level.instance.loaded_assets[id]
	else: return null

static func get_entities():
	return entities.filter(func(entity): return entity is PiranhaPlant)

const NORTH = "N"
const WEST = "W"
const SOUTH = "S"
const EAST = "E"

const VARIATION_DEFAULT_ID = VARIATION_SHORT_ID
const VARIATION_SHORT_ID = "Short"
const VARIATION_LONG_ID = "Long"

const ATTACK_DEFAULT_ID = ATTACK_MELEE_ID
const ATTACK_MELEE_ID = "Melee"
const ATTACK_RANGED_ID = "Ranged"

const LOOK_UP = PI * 0
const LOOK_DOWN = PI * 1.0
const LOOK_LEFT = PI * 1.5
const LOOK_RIGHT = PI * 0.5

@export_enum(ATTACK_MELEE_ID, ATTACK_RANGED_ID) var attack = ATTACK_DEFAULT_ID
@export_enum(VARIATION_SHORT_ID, VARIATION_LONG_ID) var variation = VARIATION_LONG_ID
@export_enum(NORTH, WEST, SOUTH, EAST) var direction : String:
	set(val):
		spawn_direction = val
	get:
		return spawn_direction

enum States
{
	Hidden,
	Rising,
	Aiming,
	Falling
}

@export var hidden_duration = 2
@export var rising_duration = 1
@export var aiming_duration = 3
@export var falling_duration = 1
@export var shoot_delay = 0.5
@export var shoot_interval = 1
@export var bullet_count = 2

var bullet_current
var state_current

func plant_height():
	return $Body.global_position.y - $Body/Head/Height.global_position.y

func _process(delta):
	match state_current:
		States.Rising:
			$Body.position = Vector2.DOWN * plant_height() * (max($TransitionTimer.time_left, 0) / rising_duration)
		States.Aiming:
			if attack.to_lower() == ATTACK_RANGED_ID.to_lower() && bullet_current > 0 && $ShootDelay.time_left <= 0:
				try_shoot_player()
			if attack.to_lower() == ATTACK_RANGED_ID.to_lower():
				look_at_player()
		States.Falling:
			$Body.position = Vector2.DOWN * plant_height() * ((falling_duration - max($TransitionTimer.time_left, 0)) / falling_duration)

func _use_spawn_config(config):
	if config is String:
		for dat in config.split(';'):
			var c = dat.split('=')
			if c.size() == 2:
				print(c[0], " = ", c[1])
				match c[0]:
					"attack":
						attack = c[1]
					"variation":
						variation = c[1]
					"direction":
						direction = c[1]

func try_shoot_player():
	bullet_count -= 1
	$ShootDelay.start(shoot_interval)

func look_at_player():
	if SMBPlayer.entity == null:
		return
	var dir = SMBPlayer.entity.global_position - $Body/Head.global_position
	var rhs = Vector2.UP
	var lhs = dir.normalized()
	var dot = rhs.dot(lhs)
	$Body/Head/Range.scale.x = -1 if dir.x > 0 else 1
	if state_current == States.Aiming:
		if dot > 0:
			$Body/Head/Range/HighOpen.visible = true;
			$Body/Head/Range/HighClose.visible = false;
			$Body/Head/Range/LowOpen.visible = false;
			$Body/Head/Range/LowClose.visible = false;
		else:
			$Body/Head/Range/HighOpen.visible = false;
			$Body/Head/Range/HighClose.visible = false;
			$Body/Head/Range/LowOpen.visible = true;
			$Body/Head/Range/LowClose.visible = false;
	else:
		if dot > 0:
			$Body/Head/Range/HighOpen.visible = false;
			$Body/Head/Range/HighClose.visible = true;
			$Body/Head/Range/LowOpen.visible = false;
			$Body/Head/Range/LowClose.visible = false;
		else:
			$Body/Head/Range/HighOpen.visible = false;
			$Body/Head/Range/HighClose.visible = false;
			$Body/Head/Range/LowOpen.visible = false;
			$Body/Head/Range/LowClose.visible = true;

func spawn():
	super.spawn()
	## set directions
	## direction will be set to default "N"
	## when empty or null
	if spawn_direction == "" || spawn_direction == null:
		spawn_direction = "n"
	match spawn_direction.to_lower():
		_, "n": 
			spawn_direction = "n"
			$Body/Stem.rotation = LOOK_UP
			if attack.to_lower() == ATTACK_MELEE_ID.to_lower():
				$Body/Head/Melee.play("bite_up")
				$Body/Head/Melee.visible = true
				$Body/Head/Melee.rotation = LOOK_UP
				$Body/Head/Range.visible = false
			else:
				$Body/Head/Melee.stop
				$Body/Head/Melee.visible = false
				$Body/Head/Range.rotation = LOOK_UP
				$Body/Head/Range.visible = true
		"w": 
			$Body/Stem.rotation = LOOK_LEFT
			if attack.to_lower() == ATTACK_MELEE_ID.to_lower():
				$Body/Head/Melee.play("bite_up")
				$Body/Head/Melee.visible = true
				$Body/Head/Melee.rotation = LOOK_LEFT
				$Body/Head/Range.visible = false
			else:
				$Body/Head/Melee.stop
				$Body/Head/Melee.visible = false
				$Body/Head/Range.rotation = LOOK_LEFT
				$Body/Head/Range.visible = true
		"s": 
			$Body/Stem.rotation = LOOK_DOWN
			if attack.to_lower() == ATTACK_MELEE_ID.to_lower():
				$Body/Head/Melee.play("bite_up")
				$Body/Head/Melee.visible = true
				$Body/Head/Melee.rotation = LOOK_DOWN
				$Body/Head/Range.visible = false
			else:
				$Body/Head/Melee.stop
				$Body/Head/Melee.visible = false
				$Body/Head/Range.rotation = LOOK_DOWN
				$Body/Head/Range.visible = true
		"e": 
			$Body/Stem.rotation = LOOK_RIGHT
			if attack.to_lower() == ATTACK_MELEE_ID.to_lower():
				$Body/Head/Melee.play("bite_up")
				$Body/Head/Melee.visible = true
				$Body/Head/Melee.rotation = LOOK_RIGHT
				$Body/Head/Range.visible = false
			else:
				$Body/Head/Melee.stop
				$Body/Head/Melee.visible = false
				$Body/Head/Range.rotation = LOOK_RIGHT
				$Body/Head/Range.visible = true
	## set variation!
	## variation will be set to default "short"
	## when empty or null
	if variation == "" || variation == null:
		variation = "short"
	match variation.to_lower():
		_, "short":
			variation = "short"
#			$Body/AreaBodies/HitArea2D/HitShape2D.shape.y = 20
#			$Body/AreaBodies/DamageArea2D/DamageShape2D.shape.y = 20
			#set unneccessary stem invisible
			#set needed stem visible
			$Body/Stem/Long.visible = false
			$Body/Stem/Short.visible = true
			$Body/Head.position = $Body/HeadDistance/Short.position.rotated($Body/Stem.rotation)
		"long":
#			$Body/AreaBodies/HitArea2D/HitShape2D.shape.y = 30
#			$Body/AreaBodies/DamageArea2D/DamageShape2D.shape.y = 30
			#set unneccessary stem invisible
			#set needed stem visible
			$Body/Stem/Short.visible = false
			$Body/Stem/Long.visible = true
			$Body/Head.position = $Body/HeadDistance/Long.position.rotated($Body/Stem.rotation)
	## set initial values
	state_current = States.Hidden
	bullet_current = 0
	## set height
	$Body.position = Vector2.DOWN * plant_height()
	## start timer
	$TransitionTimer.start(hidden_duration)

func _on_transition_timer_timeout():
	match state_current:
		States.Hidden: 
			if attack.to_lower() == ATTACK_RANGED_ID.to_lower():
				look_at_player()
			state_current = States.Rising
			$TransitionTimer.start(rising_duration)
		States.Rising:
			state_current = States.Aiming
			$TransitionTimer.start(aiming_duration)
			# set height to max
			$Body.position = Vector2.ZERO
		States.Aiming:
			state_current = States.Falling
			$TransitionTimer.start(falling_duration)
			if attack.to_lower() == ATTACK_RANGED_ID.to_lower():
				look_at_player()
				$ShootDelay.start(shoot_delay)
				bullet_current = bullet_count
		States.Falling:
			state_current = States.Hidden
			$TransitionTimer.start(hidden_duration)
			# set height to minimum
			$Body.position = Vector2.DOWN * plant_height()

func _on_shoot_delay_timeout():
	if bullet_current < 1:
		bullet_current = bullet_count
		$ShootDelay.start(shoot_interval)
	else:
		bullet_current -= 1
		if bullet_current > 0:
			$ShootDelay.start(shoot_interval)
