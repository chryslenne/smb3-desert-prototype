extends Node
class_name PipeTransition
const enums = preload("res://Assets/Basics/Enums.gd")

enum Mode
{
	Entry,
	Exit
}

signal OnTransitionComplete(body)

static var active_transitions : Dictionary
var body : Node2D = null
var entry : Pipe
var exit : Pipe
var max_distance = 32 #32 pixels
var current_mode = Mode.Entry

func _ready():
	current_mode = Mode.Entry
	$TransitionDuration.start()
	
func _notification(what):
	match what:
		NOTIFICATION_POSTINITIALIZE:
			active_transitions[body] = self
		NOTIFICATION_PREDELETE:
			active_transitions.erase(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_mode:
		Mode.Entry:
			body.position += enums.DirectionToVector2(entry.entry_dir) * delta * max_distance
		Mode.Exit: 
			body.position += enums.DirectionToVector2(entry.opposite_dir()) * delta * max_distance

func on_transition_duration_complete():
	match current_mode:
		Mode.Entry:
			body.global_position = exit.exit_position() + enums.DirectionToVector2(exit.entry_dir) * max_distance
			current_mode = Mode.Exit
			$TransitionDuration.start()
		Mode.Exit:
			OnTransitionComplete.emit(body)
			queue_free()
