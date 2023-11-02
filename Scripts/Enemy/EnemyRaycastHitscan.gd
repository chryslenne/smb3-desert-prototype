extends ShapeCast2D

@export var exceptions : Array = []
@export var target_hitscan : String = "AllowableHitTypes/JumpAttack"

signal hitscan_found

func _ready():
	for exception in exceptions:
		add_exception(exception)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		var success = false
		for i in get_collision_count():
			var entity = get_collider(i).owner
			if entity is Enemy && entity.has_node(target_hitscan):
				success = true
				entity.hit()
				add_exception(get_collider(i))
				if !entity.enemy_despawned.is_connected(delay_remove_exception):
					entity.enemy_despawned.connect(delay_remove_exception)
				break
		if success:
			hitscan_found.emit()

func delay_remove_exception(body):
	remove_exception(body.get_node("HitArea2D"))
