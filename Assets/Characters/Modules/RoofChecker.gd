extends Node2D

var is_roofed : bool
var exceptions : Array

func _enter_tree():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	for exception in exceptions:
		($ShapeCast2D as ShapeCast2D).add_exception(exception)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	is_roofed = ($ShapeCast2D as ShapeCast2D).get_collision_count() > 0
	
	for i in ($ShapeCast2D as ShapeCast2D).get_collision_count():
		if ($ShapeCast2D as ShapeCast2D).get_collider(i).has_node("properties/breakable"):
			($ShapeCast2D as ShapeCast2D).get_collider(i).break_block()
