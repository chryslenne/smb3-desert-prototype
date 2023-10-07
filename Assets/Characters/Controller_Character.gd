extends RigidBody2D

@export var cur_vel : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var h = 0
	var v = 0
	
	if Input.is_action_pressed("move_left"):
		h -= 1
	if Input.is_action_pressed("move_right"):
		h += 1
	if Input.is_action_pressed("jump"):
		v = 5
		
	if h != 0 || v != 0:
		cur_vel = (Vector2.RIGHT * h + Vector2.UP * v) * delta * 50
		move_and_collide(cur_vel)
	
