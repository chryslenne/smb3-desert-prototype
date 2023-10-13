extends Node2D

var is_grounded : bool
var exceptions : Array


# Called when the node enters the scene tree for the first time.
func _enter_tree():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(
		self.global_position, 
		self.global_position + Vector2.DOWN * 0.1)
	query.exclude = exceptions
	var result = space_state.intersect_ray(query)
	is_grounded = result.size() > 0
