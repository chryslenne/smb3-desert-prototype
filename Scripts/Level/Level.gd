extends Node2D
class_name Level

const enums = preload("res://Scripts/Basic/Enums.gd")

static var instance : Level
var loaded_assets : Dictionary 

func load_assets():
	## preloaded powerups here
	Pickup.load_assets()

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	instance = self
	# load assets here
	load_assets()

func get_instance_container():
	if has_node("World/Instantiated"):
		return $World/Instantiated
	return self
