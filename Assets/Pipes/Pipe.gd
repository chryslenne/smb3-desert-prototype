extends Node2D
class_name Pipe

const enums = preload("res://Assets/Basics/Enums.gd")

#---------------------#
# properties          #
#---------------------#
@export var other_pipe : Pipe
@export var entry_dir : enums.Directions
@export var scene_camera : Camera2D

#---------------------#
# accessors           #
#---------------------#
func is_entry_illegal(): return entry_dir == enums.Directions.None
func is_north_entry(): return entry_dir == enums.Directions.N
func is_south_entry(): return entry_dir == enums.Directions.S
func is_east_entry(): return entry_dir == enums.Directions.E
func is_west_entry(): return entry_dir == enums.Directions.W

func exit_position():
	return $Exit.global_position
	
func opposite_dir():
	match entry_dir:
		enums.Directions.N:
			return enums.Directions.S
		enums.Directions.W:
			return enums.Directions.E
		enums.Directions.S:
			return enums.Directions.N
		enums.Directions.E:
			return enums.Directions.W
	return entry_dir # return self if not found

#---------------------#
# godot functions     #
#---------------------#
# Called when the node enters 
# the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is 
# the elapsed time since the previous frame.
func _process(_delta):
	pass

func transition(body):
	if Level == null || Level.pipe_users.has(body):
		return
	
	if body is PhysicsBody2D:
		body.set_process(false)
		body.set_physics_process(false)
		var transitionInstance = Level.preloaded_assets["pipe_transition"].instantiate()
		if transitionInstance is PipeTransition:
			transitionInstance.body = body
			transitionInstance.entry = self
			transitionInstance.exit = other_pipe
			transitionInstance.OnTransitionComplete.connect(on_pipe_transition_complete)
		Level.add_child(transitionInstance)

func on_pipe_transition_complete(body):
		body.set_process(true)
		body.set_physics_process(true)

func player_on_pipe(player):
	if Level != null:
		Level.pipe = self

func player_left_pipe(player):
	if Level != null && Level.pipe == self:
		Level.pipe = null
