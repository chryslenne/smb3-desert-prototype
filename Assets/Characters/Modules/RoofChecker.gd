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
#	var space_state = get_world_2d().direct_space_state
#	# use global coordinates, not local to node
#	var query = $ShapeCast2D.add_exception()
##	var query = PhysicsShapeQueryParameters2D.create(
##		self.global_position, 
##		self.global_position + Vector2.UP * 1)
#	query.exclude = exception
#	var result = space_state.intersect_ray(query)
#	print(result)
#	is_roofed = result.size() > 0
