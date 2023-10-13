extends Node2D

#---------------------#
# properties          #
#---------------------#
var is_grounded : bool
var exceptions : Array

#---------------------#
# godot functions     #
#---------------------#
# Called every frame. 'delta' is the elapsed time since the previous frame.
#
# This function shoots a raycast downwards
# and sets the flag 'is_grounded' depending on the collision size
func _process(_delta):
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(
		self.global_position, 
		self.global_position + Vector2.DOWN * 0.1)
	query.exclude = exceptions
	var result = space_state.intersect_ray(query)
	is_grounded = result.size() > 0
