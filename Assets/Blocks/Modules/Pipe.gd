extends Node2D
class_name Pipe

const enums = preload("res://Assets/Basics/Enums.gd")

#---------------------#
# properties          #
#---------------------#
@export var other_pipe : Pipe
@export var entry_dir : enums.Directions

#---------------------#
# accessors           #
#---------------------#
func is_entry_illegal(): return entry_dir == enums.Directions.None
func is_north_entry(): return entry_dir == enums.Directions.N
func is_south_entry(): return entry_dir == enums.Directions.S
func is_east_entry(): return entry_dir == enums.Directions.E
func is_west_entry(): return entry_dir == enums.Directions.W

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

