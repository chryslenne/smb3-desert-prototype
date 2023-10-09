extends Node2D

class_name Pipe

enum EntryDirection
{
	N,
	W,
	S,
	E
}

@export var other_pipe : Pipe
@export var entry_dir : EntryDirection

func is_north_entry(): return entry_dir == EntryDirection.N
func is_south_entry(): return entry_dir == EntryDirection.S
func is_east_entry(): return entry_dir == EntryDirection.E
func is_west_entry(): return entry_dir == EntryDirection.W

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

