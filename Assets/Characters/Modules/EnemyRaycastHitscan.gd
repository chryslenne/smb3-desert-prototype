extends ShapeCast2D

@export var exceptions : Array = []

func _ready():
	for exception in exceptions:
		add_exception(exception)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		for i in get_collision_count():
			var entity = get_collider(i).owner
			if entity is Enemy:
				entity.hit()
				add_exception(get_collider(i))
				entity.enemy_despawned.connect(delay_remove_exception)
		
		if owner is SMBPlayer:
			if owner.j_input:
				owner.jump()
			else:
				owner.force_jump()

func delay_remove_exception(body):
	remove_exception(body.get_node("HitArea2D"))
