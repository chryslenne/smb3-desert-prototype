extends Camera2D

@export var target : Node2D
@export var follow : bool

func _ready():
	target = Level.player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if follow || !target:
		return
	call_deferred("follow_target")

func follow_target():
	global_position = target.global_position
