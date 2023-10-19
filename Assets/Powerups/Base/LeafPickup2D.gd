extends CharacterBody2D
class_name LeafPickup2D

signal leaf_despawned

var vertical_speed : float = 50
@onready var p0 = $SwayPath/p0.position
@onready var p1 = $SwayPath/p1.position
@onready var p2 = $SwayPath/p2.position
var dir = 1
var time = 0.5
@export var speed = 2
@onready var leafstate = LeafState.Spawning

enum LeafState
{
	Spawning,
	Falling
}

func bezier(t):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	return q0.lerp(q1, t)

func _ready():
	$CollisionShape2D.position = bezier(0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if leafstate == LeafState.Spawning:
		position += Vector2.UP * delta * vertical_speed
	if leafstate == LeafState.Falling:
		position += Vector2.DOWN * delta * vertical_speed * 0.2
		$CollisionShape2D.position = bezier(time)
		time += delta * dir * 2
		if time >= 1:
			dir = move_toward(dir, -1, delta * speed)
		elif time <= 0:
			dir = move_toward(dir, 1, delta * speed)

func state_despawn():
	queue_free()
	leaf_despawned.emit()
	$DespawnDuration.stop()

func _on_spawn_duration_timeout():
	leafstate = LeafState.Falling

func _on_despawn_duration_timeout():
	queue_free()
