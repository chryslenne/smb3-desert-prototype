class_name Projectile
extends Node2D

@export var speed : float
@export var direction : Vector2
@export var duration : float = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$Lifetime.start(duration)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	translate(speed * direction * delta)

func _on_lifetime_timeout():
	queue_free()
